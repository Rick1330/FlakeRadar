# FlakeRadar — Architecture Brief v1.1 (Gate A)

Status
- Version: 1.1 (updated post-research for framework-specific parameters)
- Owners: @rick1330 (maintainer); Orchestrator (this program)
- Scope: OSS MVP (Next.js + Node, Postgres, minimal GitHub App)

1) Purpose
- Define the system context, containers, ingestion design, data model, flake scoring, PR bot flow, and quality budgets for the OSS MVP.
- Optimize for a thin, demonstrable E2E in Gate C: ingest → score → PR comment/label.
- Enforce non‑functional budgets: a11y, performance, security, privacy.

2) C4 Model — Level 1 (System Context)
    +-------------------+            +------------------------+
    |   Engineers       |            |     GitHub Platform    |
    | (Dev/QA/SRE/EM)   |<---------->|  PRs, Checks, Comments |
    +---------+---------+            +-----------+------------+
              ^                                   ^
              | Web UI (browser)                  | GitHub App API / Webhooks
              |                                   |
              |                     +-------------+-------------+
              |                     |        FlakeRadar         |
              |                     |       (The System)        |
              |                     +-------------+-------------+
              |                                   |
              v                                   v
    +-------------------+            +------------------------+
    |  CI Providers     |            |  Slack / Webhooks      |
    | GitHub Actions    |----------->|  (optional alerts)     |
    | (JUnit/Jest/PyTest|  Ingest    +------------------------+
    |   results)        |
    +-------------------+

3) C4 Model — Level 2 (Containers)
    +---------------------------------------------------------------+
    |                      FlakeRadar System                        |
    |                                                               |
    |  +-----------------+     +--------------------+               |
    |  |  Web UI         | SSR |  API/BFF           |  REST +       |
    |  |  (Next.js)      |<--->|  (Next.js API Rts) |  Webhooks     |
    |  +--------+--------+     +---------+----------+               |
    |           |                        |                          |
    |           |                        | parse/score              |
    |           v                        v                          |
    |  +-----------------+      +--------------------+              |
    |  | Parser/Scorer   |      |   Postgres DB      |              |
    |  | (TS library)    |      | (Relational store) |              |
    |  +-----------------+      +---------+----------+              |
    |                                      ^                        |
    |                                      |                        |
    |                        +-------------+------------+           |
    |                        |   PR Bot (GitHub App)    |           |
    |                        | (Minimal permissions)    |           |
    |                        +-------------+------------+           |
    |                                      |                        |
    |                           Comments/Labels via API             |
    +---------------------------------------------------------------+

External:
- GitHub Actions → POST /api/ingest (recommended mode for MVP).
- Slack/Webhooks: optional outbound notifications.

4) C4 Model — Level 3 (Key Components)
- API/BFF (Next.js API routes)
  - IngestController: validates auth, parses payload, persists runs, triggers scoring, enqueues PR bot.
  - QueryController: paginated queries for flaky tests, trends, repo health.
- Parser/Scorer (TypeScript lib)
  - Adapters: junit, jest, pytest (Gate D to add mocha/gradle).
  - Scoring: rolling window, volatility, recency weighting, clustering, classification.
- PR Bot (GitHub App)
  - PRLookup: find open PR(s) by commit SHA.
  - Commenter: idempotent update with hidden marker; add/remove "flaky-tests" label.
- Data Access
  - Repositories for Repo, TestCase, TestRun, FlakeScore, OwnerMap with input validation and SQL params.
- Notifications (optional)
  - Slack/Webhooks publisher (rate‑limited; disabled by default in OSS).

5) Ingestion Design (GitHub Actions → FlakeRadar)
- Recommended mode: Direct POST from CI to FlakeRadar's /api/ingest.
- Authentication
  - Per‑repo token (random, 32+ chars) created in FlakeRadar UI and stored as a GitHub Actions secret.
  - HMAC signature header X-FR-Sig = HMAC-SHA256(body, repo_secret) for tamper check.
