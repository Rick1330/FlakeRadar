# ADR-0015: Rerun Weighting Strategy and Configuration

## Status
Proposed

## Context
CI systems often implement automatic test reruns to handle transient failures. However, treating rerun-induced failures equally with initial failures can skew flaky test detection, either masking truly flaky tests or creating false positives from infrastructure issues.

Current implementation counts all failures equally, which may not accurately represent test reliability when reruns are involved.

## Decision
Implement a rerun weighting strategy with the following rules:

- **Initial failures**: Always count with full weight (1.0) even if subsequent rerun passes
- **Rerun-induced failures**: Default weight of 0.5 to balance signal preservation with noise reduction
- **Configuration**: Repository-level override via `/api/repos/:id/config` endpoint
- **Header tracking**: Use `X-FR-Rerun-Count` header to track rerun attempts during ingestion

## Consequences

### Positive
- More accurate flake classification by distinguishing initial vs rerun failures
- Reduces false positives from transient infrastructure issues
- Maintains signal for legitimate flaky behavior
- Configurable per repository for different team preferences

### Negative
- Increased complexity in scoring algorithm
- Requires CI integration changes to pass rerun count
- Additional configuration surface area

### Neutral
- Database schema update needed for rerun tracking
- Documentation required for header usage and configuration

## Implementation Notes
- Default 0.5 weight balances most common use cases
- Teams with stable infrastructure may prefer higher rerun weights
- Teams with unstable infrastructure may prefer lower rerun weights
- Scoring formula remains mathematically consistent with weighted inputs