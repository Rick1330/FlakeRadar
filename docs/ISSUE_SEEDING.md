# Issue Seeding (Production‑grade)

Overview
- Single source of truth: issues/seed.json
- Enforced structure: schemas/issues.seed.schema.json (validated by CI)
- Automation: scripts/seed-issues.sh + .github/workflows/seed-issues.yml
- Multi‑repo: set "repo" per item or default to REPO_DEFAULT
- Safety: DRY_RUN on PRs; apply on main only; rate‑limited; retries
- Governance: standardized label taxonomy + colors; milestones (Gate A–D, Sprint‑xx)

Usage (local)
- Prereqs: gh (CLI), jq, Node 20+, ajv-cli (optional local)
- Dry‑run:
  DRY_RUN=1 bash scripts/seed-issues.sh
- Apply:
  GH_TOKEN=<repo-scoped token> CLOSE_MISSING=1 bash scripts/seed-issues.sh

Key env vars
- REPO_DEFAULT (defaults to current repository where workflow runs)
- DRY_RUN=1 (no writes; prints plan)
- CLOSE_MISSING=1 (closes issues no longer present; adds label "obsolete-by-seed")
- PROJECT_OWNER (defaults to repository owner)
- PROJECT_TITLE="FlakeRadar Roadmap" (or set PROJECT_NUMBER)
- TRANSFER_FALLBACK=1 (if creation in target repo fails, create in REPO_DEFAULT with a note)

Schema highlights (schemas/issues.seed.schema.json)
- epics[].id: "EP-xxx"
- stories[].id: "ST-xxx", .epicId: "EP-xxx"
- Optional fields per item:
  - repo: "owner/name"
  - milestone: "Gate A" | "Gate B" | "Gate C" | "Gate D" | "Sprint-xx"
  - project: { owner, title | number }
  - assignees: ["githubUser"]
  - adrLinks: ["url-or-path"]
  - dod: override default DoD checklist

Bodies & templates (generated)
- Epics: include DoD and ADR links
- Stories: include Parent Epic link, WU mapping, Acceptance Criteria, DoD, ADR links
- Marker: <!-- seed-id: EP-001 --> to keep idempotency (survives transfers)

CI behavior (.github/workflows/seed-issues.yml)
- On PR touching seed/schema/script/workflow:
  - Validate schema
  - Dry‑run and post summary as PR comment
- On main push:
  - Validate schema
  - Apply create/update/close
  - Commit issues/map.json if changed

Security
- Use a repo‑scoped token (GH_TOKEN_SEED) for cross‑repo writes.
- GITHUB_TOKEN is sufficient for program‑repo only operations but cannot access other repos.
- Least privilege: scopes repo + project are sufficient.

Label taxonomy (standard colors)
- good first issue, help wanted, discussion
- gate:A/B/C/D
- persona:dev/qa/sre/em
- module:ingest/scoring/ui/bot/docs
- priority:p1/p2/p3
- obsolete-by-seed

Milestones & Projects
- Milestones auto‑created: Gate A–D. You may specify Sprint‑xx per item; the script will create it if missing.
- Roadmap: items are added to the user/org project PROJECT_TITLE (default: FlakeRadar Roadmap).

Cross‑repo consistency
- Keep seed‑id markers on issue body; transfers preserve them.
- issues/map.json tracks id → { repo, number } and is updated on every apply.

Recent Improvements
- Automatic repository targeting: The workflow now automatically targets the current repository where it runs
- Enhanced error handling: Repository access is validated before operations to prevent "repo not found" errors
- Robust URL parsing: Improved parsing of GitHub issue URLs to reliably extract issue numbers
- Better error messages: Clear, actionable error messages help diagnose issues quickly
- Workflow resilience: Added measures to prevent job failures when PR comments are empty or blocked
- Simplified git operations: Removed custom tokenized URLs in favor of default credentials for simpler configuration