- Request shape (multipart or JSON)
  - Headers: Authorization: Bearer <repo_token>; X-FR-Sig: <hmac>; X-FR-Framework: <framework>; X-FR-Rerun-Count: <count>
  - Fields:
    - repo_full_name (e.g., owner/repo), commit_sha, branch, run_id, workflow_name, created_at
    - framework: junit|jest|pytest
    - rerun_count: number of times this test run was retried (default: 0)
    - report[]: one or more JUnit XML files or JSON summaries
- Example GitHub Action step
      - name: Upload test report to FlakeRadar
        run: |
          curl -sS -X POST "$FRA_URL/api/ingest" \
            -H "Authorization: Bearer $FRA_TOKEN" \
            -H "X-FR-Framework: junit" \
            -H "X-FR-Rerun-Count: ${RERUN_COUNT:-0}" \
            -H "Content-Type: multipart/form-data" \
            -F repo_full_name=$ github.repository  \
            -F commit_sha=$ github.sha  \
            -F branch=$ github.ref_name  \
            -F run_id=$ github.run_id  \
            -F framework=junit \
            -F report=@junit.xml
        env:
          FRA_URL: https://flakeradar.dev
          FRA_TOKEN: $ secrets.FLAKERADAR_TOKEN 
- Ingest steps
  1) AuthN/AuthZ: validate token → repo; verify HMAC; rate limit by repo+IP.
  2) Parse: detect format; streaming parse to normalized TestRun/TestCase records.
  3) Persist: upsert Repo, ensure TestCase exists; insert TestRun rows; compute aggregates.
  4) Score: update rolling FlakeScore for affected tests with framework-specific parameters.
  5) Notify: if commit belongs to an open PR, enqueue PR Bot job (idempotent); optionally Slack/webhook.
- Limits &amp; budgets
  - Max payload: 5 MB; up to 50k testcases per run (streaming parser).
  - Ingest p95 < 2s for 5 MB; avoid synchronous external calls.
  - Rate limits: 100 requests/hour per repo token; ≤10 PR bot writes/min per repo.
  - Dedup: idempotency by (repo_id, commit_sha, run_id).

6) API Catalog (MVP)
- POST /api/ingest → { accepted, runId, stats } (private; token‑gated)
- GET /api/repos/:id/tests?flaky=true&amp;limit=50&amp;cursor=… (paginated)
- GET /api/repos/:id/flake-trends?from=…&amp;to=…
- POST /api/pr/:number/comment (internal; PR Bot only)
- POST /api/repos/:id/owners/refresh (Gate D; imports CODEOWNERS)
- DELETE /api/repos/:id (data deletion; owner‑only)

7) Storage Model (Postgres)
- Principles
  - Normalize test metadata; store minimal data needed for scoring and trends.
  - Do not store raw logs by default; capture summarized failure reasons as small text or enum.
- ER Outline
        +---------+        1      *     +----------+      1       *     +-----------+
        |  Repo   |--------------------->| TestCase |-------------------->| TestRun   |
        +---------+                      +----------+                      +-----------+
        | id (pk) |                      | id (pk)  |                      | id (pk)   |
        | gh_id   |                      | repo_id  |                      | test_case_id |
        | name    |                      | path     |                      | commit_sha  |
        | owner   |                      | name     |                      | status (pass|fail|skip) |
        | default_branch|                | framework|                      | duration_ms |
        | visibility   |                 | tags[]   |                      | started_at  |
        | created_at   |                 | created_at|                     | rerun_count |
        +---------+                      +----------+                      | created_at  |
                                              |                            +-----------+
                                              | 1      1
                                              v
                                        +-------------+
                                        | FlakeScore  |
                                        +-------------+
                                        | id (pk)     |
                                        | test_case_id|
                                        | window_n    |
                                        | pass_rate   |
                                        | volatility  |
                                        | recency_fail|
                                        | clustering  |
                                        | score (0-100)|
                                        | class       |
                                        | updated_at  |
                                        +-------------+

        +-----------+      *       1
        | OwnerMap  |<-------------------- Repo
        +-----------+
        | id (pk)   |
        | repo_id   |
        | pattern   |  (glob path pattern)
        | owner     |  (team or GH login)
        | source    |  (CODEOWNERS|manual)
        | created_at|
        +-----------+
