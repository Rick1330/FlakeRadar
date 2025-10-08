# Risk Register — FlakeRadar (Program)

Purpose
- Track program and product risks with owners, mitigations, and status. Update per gate; add/remove items via PRs.

Legend
- Likelihood (L): Low/Med/High
- Impact (I): Low/Med/High
- Status: Open / Mitigating / Closed
- Owner: @rick1330 unless otherwise noted

R-001 • Signal quality (false pos/neg across frameworks)
- L: Med • I: High • Status: Mitigating
- Description: Heuristics may misclassify unstable vs truly flaky tests.
- Mitigations:
  - Windowed scoring with volatility + recency + clustering; thresholds configurable per repo
  - Evaluation suite using public sample reports (Jest, PyTest, JUnit); golden tests
  - “Explain score” UI and allow user suppression/overrides
- Triggers/Metrics: Disputed flags > 5% of flagged tests; user feedback

R-002 • Multi-language/framework variability
- L: Med • I: Med • Status: Open
- Description: Report formats and retry semantics differ (parametrized tests, shards).
- Mitigations: Adapter contracts; conformance tests; property-based tests for parsers; keep raw identifiers stable

R-003 • PR bot spam or rate limits
- L: Med • I: Med • Status: Mitigating
- Description: Excessive comments/labels; GitHub secondary rate limits.
- Mitigations: Single idempotent comment with hidden marker; ≤10 writes/min/repo; exponential backoff; label only on change

R-004 • Ingestion performance
- L: Med • I: High • Status: Mitigating
- Description: Large XML/JSON reports cause timeouts or memory pressure.
- Mitigations: Streaming parser; 5MB limit; p95 ingest < 2s budget; switch to queue (BullMQ) if needed

R-005 • Data privacy and PII leakage
- L: Low • I: High • Status: Mitigating
- Description: Names/emails/stack traces may include personal data.
- Mitigations: Minimal PII (no emails); hash author names if used; redact stack traces by default; documented deletion API

R-006 • Token leakage / auth misuse
- L: Low • I: High • Status: Mitigating
- Description: Ingest tokens or GitHub App secrets leaked in logs/commits.
- Mitigations: .env.example only; never log secrets; store token hashes (salted) + last4; rotation flow; HMAC on ingest

R-007 • OSS sustainability (bus factor)
- L: Med • I: Med • Status: Open
- Description: Single maintainer workload; backlog grows; slow reviews.
- Mitigations: Good-first-issues; CODEOWNERS; maintainer guide; automation (labeler); monthly maintainer sync; recruit co-maintainers post Gate C

R-008 • A11y/perf budgets not met
- L: Med • I: Med • Status: Mitigating
- Description: UI components/pages exceed budgets.
- Mitigations: jest-axe gate to zero violations; size-limit CI; dynamic import for charts; ADR if budget change required

R-009 • DB growth / retention
- L: Med • I: Med • Status: Mitigating
- Description: TestRun rows grow quickly; query performance degrades.
- Mitigations: 30-day retention default; indices; background VACUUM; aggregates in FlakeScore; purge per repo

R-010 • Dependency/licensing risk
- L: Med • I: Med • Status: Mitigating
- Description: Pulling GPL/AGPL libs inadvertently; legal friction for adopters.
- Mitigations: dependency-review-action; allowlist (Apache/MIT/BSD); vet transitive deps; ADR for exceptions

R-011 • Scope creep vs thin E2E
- L: High • I: Med • Status: Mitigating
- Description: Temptation to add features before demo flow is solid.
- Mitigations: Gate-aligned roadmap; “thin slice” principle; defer to Gate D; use ADRs to guard scope

R-012 • Telemetry trust concerns
- L: Low • I: Med • Status: Mitigating
- Description: Community pushback if telemetry defaults are invasive.
- Mitigations: Opt-in only; clear disclosure; easy disable; publish event schema

R-013 • GitHub API changes/quotas
- L: Low • I: Med • Status: Open
- Description: Octokit permissions/quotas evolve; webhooks behavior changes.
- Mitigations: Use minimal scopes; feature flag PR bot; backoff; pin octokit versions

R-014 • Security vulnerabilities (supply chain)
- L: Med • I: High • Status: Mitigating
- Description: Vulnerable dependency or misconfig.
- Mitigations: Dependabot weekly; CodeQL weekly; CSP strict; SAST in CI; release notes with CVE mentions when relevant

R-015 • Misattribution of ownership
- L: Low • I: Low • Status: Open
- Description: Incorrect owner mapping causes churn.
- Mitigations: Prefer teams (CODEOWNERS) vs individuals; manual overrides; show confidence

R-016 • Legal/process (DCO/CLA friction)
- L: Low • I: Low • Status: Open
- Description: Contribution legal friction slows PRs.
- Mitigations: Recommend DCO; avoid CLA initially; revisit if large corporate contributions surge

R-017 • Hosting/ops cost (future hosted)
- L: Low • I: Med • Status: Open
- Description: If hosting later, cost creep for storage/egress.
- Mitigations: Retention; compression; budgets; per‑repo quotas; pricing strategy

Add/Update Process
- Propose changes via PR. Include: risk id, description, L/I, owner, mitigation, status. Link to related ADRs/issues.