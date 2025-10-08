# Execution Plan (Resume‑Safe) — Gate A → D

Overview
- Cadence: 15–45 min Work Units (WUs). Each WU ends with commit + push, Build Log update, ADR if a decision, and session state update.
- Gates
  - Gate A (Weeks 1–2): Discovery + PRD (docs only)
  - Gate B (Weeks 3–8): UI library v0.1.0 + Web app Option A (CI green; a11y/perf budgets)
  - Gate C (Weeks 9–12): Monorepo + BFF/services + thin E2E (ingest → score → quarantine PR comment)
  - Gate D (Weeks 13–16): Community launch (CLI, docs site, good‑first‑issues), more CI/framework integrations

Work Units (WUs) Map

Gate A (Docs only)
- WU‑001 Init program repo skeleton — DONE
  - Artifacts: README, LICENSE, .gitignore, Build Log, ADR index, Session State
- WU‑002 Program Charter — DONE
  - Artifacts: docs/01-charter.md
- WU‑003 Execution Plan (this doc)
  - Artifacts: docs/02-execution-plan.md
- WU‑004 Architecture Brief v0.1
  - Artifacts: docs/03-architecture-brief.md; ER outlines; budgets reiterated
- WU‑005 Tool Playbook (prompts)
  - Artifacts: docs/04-tool-playbook.md; playbooks/* (Manus, mgx.dev, Lindy, Qoder, emergent)
- WU‑006 Risks, Compliance, Governance set
  - Artifacts: docs/05-risk-register.md; docs/06-compliance-brief.md; CONTRIBUTING.md; CODE_OF_CONDUCT.md; SECURITY.md; GOVERNANCE.md; CODEOWNERS; PR template
- WU‑007 Issues + Handoff + Exec Summary
  - Artifacts: .github/ISSUE_TEMPLATE/*; issues/seed.json; docs/SESSION_HANDOFF.md; Exec Summary; Next‑Actions

Gate B (UI + Web Option A; CI green; budgets)
- WU‑101 Create @flakeradar/ui repo (Vite + Tailwind + shadcn/ui); publish private preview to GitHub Packages
  - Artifacts: repo scaffold, Storybook, jest‑axe baseline, bundle budget check
- WU‑102 Core a11y‑first components (Button, Input, Select, Tabs, Table, Alert, Dialog)
  - Artifacts: components + stories + a11y tests + zero‑violation gate
- WU‑103 Next.js app Option A scaffold (SSR; route‑level code split; next‑safe‑middleware CSP)
  - Artifacts: Home, Ingest Config, Flake Dashboard shells; CWV instrumentation (web‑vitals)
- WU‑104 CI wiring + protections (require “ci” + CodeQL; Dependabot active; license scan allowlist)
  - Artifacts: GH Actions, CodeQL, budgets check jobs
- WU‑105 Docs + examples (how to upload JUnit/Jest/PyTest samples)
  - Artifacts: examples/, docs pages, copy‑paste config snippets

Gate C (Monorepo + E2E thin flow)
- WU‑201 Nx monorepo scaffold; import @flakeradar/ui + web app via subtree
  - Artifacts: monorepo (apps/web, packages/ui, services/*), CI matrix
- WU‑202 Data model + migrations (Repo, TestCase, TestRun, FlakeScore, OwnerMap)
  - Artifacts: SQL migrations; seed scripts; RLS plan (document only if OSS core)
- WU‑203 Ingestion pipeline (GitHub Actions → artifact fetch → JUnit/Jest/PyTest parse)
  - Artifacts: parsers, upload endpoint, storage
- WU‑204 Scoring heuristics library (stability index, recency weight, failure clustering)
  - Artifacts: scoring module + tests
- WU‑205 PR Quarantine Bot (GitHub App minimal) — comment + label
  - Artifacts: bot app, permissions scoped; latency budget < 500ms p95
- WU‑206 Thin E2E test (sample repo → ingest → score → PR comment)
  - Artifacts: E2E workflow, demo recording, green CI

Gate D (Community launch + integrations)
- WU‑301 CLI ingest tool (stream JUnit/Jest/PyTest)
  - Artifacts: flakeradar-cli; docs
- WU‑302 Slack/webhook alerts; owner mapping hints
  - Artifacts: Slack app/webhook module; docs
- WU‑303 Docs site + good‑first‑issues + roadmap
  - Artifacts: Docusaurus/MkDocs site; populated issues; Discussions threads
- WU‑304 Additional CI/frameworks (CircleCI, Gradle, Mocha)
  - Artifacts: adapters; examples; benchmarks

10‑Day Kickoff (Gate A focus)
- Day 1: WU‑001 done (skeleton). Confirm quality bars + labels [ASSUMPTION: UTC cadence]. Start WU‑002.
- Day 2: Finish WU‑002 (Charter). Open Discussion: “Flake scoring heuristics v0.”
- Day 3: WU‑003 (Execution Plan). Prep ADR template.
- Day 4: WU‑004 (Architecture Brief outline). Identify data model and PR bot flow.
- Day 5: WU‑005 (Tool Playbook). Draft Manus + mgx.dev prompts; dry‑run locally if tools unavailable.
- Day 6: WU‑006 (Risk Register). Capture privacy, OSS sustainability, signal quality mitigations.
- Day 7: WU‑006 (Compliance + Governance). SECURITY, CONTRIBUTING, CODEOWNERS, PR template.
- Day 8: WU‑007 (Issue templates + seed). Label taxonomy; “good first issue” curation.
- Day 9: WU‑007 (Session Handoff + Exec Summary). Align Next Actions for executor.
- Day 10: Review + Gate A sign‑off. Create tracking issue “Gate B kickoff.”

RACI (roles)
- Orchestrator (you/this chat): R for planning/docs/playbooks; C for technical choices; A for Gate A acceptance criteria clarity.
- Maintainer (@rick1330): A for final approval/merges; R for governance and roadmap.
- Executor (Qoder/Cursor or emergent.sh): R for repo creation, commits, CI wiring per playbooks; C for workflow details.
- Manus: S (support) for research; outputs feed Charter/Architecture/Compliance revisions.
- mgx.dev: S for PRD v1.0 (OKRs, user stories/AC, roadmap).
- Lindy: S for UI/app scaffolds in Gate B/D; R for adhering to a11y/perf budgets in code.
- Community contributors: C on proposals via Discussions; R on good‑first‑issues with guidance.

Repo and Subtree Plan
- Program docs (this repo): rick1330/flakeradar-program (stays separate; docs only).
- UI library: rick1330/flakeradar-ui (@flakeradar/ui package).
- Web app: rick1330/flakeradar-web (Next.js Option A).
- Bot/service (optional split): rick1330/flakeradar-bot (GitHub App) [ASSUMPTION], or consolidate in monorepo later.
- Gate C: Create rick1330/flakeradar (Nx monorepo). Import UI and Web via git subtree:
  - subtree add —prefix packages/ui git@github.com:rick1330/flakeradar-ui.git main
  - subtree add —prefix apps/web git@github.com:rick1330/flakeradar-web.git main
  - Keep program repo independent; link from monorepo README.

Community Milestones (leading indicators)
- M1 (Gate A end): 10+ good‑first‑issues; Discussions enabled; 1+ ADR merged; 1+ external comment.
- M2 (Gate B mid): 10 stars; 1 first‑time contributor PR merged; CI green badge visible.
- M3 (Gate C end): Thin E2E demo video; 25 stars; 3 first‑time contributor PRs.
- M4 (Gate D end): 75 stars; 10 first‑time contributors; 2 published integrations.

Definition of Done (per WU)
- Commit pushed; Build Log updated; ADR added if decision; Session State updated; protections/CI checks passing where relevant; links to artifacts recorded.

Reviews and Rituals
- Weekly: Roadmap/labels review; triage new issues; post status in Discussions.
- Per gate: Retrospective + ADR sweep; confirm quality bars unchanged or record a new ADR if changed.