- Keys &amp; indexes
  - TestCase unique (repo_id, path, name, framework)
  - TestRun index (repo_id, started_at desc), index (test_case_id, started_at desc)
  - FlakeScore unique (test_case_id), partial index WHERE score >= 60
  - OwnerMap index (repo_id, pattern)
- Retention
  - TestRun rows: 30 days by default; aggregates (FlakeScore) kept rolling; repo‑scoped purge supported.

8) Flake Scoring Heuristics v1.1
- Framework-Specific Windows
  - Jest: N = min(30, all runs) - rapid feedback for frontend tests
  - JUnit: N = min(50, all runs) - enterprise stability requirements  
  - PyTest: N = min(40, all runs) - scientific computing balance
  - Configurable per repository via /api/repos/:id/config
- Inputs (window N)
  - f[i] ∈ {0,1} for fail/pass (1 = fail)
  - toggles = number of transitions between pass and fail
  - recency weights w[i] = exp(-λ*(N-i)), λ = ln(2)/7 (half‑life = 7 runs)
  - longest_fail_streak, longest_pass_streak
- Metrics
  - pass_rate = 1 - (Σ f[i] / N)
  - volatility = toggles / max(1, N-1)
  - recency_fail = (Σ f[i]*w[i]) / (Σ w[i])
  - clustering = (# of failure events in streaks >= 2) / N
- Score (0–100)
  - F = 100 * clamp01( 0.25*(1 - pass_rate) + 0.35*volatility + 0.30*recency_fail + 0.10*clustering )
- Classification
  - flaky if: pass_rate ∈ [0.60, 0.98] AND volatility ≥ 0.20 AND toggles ≥ 2 in last 10 runs
  - persistent-fail if: pass_rate < 0.60 AND longest_fail_streak ≥ 3 (not flaky; separate handling)
- Reruns
  - Count initial failures even if rerun passed; weight rerun‑induced failures at 0.5 (configurable per repo).
  - Use X-FR-Rerun-Count header to track rerun attempts.
- Defaults
  - Action threshold: F ≥ 60 → quarantine candidate (configurable per repo).

9) PR Quarantine Bot (GitHub App)
- Permissions
  - metadata:read, contents:read, pull_requests:write, checks:write
- Flow (sequence)
      [Ingest Complete] 
          → find open PR(s) for commit SHA
          → compute delta (new/changed flaky tests on branch)
          → upsert PR comment (idempotent via <!-- flakeradar:pr-comment:v1 --> marker)
          → add label "flaky-tests" if any candidates
          → optionally set a commit check summary
- Rate limits &amp; safety
  - ≤ 10 writes/min/repo; exponential backoff on secondary rate limit.
  - Never spam: single comment per PR updated in place.
  - Failure handling: log + retry up to 3 times; drop on persistent 4xx.

10) A11y/Perf/Security/Privacy Budgets (applied)
- Accessibility
  - UI components tested with jest‑axe; zero violations on "Flake Dashboard" and "Ingest Config".
- Performance
  - Web entry bundle < 150KB gzipped; charts loaded via dynamic import; SSR for core views.
  - API: GET p95 < 150ms; POST /api/ingest p95 < 2s for 5 MB.
- Security
  - CSP via next-safe-middleware; strict defaults with nonces.
  - Secrets only via env; provide .env.example; token hashes stored (salted), show last4 only.
  - CodeQL weekly; Dependabot; protected main (require "ci" + CodeQL, 1 review, linear history).
