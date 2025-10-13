# ADR-0020: Web CI check context stabilization ("ci / build")
- Status: Accepted
- Date: 2025-10-13
- Context:
  - Branch protection initially required "ci" but the workflow reported "ci / build (20)", causing "Expected" status to hang.
- Decision:
  - Use a single-job workflow named "ci" with job "build" for a stable context "ci / build" and require that in branch protections.
- Consequences:
  - Reduced friction merging PRs. Ensure any new workflows don't alter this context name without updating protections.