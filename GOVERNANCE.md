# Governance — FlakeRadar OSS

Model
- Maintainer-led with lazy consensus. Anyone may propose changes via PRs or Discussions. Maintainers merge after review.

Roles
- Maintainers: @rick1330 (founding). Additional maintainers added via PR and recorded here.
- Contributors: anyone submitting issues/PRs, participating in Discussions.
- Reviewers: maintainers or delegated community members with review rights.

Decision Making
- Trivial/low risk: standard PR + single maintainer approval.
- Significant changes (architecture, budgets, licensing, telemetry): require an ADR and at least 2 maintainer approvals (when >1 maintainer).
- Disagreements: discuss in ADR/Discussion; escalate to a maintainer vote.

Releases
- Semantic Versioning (semver). Tags vMAJOR.MINOR.PATCH.
- Release cadence: as-needed; aim monthly minor releases post Gate C.
- Process: changelog via Conventional Commits; Release Drafter (later); signed tags (planned).

Roadmap & Community
- Roadmap tracked in Discussions + issues; milestones per gates (A–D).
- Labels: good first issue, help wanted, discussion, gate:*, persona:*, module:*, priority:p*.
- Community calls/updates (optional): post announcements in Discussions.

Security & Compliance
- Security: see SECURITY.md; private advisories; minimal scopes for GitHub App.
- Compliance: privacy-by-design; opt-in telemetry; DCO for contributions.

Code Ownership
- CODEOWNERS governs required reviews. Default: @rick1330.

Amendments
- Propose governance changes via PR + ADR; require maintainer approval.