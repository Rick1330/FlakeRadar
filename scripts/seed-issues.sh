#!/usr/bin/env bash
# FlakeRadar Issue Seeder (production-grade)
# - Validates seed.json via schema (CI validates too)
# - Multi-repo targeting via "repo" per item; fallback transfer option
# - DRY_RUN=1 prints plan only
# - CLOSE_MISSING=1 auto-closes issues removed from seed.json (comment + label "obsolete-by-seed")
# - Creates standardized labels (with colors), milestones (Gate A-D, Sprint-xx), and adds issues to Projects v2
# - Rate-limited with retries
# - Uses GH_TOKEN (repo/project scopes) — principle of least privilege

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEED="${SEED:-$ROOT_DIR/issues/seed.json}"
SCHEMA="${SCHEMA:-$ROOT_DIR/schemas/issues.seed.schema.json}"
MAP="${MAP:-$ROOT_DIR/issues/map.json}"

REPO_DEFAULT="${REPO_DEFAULT:-rick1330/flakeradar-program}"
TRANSFER_FALLBACK="${TRANSFER_FALLBACK:-0}"
DRY_RUN="${DRY_RUN:-0}"
CLOSE_MISSING="${CLOSE_MISSING:-0}"

PROJECT_OWNER="${PROJECT_OWNER:-rick1330}"
PROJECT_TITLE="${PROJECT_TITLE:-FlakeRadar Roadmap}"  # or set PROJECT_NUMBER

GITHUB_OUTPUT="${GITHUB_OUTPUT:-/dev/null}"
GITHUB_STEP_SUMMARY="${GITHUB_STEP_SUMMARY:-/dev/null}"

# -------------- Utilities --------------
jq_bin() { command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }; }
gh_bin() { command -v gh >/dev/null || { echo "gh CLI is required" >&2; exit 1; }; }
ajv_validate() {
  if command -v ajv >/dev/null; then
    ajv validate -s "$SCHEMA" -d "$SEED" --spec=draft2020 --strict=true
  else
    echo "ajv not found; skipping local schema validation (CI will check)"
  fi
}

sleep_throttle() { sleep 0.3; } # gentle throttle
retry() {
  local max=${1:-5}; shift
  local n=1
  until "$@"; do
    if (( n >= max )); then return 1; fi
    sleep $(( n * n ))
    n=$(( n + 1 ))
  done
}

# -------------- Labels (standardized colors) --------------
declare -A LABELS_COLORS=(
  ["good first issue"]="7057ff"
  ["help wanted"]="008672"
  ["discussion"]="bfd4f2"
  ["gate:A"]="0e8a16"
  ["gate:B"]="5319e7"
  ["gate:C"]="fbca04"
  ["gate:D"]="d93f0b"
  ["persona:dev"]="1d76db"
  ["persona:qa"]="0e8a16"
  ["persona:sre"]="5319e7"
  ["persona:em"]="cfd3d7"
  ["module:ingest"]="0e8a16"
  ["module:scoring"]="fbca04"
  ["module:ui"]="1d76db"
  ["module:bot"]="d4c5f9"
  ["module:docs"]="bfdadc"
  ["priority:p1"]="e11d48"
  ["priority:p2"]="fb7185"
  ["priority:p3"]="fdba74"
  ["obsolete-by-seed"]="ededed"
)

ensure_labels() {
  local repo="$1"
  for name in "${!LABELS_COLORS[@]}"; do
    local color="${LABELS_COLORS[$name]}"
    if (( DRY_RUN == 1 )); then
      echo "PLAN: ensure label '$name' (#$color) in $repo"
    else
      retry 5 gh label create "$name" -R "$repo" --color "$color" --force >/dev/null 2>&1 || true
      sleep_throttle
    fi
  done
}

# -------------- Milestones --------------
ensure_milestone() {
  local repo="$1" title="$2"
  local number
  number=$(gh api -X GET "repos/$repo/milestones?state=open" --jq ".[] | select(.title==\"$title\") | .number" 2>/dev/null || true)
  if [[ -z "${number:-}" ]]; then
    if (( DRY_RUN == 1 )); then
      echo "PLAN: create milestone '$title' in $repo"
    else
      retry 5 gh api -X POST "repos/$repo/milestones" -f title="$title" >/dev/null
      sleep_throttle
    fi
  fi
}

