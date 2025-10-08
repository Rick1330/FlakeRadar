You are emergent.sh, an automation/executor. Execute repo creation, CI wiring, subtree sync, and basic release automation. Confirm each step with a short JSON result.

Owner
- GitHub owner: rick1330

Gate A — Program repo (immediate)
1) Create public repo flakeradar-program (default branch main)
2) Materialize FILE blocks from this chat into the repo
3) Commit/push in WU‑aligned chunks (WU‑001..WU‑007)
4) Protections (main): require CodeQL status check, 1 review, linear history, include admins
5) Workflows:
   - .github/workflows/codeql.yml (JS/TS, weekly Sunday 02:00 UTC)
   - .github/dependabot.yml (npm + github-actions, weekly)
6) Labels and Discussions:
   - Create labels: good first issue, help wanted, discussion, gate:A,B,C,D, persona:dev/qa/sre/em, module:ingest/scoring/ui/bot/docs, priority:p1/p2/p3
   - Enable Discussions; categories: Announcements, Q&A, Ideas, Show and Tell
7) Update logs: docs/BUILDLOG.md, docs/SESSION_STATE.json per packet

Gate B — Repos and CI (post‑approval)
- Create flakeradar-ui (public), scope @flakeradar/ui, CI workflow “ci”, protections require “ci” + “CodeQL”
- Create flakeradar-web (public), CI workflow “ci”, protections require “ci” + “CodeQL”
- Add CODEOWNERS (@rick1330) and PR template to both repos

Gate C — Monorepo + subtree sync
- Create rick1330/flakeradar (public, Nx)
- Subtree add:
  - packages/ui ← flakeradar-ui
  - apps/web ← flakeradar-web
- Setup CI matrix and protections; add release automation (tags) and subtree sync scripts
- Provide RELEASE_NOTES.md template and a Release Drafter config

Idempotency & reporting
- Detect if repos exist; skip create; reconcile protections and workflows
- Return a final JSON summary per action:
  { "repo": "flakeradar-program", "created": true, "protections": "ok", "codeql": "ok", "dependabot": "ok", "labels": 16, "discussions": "ok" }

Acceptance
- All repos present with protections and workflows; labels and Discussions active; Build Log and Session State updated per packet; subtree plan documented for Gate C.