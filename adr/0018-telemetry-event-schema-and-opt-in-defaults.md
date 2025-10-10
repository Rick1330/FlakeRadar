# ADR-0018: Telemetry Event Schema and Opt-in Defaults

## Status
Proposed

## Context
Telemetry data helps improve FlakeRadar through usage analytics and performance monitoring. However, OSS projects must balance product insights with community trust and privacy expectations.

A structured approach to telemetry collection, storage, and user control is needed to maintain community trust while enabling data-driven improvements.

## Decision
Implement structured telemetry with the following schema and policies:

**Event Types:**
```json
{
  "ui.page_view": {
    "route": "/dashboard",
    "timestamp": "2025-10-10T10:00:00Z", 
    "session_id": "hashed_session"
  },
  "ingest.completed": {
    "framework": "junit",
    "test_count": 150,
    "payload_size_kb": 45,
    "processing_time_ms": 850,
    "repo_id_hash": "sha256_hash"
  },
  "scoring.candidates": {
    "total_tests": 150,
    "flaky_count": 3,
    "avg_score": 25.4,
    "framework": "junit"
  }
}
```

**Privacy Controls:**
- Default disabled in OSS installations
- Explicit opt-in via `FRA_TELEMETRY_ENABLED=true`
- Honor Do-Not-Track headers (skip all collection)
- Hash repository identifiers unless explicit opt-in for repo names
- No PII collection (emails, real names, IP addresses)

## Consequences

### Positive
- Transparent data collection with clear schema
- Strong privacy defaults build community trust
- Structured data enables meaningful analytics
- User control over data sharing

### Negative
- Limited telemetry data may slow product improvements
- Additional complexity in telemetry infrastructure
- Opt-in friction may reduce data collection

### Neutral
- Clear documentation required for telemetry policies
- Infrastructure needed for telemetry collection and storage
- Regular review of telemetry practices needed

## Implementation Notes
- Telemetry collection only when explicitly enabled
- Event schema versioning for future changes
- Aggregate-only reporting to preserve privacy
- Regular audit of collected data types
- Community transparency about telemetry usage