auto_milestone_from_labels() {
  local labels_csv="$1"
  case "$labels_csv" in
    *"gate:A"*) echo "Gate A" ;;
    *"gate:B"*) echo "Gate B" ;;
    *"gate:C"*) echo "Gate C" ;;
    *"gate:D"*) echo "Gate D" ;;
    *) echo "" ;;
  esac
}

# -------------- Projects v2 --------------
get_project_number() {
  if [[ -n "${PROJECT_NUMBER:-}" ]]; then
    echo "$PROJECT_NUMBER"
    return
  fi
  # Find by title
  retry 5 gh project list --owner "$PROJECT_OWNER" --format json --jq ".[] | select(.title==\"$PROJECT_TITLE\") | .number"
}

add_to_project() {
  local url="$1"
  local owner="${2:-$PROJECT_OWNER}"
  local number
  number=$(get_project_number)
  [[ -z "$number" ]] && { echo "WARN: Project '$PROJECT_TITLE' not found under $PROJECT_OWNER"; return 0; }
  if (( DRY_RUN == 1 )); then
    echo "PLAN: add $url to project $owner#$number"
  else
    retry 5 gh project item-add --owner "$owner" --number "$number" --url "$url" >/dev/null
    sleep_throttle
  fi
}

# -------------- Issues search & mapping --------------
map_init() { [[ -f "$MAP" ]] || echo "{}" > "$MAP"; }
map_set() {
  local id="$1" repo="$2" number="$3"
  tmp="$(mktemp)"
  jq ". + {\"$id\": {\"repo\": \"$repo\", \"number\": $number}}" "$MAP" > "$tmp" && mv "$tmp" "$MAP"
}
map_get_repo() { jq -r ".\"$1\".repo // empty" "$MAP"; }
map_get_number() { jq -r ".\"$1\".number // empty" "$MAP"; }

find_issue_by_seed_id() {
  local repo="$1" id="$2"
  gh issue list -R "$repo" --state all \
    --search "in:body \"seed-id: $id\"" \
    --json number --jq '.[0].number' 2>/dev/null
}

issue_url() { echo "https://github.com/$1/issues/$2"; }

assign_users() {
  local repo="$1" number="$2" assignees_csv="$3"
  IFS=',' read -ra arr <<< "$assignees_csv"
  for u in "${arr[@]}"; do
    [[ -z "$u" ]] && continue
    if (( DRY_RUN == 1 )); then
      echo "PLAN: assign @$u to #$number in $repo"
    else
      retry 3 gh issue edit "$number" -R "$repo" --add-assignee "$u" >/dev/null || true
      sleep_throttle
    fi
  done
}

set_milestone() {
  local repo="$1" number="$2" milestone="$3"
  [[ -z "$milestone" ]] && return 0
  ensure_milestone "$repo" "$milestone"
  if (( DRY_RUN == 1 )); then
    echo "PLAN: set milestone '$milestone' on #$number in $repo"
  else
    retry 3 gh issue edit "$number" -R "$repo" --milestone "$milestone" >/dev/null || true
    sleep_throttle
  fi
}

# -------------- Close missing --------------
close_missing() {
  local -r all_ids_present="$1"
  # Iterate mapping keys and close those not in $all_ids_present
  local keys; keys=$(jq -r 'keys[]' "$MAP")
  for k in $keys; do
    if ! grep -qx "$k" <<< "$all_ids_present"; then
      local repo number
      repo=$(map_get_repo "$k"); number=$(map_get_number "$k")
      [[ -z "$repo" || -z "$number" ]] && continue
      local url; url=$(issue_url "$repo" "$number")
      if (( DRY_RUN == 1 )); then
        echo "PLAN: close $url as obsolete-by-seed"
      else
        retry 3 gh issue comment "$number" -R "$repo" -b "Closing as obsolete per seed sync. This item ($k) was removed from issues/seed.json." >/dev/null || true
        retry 3 gh issue edit "$number" -R "$repo" --add-label "obsolete-by-seed" >/dev/null || true
        retry 3 gh issue close "$number" -R "$repo" >/dev/null || true
        sleep_throttle
      fi
    fi
  done
}

# -------------- Compose bodies --------------
epic_body() {
  local id="$1" body="$2" adr_links_csv="$3"
  local adr_md=""
  if [[ -n "$adr_links_csv" ]]; then
    IFS=',' read -ra links <<< "$adr_links_csv"
    adr_md=$'\n''ADR Links:'$'\n'
    for l in "${links[@]}"; do adr_md+="- $l"$'\n'; done
  fi
  cat <<EOF
<!-- seed-id: $id -->
$body

Definition of Done
- [ ] Issues/stories linked and tracked
- [ ] Acceptance metrics defined and measured
- [ ] Budgets respected (a11y/perf/security/privacy)
- [ ] WUs completed (commit + Build Log + Session State)
$adr_md
EOF
}

