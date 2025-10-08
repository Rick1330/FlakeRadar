# Contributing to FlakeRadar

Thanks for your interest in contributing! We aim for a welcoming, transparent, and quality-driven OSS project.

Ground Rules
- Be kind and respectful (see CODE_OF_CONDUCT.md).
- Prefer issues before big PRs; discuss breaking changes in Discussions.
- Keep to our budgets: a11y WCAG 2.2 AA, entry bundle <150KB, CSP/CodeQL/Dependabot, minimal PII.

Quickstart (Docs repo)
- Requirements: Node 20 LTS, pnpm
- Install: pnpm install
- Lint/format: pnpm lint && pnpm format
- Build: This repo is docs-only; edit files and submit PRs. CI checks: markdownlint (planned) and CodeQL.

Contribution Workflow
1) Find or open an issue, label appropriately (good first issue, help wanted, module:*, gate:*, persona:*).
2) Fork and create a feature branch: git checkout -b feat/short-desc
3) Make changes; include tests/docs where relevant.
4) Commit using Conventional Commits and include WU ID if applicable:
   - feat: add X (WU-201)
   - fix: correct Y (WU-104)
   - docs: update Z
5) Push and open a PR. Fill out the PR template checklist.

DCO (Developer Certificate of Origin)
- We require Signed-off-by on commits to certify authorship and license compliance.
- Add a sign-off with: git commit -s -m "feat: add X"
- See https://developercertificate.org/

Issue Triage
- New issues: confirm repro/clarity; add labels; request minimal report samples if ingest-related.
- Prioritization: priority:p1 (gate blocker) → p2 → p3
- Stale: request more info after 7 days; close after 21 days without response.

ADR Process
- For significant decisions (architecture, budgets, governance), create an ADR in adr/ using adr/template.md.
- Include: Context, Options, Decision, Consequences, Status.
- Link ADR in PR description and docs/DECISIONS.md.

Coding Standards (for code repos in later gates)
- TypeScript strict mode; ESLint (typescript, react, jsx-a11y); Prettier.
- Tests: vitest/jest + testing-library; jest-axe for a11y.
- Security: no secrets in repo; .env.example only; CSP via next-safe-middleware.
- Performance: dynamic imports for heavy components; size-limit CI.
- Accessibility: semantic HTML, focus management, keyboard nav, color contrast.

Community
- Discussions enabled: Announcements, Q&A, Ideas, Show and Tell.
- “Good first issue” curated; mentors welcome. Add reproduction samples when possible.

Maintainers
- CODEOWNERS controls reviews; default @rick1330.
- SLA (best-effort): initial response to PRs/issues within 5 business days.