- Privacy
  - Minimal PII: store GitHub logins only; no emails; hash author names if used.
  - Redact stack traces by default; test names/paths are safe. Opt‑in for verbose logs.
  - Data deletion: owner can purge a repo; cascade delete via FK.

11) De‑Identification Guidance
- Strip emails and real names from ingestion; store only GitHub login or hashed identifiers.
- Truncate commit SHAs to 12 chars for UI; store full SHA in DB if needed for linkage.
- Prefer team ownership via OwnerMap/CODEOWNERS over individual attribution in UI.

12) Configuration &amp; Secrets
- Required env (server)
  - DATABASE_URL (Postgres), SESSION_SECRET, APP_BASE_URL
  - GITHUB_APP_ID, GITHUB_APP_PRIVATE_KEY, GITHUB_APP_INSTALLATION_ID (for PR Bot) or PAT fallback for dev
- Repository tokens
  - Generate per‑repo ingest token; persist as salted hash; display last4. Rotate on demand.
- Feature flags
  - telemetry.enabled (default false in OSS), slack.enabled, alerts.threshold

13) Operational Metrics (MVP)
- Ingest: count, p95 latency, parse failures
- Scoring: time per 1k tests, number of flaky candidates
- PR Bot: comment/update success rate, rate‑limit hits
- UI: CWV (LCP/FID/CLS), bundle size check

14) Local Dev &amp; Testing
- Local: Next.js dev server; Postgres via Docker; seed script with sample JUnit/Jest/PyTest reports.
- Tests: unit tests for parsers/scoring; integration test for /api/ingest; contract test for PR comment upsert (mock GitHub).
- a11y: jest‑axe on core pages; budgets enforced in CI.

15) Extensibility Roadmap
- Adapters: mocha, gradle (Gate D)
- Queue: BullMQ/Redis if ingest latency breaches budget
- Object storage: S3‑compatible for raw artifacts (7‑day TTL) if needed
- OwnerMap enrichment: pull CODEOWNERS and directory ownership heuristics

16) Open Questions (to be resolved via ADRs/PRD)
- Exact framework-specific thresholds and rerun weighting strategies (ADR-0014, ADR-0015).
- PAT fallback vs GitHub App‑only for MVP PR Bot (ADR-0016).
- Retention defaults for TestRun beyond 30 days (ADR-0017).
- Telemetry event schema and opt-in strategy (ADR-0018).

Appendix A — Table Sketches (DDL‑ish, indicative)
- TestCase
  - id pk, repo_id fk, path text, name text, framework text, tags text[], created_at timestamptz
  - unique (repo_id, path, name, framework)
- TestRun
  - id pk, test_case_id fk, repo_id fk, commit_sha text, status enum(pass|fail|skip), duration_ms int, started_at timestamptz, rerun_count int default 0, created_at timestamptz, failure_reasons text[]
  - index (repo_id, started_at desc); index (test_case_id, started_at desc)
- FlakeScore
  - id pk, test_case_id fk unique, window_n int, pass_rate float, volatility float, recency_fail float, clustering float, score int, class text, updated_at timestamptz
  - partial index (score) where score >= 60
- OwnerMap
  - id pk, repo_id fk, pattern text, owner text, source enum(CODEOWNERS|manual), created_at timestamptz
  - index (repo_id, pattern)
- Repo
  - id pk, gh_id bigint, name text, owner text, default_branch text, visibility enum(public|private), created_at timestamptz

Assumptions
- Hosting: dev DB via Neon/Supabase; production choice deferred (ADR later).
- Tokens: per‑repo tokens stored as salted hashes; HMAC required on ingest.
- Limits: 5 MB ingest payload; framework-specific scoring windows; action threshold F≥60.
- PR Bot: GitHub App minimal permissions; PAT fallback allowed for demo only.