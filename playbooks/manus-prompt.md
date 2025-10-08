You are Manus, a research copilot. Task: Produce an evidence-backed Research Brief v1.1 for the OSS project “FlakeRadar” (CI‑native flaky test detection and remediation).

Context (must read)
- Project: FlakeRadar — OSS core; future hosted/enterprise add‑ons
- Personas: Eng managers, QA/SET, SRE, developers
- Stack prefs: TypeScript, Next.js/Node, Postgres, GitHub Actions
- Non-functional budgets: a11y WCAG 2.2 AA; entry bundle <150KB gzipped; CSP + CodeQL + Dependabot; minimal PII; opt‑in telemetry

Research objectives (deliver all)
1) Devtools and CI landscape
   - CI providers: GitHub Actions, CircleCI, Jenkins, GitLab CI, Buildkite, Azure DevOps
   - Test frameworks: Jest, PyTest, JUnit, Mocha, Gradle, Maven, NUnit
   - Existing flaky test tools/benchmarks: BuildPulse, Datadog CI Visibility, Gradle Test Retry, Jenkins Flaky Test Handler, Launchable, Azure Test Insights, Google FlakyBot (if public), others
   - Typical JUnit/Jest/PyTest report shapes and edge cases (retries, parameterized tests, sharding)
2) Signal quality and heuristics
   - Best-practice heuristics for flake detection; limitations; handling retries/reruns
   - Recency weighting, volatility, streaks; framework-specific gotchas
3) OSS governance norms
   - Maintainer models, lazy consensus, CODEOWNERS, release cadence, semantic versioning
   - Good-first-issue curation and Discussions usage patterns
   - Contributor license options (DCO vs CLA) and when to prefer each
4) Privacy/telemetry norms in OSS
   - Minimal PII expectations; opt-in telemetry patterns; consent UX
   - GDPR/DPA considerations for any hosted component; typical retention defaults
5) Procurement/Adoption friction (for future hosted)
   - Requirements checklists (SOC 2, DPA, SSO/SCIM, data residency); pricing/tier patterns

Output format (Markdown)
- Title: FlakeRadar Research Brief v1.1 (with date)
- Executive Summary (bulleted)
- Findings (with headings for each objective), include citations [#] after claims and a References section with links
- Competitive matrix (columns: Product, Target, Ingest, Scoring method, PR/Bot, Pricing, OSS?)
- Recommendations (actionable), prioritized High/Med/Low
- Implications for docs to revise: list precise edits in docs/01-charter.md, docs/03-architecture-brief.md, docs/06-compliance-brief.md
- Open questions

Constraints
- Cite credible sources with working links; avoid paywalled content when possible.
- Be specific: include API field names, report examples, and failure modes where relevant.

Deliverable
- Paste the brief in this chat; we will copy it into docs and create ADRs as needed.