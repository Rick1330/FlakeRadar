# Tool Playbook — Gate A → D

Purpose
- Provide exact prompts and setup steps for research, PRD, scaffolding, and execution automation.
- Ensure resume‑safe delivery (commit per WU), with a11y/perf/security/privacy budgets enforced.

How to use this playbook
- Run tools in this order for Gate A: Manus → mgx.dev → (revise docs/01,03,06) → prepare issues → approve Gate A.
- Prompts live in playbooks/*.md (copy exact text). Executors (Qoder/Cursor or emergent.sh) run repo actions.

Tool Run Order and Outputs (Gate A)
1) Manus (research): devtools market scan, CI provider landscape, OSS governance best practices, telemetry privacy norms.
   - Output: Research Brief v1.1 with citations. Action: update docs/01‑charter.md, docs/03‑architecture-brief.md, docs/06‑compliance-brief.md; raise ADRs as needed.
2) mgx.dev (PRD): PRD v1.0 (OKRs, user stories/AC, roadmap, risks).
   - Output: PRD.md (in docs/) and issue seeds; align docs/02‑execution‑plan.md.
3) Executors (Qoder/Cursor or emergent.sh): create repos, commit files, set protections, enable CodeQL/Dependabot, seed issues.
   - Output: repos created; workflows enabled; labels and Discussions set; Build Log updated.

GitHub Setup Baseline (apply to all repos)
- Branch protections (main):
  - Require status checks: “ci” and “CodeQL” (code scanning results)
  - Require 1 review; dismiss stale approvals on new commits
  - Require linear history; restrict force‑pushes; include admins
- Security automation:
  - Enable Dependabot (security + version updates)
  - Enable CodeQL code scanning with a weekly schedule (Sunday 02:00 UTC)
- Labels to create:
  - “good first issue”, “help wanted”, “discussion”, “gate:A/B/C/D”, “persona:dev/qa/sre/em”, “module:ingest/scoring/ui/bot/docs”, “priority:p1/p2/p3”
- Community:
  - Enable Discussions; set categories: Announcements, Q&A, Ideas, Show and Tell
  - Default CODEOWNERS to @rick1330 (added in Packet 6)
- Privacy/Security defaults:
  - No secrets in repos; use .env.example only
  - For ingest tokens: store salted hashes; display last4 only [design note for code repos]

Included prompts (copy from playbooks/)
- Manus: playbooks/manus-prompt.md
- mgx.dev: playbooks/mgx-prompt.md
- Lindy: playbooks/lindy-ui-prompt.md
- Qoder/Cursor: playbooks/qoder-executor-prompt.md
- emergent.sh: playbooks/emergent-executor-prompt.md

Acceptance criteria per tool run
- Manus delivers cited findings and concrete recommendations; we revise docs and/or raise ADRs.
- mgx.dev delivers a PRD with testable AC; stories map to WUs; risks/assumptions are explicit.
- Executors produce auditable commits, enabled protections, labels, and Discussion settings; Build Log and Session State updated.

Notes
- If any tool is unavailable, proceed with [ASSUMPTION] and document deltas in ADRs and the Build Log.