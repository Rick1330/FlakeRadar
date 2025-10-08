You are mgx.dev, a product PRD generator. Task: Produce PRD v1.0 for “FlakeRadar” (OSS, CI‑native flaky test detection and remediation).

Context
- Goal: Useful OSS devtool that detects flaky tests from CI results, scores them over time, comments on PRs, and provides dashboards/playbooks.
- Personas: Eng managers, QA/SET, SRE, developers
- Timeline: 12-week internal pilot (Gate A‑C), 20-week limited production (Gate D)
- Architecture: Next.js web + API routes, TS parser/scorer, Postgres, minimal GitHub App
- Budgets: a11y WCAG 2.2 AA; entry bundle <150KB; CSP+CodeQL+Dependabot; minimal PII; opt‑in telemetry

PRD structure (produce all sections)
1) Problem statement + background (with context on CI fragmentation and flake impact)
2) Goals/Non‑Goals
3) Personas & jobs-to-be-done (JTBD)
4) OKRs (Gate A → D)
5) Requirements (MVP scope) with Acceptance Criteria (AC) per user story
   - Ingest (GitHub Actions/JUnit/Jest/PyTest)
   - Scoring heuristics (volatility, recency, streaks)
   - PR Bot (comment + label; idempotent)
   - Dashboards (health trends, flaky list, owner hints)
   - Playbooks (suggested fixes + links to commits)
6) Non‑functional requirements (A11y/Perf/Security/Privacy budgets)
7) Data model overview (Repo, TestCase, TestRun, FlakeScore, OwnerMap)
8) Telemetry & privacy (opt‑in UX, data fields if enabled, retention defaults)
9) Rollout plan (Gates; success metrics; feature flags)
10) Risks & mitigations
11) Competitive landscape (short)
12) Open questions & dependencies

Output format
- Markdown, with a numbered backlog table of user stories (ID, Persona, Story, AC, Priority, Gate).
- Map each story to Gate B/C/D and to module labels (ingest/scoring/ui/bot/docs).
- End with “Issue Seeds” as a JSON block ready to merge into issues/seed.json (epics/stories with labels).

Constraints
- Acceptance Criteria must be testable (e.g., “p95 ingest < 2s for 5MB”).
- Use our budgets as hard gates; propose ADRs if budgets need to change.

Deliverable
- Paste PRD v1.0 here; we will commit it into docs and seed issues accordingly.