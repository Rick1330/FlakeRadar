# FlakeRadar — Program Repo (Gate A, Docs‑First)

CI‑native flaky test detection and remediation for modern teams. FlakeRadar ingests test results from CI (GitHub Actions/JUnit/Jest/PyTest), scores flakes over time with transparent heuristics, quarantines flaky tests via a PR bot (comments/labels), and provides dashboards and playbooks that help teams fix the root causes fast.

This repository is the "program" repo for Gate A (discovery + PRD). It contains the docs, plans, playbooks, and issue seeds that guide execution. Code will be created in later gates via separate repos (UI library and web app), scaffolded by the executors (Qoder/Cursor or emergent.sh).

Assumptions Log [v0]
- Repo name: rick1330/flakeradar-program [ASSUMPTION]
- Codespaces/Node version: Node 20 LTS; pnpm preferred [ASSUMPTION]
- Initial time zone for cadence: UTC [ASSUMPTION]
- OSS branding: text logo placeholder until design pass in Gate B [ASSUMPTION]

Badges (placeholders; wire up after repo creation)
- License: Apache-2.0
- CI: pending
- CodeQL: pending
- Discussions: [enabled](https://github.com/Rick1330/FlakeRadar/discussions)

Quick Start (for these docs)
1) Read docs/01-charter.md for vision, OKRs, constraints, and quality bars.  
2) Review docs/02-execution-plan.md for Work Units (WUs), gates, kickoff, and RACI.  
3) Skim docs/03-architecture-brief.md to understand ingestion, scoring, PR bot flow, and the data model.  
4) Use docs/04-tool-playbook.md to run Manus (research) and mgx.dev (PRD v1.0).  
5) Check docs/05-risk-register.md and docs/06-compliance-brief.md before enabling telemetry or collecting data.  
6) Open issues from issues/seed.json and follow the WU cadence (commit per WU, update Build Log, ADR if decision).

Operating Principles (applies to all gates)
- Resume‑safe WUs (15–45 min): each ends with commit, push, Build Log update; ADR if a decision.  
- Quality bars: A11y WCAG 2.2 AA; Perf entry bundle <150KB gzipped; Security via CSP/CodeQL/Dependabot; Privacy minimal PII + opt‑in telemetry.  
- Community‑first: good‑first‑issue and help‑wanted labels, Discussions enabled, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY policy.

Repository Map
- docs/BUILDLOG.md — running log of WUs and artifacts
- docs/DECISIONS.md — ADR index (ADRs will live in adr/)
- docs/SESSION_STATE.json — session tracker for handoffs
- docs/* — charter, execution plan, architecture, tool prompts, risks, compliance
- playbooks/* — exact prompts for Manus, mgx.dev, Lindy, Qoder/Cursor, emergent.sh (added in later packets)
- .github/* — issue templates, PR template, CODEOWNERS (added in later packets)

Community Goals
- Star‑worthy OSS with friendly onboarding
- Clear roadmap and issue labels ("good first issue", "help wanted")
- Discussions enabled for proposals and Q&A
- Transparent governance and release process

License and Policies
- License: Apache‑2.0 (see LICENSE)
- Code of Conduct: Contributor Covenant v2.1 (added in later packet)
- Security: responsible disclosure and triage SLA (added in later packet)

How to Contribute (high‑level; details in CONTRIBUTING.md later)
- Use Conventional Commits (e.g., feat:, fix:, docs:, chore:) and include WU‑ID in the commit body.
- Open issues with acceptance criteria; label with gate/persona/module.
- Propose changes to quality bars via ADR before implementation.

—
Maintainers: @rick1330 (founding maintainer). More maintainers to be added via GOVERNANCE.md in Gate A.

## UI Package

FlakeRadar includes a lightweight, accessible UI component library built with React, TypeScript, and Tailwind CSS.

### Installation (GitHub Packages)

```bash
npm config set @rick1330:registry https://npm.pkg.github.com
npm i @rick1330/flakeradar-ui
```

Or with pnpm:

```bash
pnpm i @rick1330/flakeradar-ui
```

### Usage

```javascript
import { Button } from '@rick1330/flakeradar-ui';

function App() {
  return <Button variant="primary">Click me</Button>;
}
```

For complete documentation and available components, see the [UI repository releases](https://github.com/rick1330/flakeradar-ui/releases).

## Product Requirements

For detailed product requirements, see [PRD v1.0](docs/PRD.md).
