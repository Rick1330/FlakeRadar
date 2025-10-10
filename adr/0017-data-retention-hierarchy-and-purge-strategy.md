# ADR-0017: Data Retention Hierarchy and Purge Strategy

## Status
Proposed

## Context
FlakeRadar stores multiple types of data with different analytical value and storage costs. A clear retention hierarchy is needed to balance storage costs, analytical capabilities, and user privacy expectations.

Different data types serve different purposes and should have appropriate retention periods reflecting their value and privacy implications.

## Decision
Establish the following retention hierarchy:

**Operational Data:**
- TestRun: 30 days default (configurable 7-365 days per repository)
- FlakeScore: 180 days (rolling updates, configurable 90-730 days)

**Telemetry Data:**
- Event data: 30 days (fixed, not configurable)
- Aggregate metrics: 2 years (configurable 1-5 years)

**System Data:**
- Application logs: 14 days (configurable 7-30 days)

**Purge Strategy:**
- Automated purge based on retention policies
- Manual purge via DELETE `/api/repos/:id` (cascade deletion)
- Foreign key constraints ensure referential integrity during deletion

## Consequences

### Positive
- Clear data lifecycle management
- Balances storage costs with analytical value
- User control over their data
- Compliance with privacy expectations

### Negative
- Configuration complexity for different retention periods
- Storage optimization required for large datasets
- Automated purge job implementation needed

### Neutral
- Database design must support efficient purging
- Monitoring required for purge job health
- Documentation needed for retention configuration

## Implementation Notes
- Cascade deletion via foreign key constraints
- Background jobs for automated purging
- Repository-level configuration overrides
- Audit logging for manual deletion requests
- Grace period before irreversible deletion