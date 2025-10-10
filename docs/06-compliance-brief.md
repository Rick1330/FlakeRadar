# Compliance &amp; Privacy Brief — FlakeRadar v1.1 (OSS)

Scope
- OSS core; no central data collection by default. If hosted later, FlakeRadar acts as a data processor under a DPA with customers. This brief sets privacy-by-design defaults and security practices for both OSS and hosted contexts.

Principles
- Data minimization: collect only what's necessary to compute flake scores and display trends.
- Opt-in telemetry: disabled by default for OSS; explicit consent required to enable.
- Transparency: publish schemas for stored data and (if enabled) telemetry events.
- User control: repo-scoped deletion and retention controls; easy opt-out.

Data Inventory (MVP)
- Required: repo identifier (owner/name), commit SHA, branch, test case identifiers (path/name/framework), status (pass/fail/skip), duration, timestamps, rerun count.
- Optional: failure reasons (short text), GitHub login for ownership hints (no emails).
- Never store by default: emails, real names, full stack traces, access tokens, IP addresses (beyond transient logs).
- Tokens: ingest tokens stored as salted hash; display last4 only.

Retention Defaults (Updated v1.1)
| Entity | Default Retention | Configurable Range | Purge Trigger |
|--------|------------------|-------------------|---------------|
| TestRun | 30 days | 7-365 days | Automated + manual |
| FlakeScore | 180 days | 90-730 days | Rolling updates |
| Telemetry Events | 30 days | Fixed | Automated |
| Aggregate Metrics | 2 years | 1-5 years | Manual only |
| Application Logs | 14 days | 7-30 days | Automated |

Data Subject &amp; Admin Controls
- Delete repo data: DELETE /api/repos/:id → cascade delete (Repo → TestCase → TestRun → FlakeScore).
- Export: future endpoint for CSV export of FlakeScore/TestRun (hosted).
- Access: for hosted service, admin-only UI to rotate tokens and purge data.

Telemetry Policy v1.1 (OSS)
- Default: telemetry.disabled = true
- Enabling: toggle via env FRA_TELEMETRY_ENABLED=true; show consent banner and link to privacy doc.
- Event Schema (structured):
  ```json
  {
    "ui.page_view": {
      "route": "/dashboard",
      "timestamp": "2025-10-10T10:00:00Z",
      "session_id": "hashed_session"
    },
    "ingest.completed": {
      "framework": "junit",
      "test_count": 150,
      "payload_size_kb": 45,
      "processing_time_ms": 850,
      "repo_id_hash": "sha256_hash"
    },
    "scoring.candidates": {
      "total_tests": 150,
      "flaky_count": 3,
      "avg_score": 25.4,
      "framework": "junit"
    }
  }
  ```
- DNT Handling: if Do-Not-Track header is present, skip all telemetry collection regardless of FRA_TELEMETRY_ENABLED setting.
- PII Scrubbing: hash all identifiers; never collect emails, real names, or IP addresses.

Security Controls
- Transport: HTTPS/TLS 1.2+
- At rest: Postgres encryption (managed provider); secrets in env only; never in repo
- CSP: next-safe-middleware with strict defaults
- Auth: per-repo ingest tokens (Bearer + HMAC); GitHub App with minimal scopes
- Logging: scrub headers (Authorization, cookies); limit query logging in production

License Scanning Policy
- Allowlist: Apache-2.0, MIT, BSD-2/3, ISC, CC0 (non-code assets)
- Restricted (runtime): GPL, AGPL, SSPL (OK for dev tools only if not bundled in runtime)
- Enforce via GitHub dependency-review-action; require PR approval for any restricted license

Contributor Licensing (DCO vs CLA)
- Recommendation: adopt DCO (Developer Certificate of Origin) for all code/documentation contributions; require Signed-off-by in commits. CLA not required initially to reduce friction.
- Revisit CLA if corporate adoption demands additional IP assurances (ADR to be added if changed).

GDPR &amp; Roles (hosted later)
- Controller: customer (repo owner)
- Processor: FlakeRadar hosted service
- Actions: provide DPA; enable data export/deletion; maintain records of processing; perform DPIA if telemetry expands
- Subprocessors: disclose list (e.g., DB provider, hosting) in hosted docs; none for OSS self-host

Secrets &amp; MFA
- Use GitHub fine-grained tokens; require MFA for maintainers; prefer GitHub App over PAT
- Rotate keys every 90 days; document rotation procedure

Incident Response (hosted)
- Detect: alerts on unusual spikes, failed auth attempts
- Respond: acknowledge within 72 hours; status page and postmortem within 7 days
- Coordinate via SECURITY.md channels

Audits &amp; Roadmap
- SOC 2: not applicable for OSS; target readiness 6–9 months post hosted GA
- Code scanning: CodeQL weekly; dependency updates via Dependabot
- Privacy review: gate changes affecting data/telemetry behind ADR + review

Change Control
- Any change to budgets (a11y/perf/security/privacy) requires updated docs and an ADR; note in RELEASE_NOTES.