story_body() {
  local id="$1" epic_url="$2" wu="$3" ac_lines="$4" adr_links_csv="$5" dod_lines="$6"
  local adr_md=""
  if [[ -n "$adr_links_csv" ]]; then
    IFS=',' read -ra links <<< "$adr_links_csv"
    adr_md=$'\n''ADR Links:'$'\n'
    for l in "${links[@]}"; do adr_md+="- $l"$'\n'; done
  fi

  local dod_md=""
  if [[ -n "$dod_lines" ]]; then
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      dod_md+="- [ ] $line"$'\n'
    done <<< "$dod_lines"
  else
    dod_md="- [ ] Tests updated/added"$'\n'
    dod_md+="- [ ] Docs updated (README/ADR)"$'\n'
    dod_md+="- [ ] Budgets enforced (a11y/perf/security/privacy)"$'\n'
    dod_md+="- [ ] Labels applied (gate:*, module:*, persona:*, priority:*)"$'\n'
    dod_md+="- [ ] WU completed (commit + Build Log + Session State)"$'\n'
  fi

  cat <<EOF
<!-- seed-id: $id -->
Parent Epic: $epic_url

WU: ${wu:-N/A}

Acceptance Criteria
$ac_lines
Definition of Done
$dod_md
$adr_md
EOF
}

