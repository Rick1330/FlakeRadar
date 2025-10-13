# ADR-0019: UI package scope and registry
- Status: Accepted
- Date: 2025-10-13
- Context:
  - We originally planned to publish a UI package under @flakeradar/ui. To streamline ownership and GitHub Packages publishing, we released @rick1330/flakeradar-ui on GitHub Packages.
- Decision:
  - Publish the UI library as @rick1330/flakeradar-ui via GitHub Packages. Keep ESM-first with CJS + d.ts; peer deps for react, react-dom, and Radix components.
- Consequences:
  - Update docs/PRD.md and READMEs to show the correct package scope.
  - Consumers must add @rick1330 scope to their .npmrc if using npm. pnpm uses the same registry settings.