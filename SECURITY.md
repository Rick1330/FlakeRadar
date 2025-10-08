# Security Policy

We take security seriously and appreciate responsible disclosure.

Reporting a Vulnerability
- Preferred: Use GitHub “Private vulnerability reporting” on this repository.
- Alternate: Email security@flakeradar.dev [ASSUMPTION] with details and a proof-of-concept if possible.
- Please do not open public issues for security reports.

Our Commitment
- Acknowledge receipt within 3 business days.
- Provide status updates at least weekly until resolution.
- Credit researchers in release notes (optional, with permission).

Scope
- Code in FlakeRadar repositories under github.com/rick1330/*
- Third-party dependencies are out of scope, but we welcome reports that help us remediate.

Handling & Remediation
- Triage severity (CVSS-like: Low/Med/High/Critical).
- Create a private security advisory and mitigation branch.
- Patch, backport if applicable, and release within:
  - Critical: 7 days
  - High: 14 days
  - Medium: 30 days
  - Low: best effort

Best Practices We Follow
- CodeQL weekly; Dependabot enabled
- CSP via next-safe-middleware
- No secrets in repos; .env.example only
- Minimal scopes for GitHub App; per-repo tokens for ingest (hashed at rest)

PGP/Verification
- Not currently publishing a PGP key [ASSUMPTION]. We will sign releases in future (ADR pending).