# -------------- Main --------------
main() {
  jq_bin; gh_bin
  ajv_validate || { echo "Schema validation failed. Fix issues/seed.json."; exit 1; }
  map_init

  local summary=""
  local ids_present=""

  # Build list of target repos to pre-ensure labels
  local repos=()
  # Epics
  while IFS= read -r repo; do repos+=("$repo"); done < <(jq -r --arg R "$REPO_DEFAULT" '.epics[].repo // $R' "$SEED")
  # Stories
  while IFS= read -r repo; do repos+=("$repo"); done < <(jq -r --arg R "$REPO_DEFAULT" '.stories[].repo // $R' "$SEED")
  # Unique
  mapfile -t repos < <(printf "%s\n" "${repos[@]}" | sort -u)
  for r in "${repos[@]}"; do ensure_labels "$r"; done

  # Ensure default milestones in each repo
  for r in "${repos[@]}"; do
    for m in "Gate A" "Gate B" "Gate C" "Gate D"; do ensure_milestone "$r" "$m"; done
  done

  # Create epics first
  while IFS= read -r e; do
    local id title labels body repo milestone assignees adrLinks_csv
    id=$(jq -r '.id' <<<"$e")
    title=$(jq -r '.title' <<<"$e")
    body=$(jq -r '.body' <<<"$e")
    repo=$(jq -r --arg R "$REPO_DEFAULT" '.repo // $R' <<<"$e")
    labels=$(jq -r '.labels | join(",")' <<<"$e")
    milestone=$(jq -r '.milestone // empty' <<<"$e")
    assignees=$(jq -r '.assignees // [] | join(",")' <<<"$e")
    adrLinks_csv=$(jq -r '.adrLinks // [] | join(",")' <<<"$e")

    [[ -z "$milestone" ]] && milestone="$(auto_milestone_from_labels "$labels")"
    local body_md; body_md="$(epic_body "$id" "$body" "$adrLinks_csv")"

    local number; number="$(find_issue_by_seed_id "$repo" "$id" || true)"
    if [[ -z "${number:-}" ]]; then
      if (( DRY_RUN == 1 )); then
        summary+="- [EPIC] $id → create in $repo: \"$title\"\n"
      else
        number=$(retry 5 gh issue create -R "$repo" -t "$title" -b "$body_md" -l "$labels" --json number --jq '.number')
        sleep_throttle
        summary+="- [EPIC] $id → created #$number in $repo: \"$title\"\n"
      fi
    else
      if (( DRY_RUN == 1 )); then
        summary+="- [EPIC] $id → update #$number in $repo\n"
      else
        retry 5 gh issue edit "$number" -R "$repo" -t "$title" --body "$body_md" >/dev/null
        sleep_throttle
        summary+="- [EPIC] $id → updated #$number in $repo\n"
      fi
    fi

    [[ -n "${number:-}" ]] && map_set "$id" "$repo" "$number"
    [[ -n "$assignees" ]] && assign_users "$repo" "$number" "$assignees"
    set_milestone "$repo" "$number" "$milestone"
    ids_present+="$id"$'\n'

    # Add to project (optional)
    local url; url=$(issue_url "$repo" "$number")
    add_to_project "$url"
  done < <(jq -c '.epics[]' "$SEED")

  # Stories next
  while IFS= read -r s; do
    local id epicId title labels wu repo ac_lines milestone assignees adrLinks_csv dod_lines
    id=$(jq -r '.id' <<<"$s")
    epicId=$(jq -r '.epicId' <<<"$s")
    title=$(jq -r '.title' <<<"$s")
    labels=$(jq -r '.labels | join(",")' <<<"$s")
    wu=$(jq -r '.wu // empty' <<<"$s")
    repo=$(jq -r --arg R "$REPO_DEFAULT" '.repo // $R' <<<"$s")
    milestone=$(jq -r '.milestone // empty' <<<"$s")
    assignees=$(jq -r '.assignees // [] | join(",")' <<<"$s")
    adrLinks_csv=$(jq -r '.adrLinks // [] | join(",")' <<<"$s")
    dod_lines=$(jq -r '.dod // [] | .[]' <<<"$s" | sed 's/^/- /')

    [[ -z "$milestone" ]] && milestone="$(auto_milestone_from_labels "$labels")"

    # Compose AC markdown bullets
    ac_lines=""
    while IFS= read -r a; do ac_lines+="- $a"$'\n'; done < <(jq -r '.acceptanceCriteria[]' <<<"$s")

    # Parent epic URL
    local epic_repo epic_number epic_url
    epic_repo=$(map_get_repo "$epicId")
    epic_number=$(map_get_number "$epicId")
    if [[ -z "$epic_repo" || -z "$epic_number" ]]; then
      echo "ERROR: Epic $epicId not found in map; ensure epics created first." >&2
      exit 1
    fi
    epic_url=$(issue_url "$epic_repo" "$epic_number")

    local body_md; body_md="$(story_body "$id" "$epic_url" "$wu" "$ac_lines" "$adrLinks_csv" "$dod_lines")"

    local number; number="$(find_issue_by_seed_id "$repo" "$id" || true)"
    if [[ -z "${number:-}" ]]; then
      if (( DRY_RUN == 1 )); then
        summary+="- [STORY] $id → create in $repo: \"$title\"\n"
      else
        # Attempt create in target repo
        if number=$(retry 5 gh issue create -R "$repo" -t "$title" -b "$body_md" -l "$labels" --json number --jq '.number'); then
          sleep_throttle
          summary+="- [STORY] $id → created #$number in $repo: \"$title\"\n"
        else
          if (( TRANSFER_FALLBACK == 1 )); then
            # Create in default repo and mark needs-transfer
            number=$(retry 5 gh issue create -R "$REPO_DEFAULT" -t "$title" -b "$body_md"$'\n\n> NOTE: Needs transfer to '"$repo" -l "$labels,discussion" --json number --jq '.number')
            sleep_throttle
            summary+="- [STORY] $id → created in $REPO_DEFAULT (fallback), needs transfer to $repo\n"
            repo="$REPO_DEFAULT"
          else
            echo "ERROR: Failed to create $id in $repo" >&2
            exit 1
          fi
        fi
      fi
    else
      if (( DRY_RUN == 1 )); then
        summary+="- [STORY] $id → update #$number in $repo\n"
      else
        retry 5 gh issue edit "$number" -R "$repo" -t "$title" --body "$body_md" >/dev/null
        sleep_throttle
        summary+="- [STORY] $id → updated #$number in $repo\n"
      fi
    fi

    [[ -n "${number:-}" ]] && map_set "$id" "$repo" "$number"
    [[ -n "$assignees" ]] && assign_users "$repo" "$number" "$assignees"
    set_milestone "$repo" "$number" "$milestone"
    ids_present+="$id"$'\n'

    # Add to project
    local url; url=$(issue_url "$repo" "$number")
    add_to_project "$url"
  done < <(jq -c '.stories[]' "$SEED")

  # Close missing if requested
  if (( CLOSE_MISSING == 1 )); then
    close_missing "$ids_present"
  fi

  # Summaries
  echo -e "Seed Summary:\n$summary"
  echo -e "summary<<EOF\n$summary\nEOF" >> "$GITHUB_OUTPUT"
  echo -e "### Issue Seed Summary\n\n$summary" >> "$GITHUB_STEP_SUMMARY"
}

main "$@"