# ADR-0014: Framework-Specific Scoring Parameters

## Status
Proposed

## Context
Different testing frameworks exhibit varying execution patterns and statistical characteristics that affect flaky test detection accuracy. Jest tests in frontend development typically run faster with more frequent executions, while JUnit tests in enterprise environments may have longer execution cycles. PyTest usage in scientific computing requires balanced statistical significance.

Current implementation uses a universal window size N=50 for all frameworks, which may not optimize signal quality across different testing contexts.

## Decision
Implement framework-specific default window sizes for flake scoring analysis:

- **Jest**: N=30 (rapid feedback for frontend development cycles)
- **JUnit**: N=50 (enterprise stability requirements) 
- **PyTest**: N=40 (scientific computing balance)
- **Repository-level overrides**: Configurable via `/api/repos/:id/config` endpoint

## Consequences

### Positive
- Improved signal quality and reduced false positives per framework
- Better statistical significance for different testing contexts
- Maintains flexibility through repository-level configuration
- Aligns with framework-specific execution patterns

### Negative
- Increased configuration complexity
- Framework detection required during ingestion
- Additional testing needed for each framework path

### Neutral
- Database schema requires framework field in TestCase table
- Documentation updates needed for configuration options

## Implementation Notes
- Default thresholds apply automatically based on detected framework
- Repository owners can override via configuration API
- Backward compatibility maintained for existing installations