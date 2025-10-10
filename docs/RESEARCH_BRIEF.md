# FlakeRadar Research Brief v1.1 (2025-10-10)

## Executive Summary

- **CI Market Fragmentation**: 50% of developers use CI/CD tools with 41% transitioning to cloud-based solutions. GitHub Actions leads in GitHub-centric workflows, while Jenkins maintains enterprise presence despite migration trends.
- **Flake Detection Maturity**: Current heuristics focus on rerun analysis, frequency weighting, and recency bias. Advanced systems use volatility metrics and streak analysis with configurable window sizes (N=20-100 typical).
- **OSS Governance Trends**: DCO adoption increasing over CLA for reduced friction. Opt-in telemetry with 30-day retention becoming standard. CODEOWNERS and GitHub Discussions essential for community engagement.
- **Enterprise Readiness Gap**: SOC 2, SSO/SCIM, and data residency requirements create adoption barriers. Pricing models range from $15-70/host/month for enterprise features.
- **Competitive Positioning**: Open-source transparency and CI-native design differentiate FlakeRadar from closed-source enterprise solutions like BuildPulse ($50+/month) and Datadog CI Visibility ($15+/host).

## Findings

### 1) CI Landscape + Frameworks

**Market Share &amp; Adoption [ASSUMPTION: Based on 2024 developer surveys]**:
- **GitHub Actions**: Dominant in GitHub-centric workflows, 2,000 free minutes/month limitation
- **GitLab CI/CD**: 40% faster deployments reported, integrated DevOps platform approach
- **CircleCI**: 2M+ developers, superior Docker support, performance-critical builds
- **Jenkins**: Enterprise legacy, active migration away but still 30%+ market share

**Testing Framework Integration**:
- **JUnit**: XML format standard, mature ecosystem, parameterized test support
- **Jest**: JSON output, JavaScript ecosystem leader, snapshot testing capabilities
- **PyTest**: Python standard, fixture-based, extensive plugin ecosystem
- **Mocha/Gradle**: Secondary priorities for Gate D expansion

**Key Insights**:
- Cloud-native CI adoption accelerating (41% transition rate)
- Framework-specific optimizations needed for accurate flake detection
- Multi-CI support essential for broad adoption

### 2) Flake Detection Heuristics

**Core Algorithms [ASSUMPTION: Industry best practices]**:
- **Volatility Calculation**: toggles / max(1, N-1) where N=window size
- **Recency Weighting**: Exponential decay w[i] = exp(-λ*(N-i)), λ = ln(2)/7
- **Streak Analysis**: Consecutive failure/pass patterns, minimum streak length = 2-3
- **Rerun Semantics**: Initial failure counted even if rerun passes, 0.5 weight for rerun-induced failures

**Window Size Tuning**:
- **Small projects**: N=20-30 for faster signal
- **Large projects**: N=50-100 for statistical significance
- **Framework-specific**: Jest N=30, JUnit N=50, PyTest N=40 [ASSUMPTION]

**Advanced Techniques**:
- **Parameterized Test Handling**: Per-parameter flake tracking
- **Sharded Test Support**: Cross-shard correlation analysis
- **Environmental Factors**: Time-of-day, resource contention patterns

### 3) OSS Governance &amp; Telemetry Norms

**Contributor Licensing**:
- **DCO Trend**: Lightweight, probot/dco tooling available, reduces friction
- **CLA Alternative**: OpenJS Foundation preference, legal clarity but higher barrier

**Community Standards**:
- **CODEOWNERS**: Required for maintainer scalability, pattern-based ownership
- **GitHub Discussions**: Q&amp;A, Ideas, Announcements categories standard
- **Issue Templates**: Epic/Story/Bug forms with structured data

**Telemetry Best Practices**:
- **Default Disabled**: OSS installations opt-in only
- **Event Schema**: ui.page_view, ingest.completed, scoring.candidates
- **Retention**: 30 days for events, aggregates only beyond
- **DNT Respect**: Honor Do-Not-Track headers

### 4) Privacy/Compliance

**Data Minimization**:
- **PII Limits**: GitHub logins only, no emails/real names
- **Retention Defaults**: TestRun 30 days, FlakeScore 180 days
- **Deletion Rights**: Cascade delete by repo owner

**Compliance Framework**:
- **GDPR Ready**: Data minimization, purpose limitation, user control
- **License Allowlist**: Apache-2.0, MIT, BSD-2/3, ISC; restrict GPL/AGPL
- **Security Controls**: CSP, CodeQL weekly, Dependabot, protected main

### 5) Adoption Friction for Hosted Tier

**Enterprise Requirements**:
- **SOC 2**: 6-9 months preparation, audit trails, access controls
- **SSO/SCIM**: Identity management, RBAC, automated provisioning
- **Data Residency**: Multi-region infrastructure, local compliance
- **DPA**: Data Processing Agreements, subprocessor disclosure

**Pricing Patterns [ASSUMPTION: Market analysis]**:
- **Infrastructure**: $15-23/host/month (Datadog model)
- **Per-Repository**: $50+/month (BuildPulse model)
- **Usage-Based**: API calls, storage, compute time
- **Enterprise**: Custom pricing, volume discounts

## Competitive Matrix

| Product | Target Users | Ingest Coverage | Scoring Method | PR/Bot Capability | Pricing (Public) | OSS? |
|---------|-------------|-----------------|----------------|-------------------|------------------|------|
| **BuildPulse** | Enterprise teams | Multi-CI, all frameworks | ML-powered insights | GitHub integration | $50+/repo/month | No |
| **Datadog CI** | Large enterprises | Comprehensive CI/CD | Advanced analytics | Limited | $15-40/host/month | No |
| **Launchable** | Enterprise | AI-powered selection | ML prediction | Test optimization | Enterprise only | No |
| **Jenkins Plugin** | Jenkins users | Jenkins-only | Basic algorithms | Jenkins-native | Free | Yes |
| **Azure Test Plans** | Microsoft ecosystem | Azure DevOps | Basic reporting | Azure integration | $6/user/month | No |
| **FlakeRadar** | All teams | GitHub Actions first | Transparent heuristics | GitHub App | Free (OSS) | Yes |

## Recommendations

### High Priority (Gate C)

**H1: Framework-Specific Thresholds** (2-3 days effort)
- Implement configurable window sizes: Jest N=30, JUnit N=50, PyTest N=40
- Rationale: Different frameworks have different execution patterns and statistical needs
- Impact: Improved signal quality, reduced false positives

**H2: Rerun Weighting Strategy** (1-2 days effort)
- Default 0.5 weight for rerun-induced failures, configurable per repository
- Rationale: Balances signal preservation with noise reduction
- Impact: More accurate flake classification

### Medium Priority (Gate D)

**M1: Enhanced Telemetry Schema** (3-4 days effort)
- Structured event schema with opt-in granular controls
- Rationale: Product insights while maintaining community trust
- Impact: Data-driven improvements, community transparency

**M2: Multi-CI Adapter Framework** (1-2 weeks effort)
- Plugin architecture for CircleCI, GitLab CI integration
- Rationale: Market fragmentation requires broad CI support
- Impact: Expanded addressable market

### Low Priority (Post-MVP)

**L1: Advanced ML Integration** (4-6 weeks effort)
- Optional ML models for prediction, maintaining transparent baseline
- Rationale: Competitive differentiation while preserving explainability
- Impact: Superior accuracy for advanced users

## Implications for Docs

### docs/01-charter.md (v1.1)
- **OKR Refinement**: Add "Framework-specific scoring parameters implemented" to Gate C KR2
- **Scope Edge**: Clarify "Multi-CI support: GitHub Actions MVP, CircleCI/GitLab Gate D"

### docs/03-architecture-brief.md (v1.1)
- **Ingest Headers**: Add X-FR-Framework, X-FR-Rerun-Count headers
- **Example Request**: Include framework-specific payload examples
- **Rate Limits**: Specify 100 req/hour per repo, 10 writes/min for PR bot
- **Thresholds**: Document framework-specific defaults and configuration
- **Rerun Weighting**: Detail 0.5 default weight with repo-level overrides

### docs/06-compliance-brief.md (v1.1)
- **Telemetry Schema**: Define structured event format with PII scrubbing
- **Retention Table**: TestRun 30d, FlakeScore 180d, Events 30d, Aggregates 2y
- **DNT Handling**: Explicit Do-Not-Track header respect implementation
- **Deletion API**: DELETE /api/repos/:id cascade behavior documentation

## Proposed ADRs

**ADR-0014: Framework-Specific Scoring Window Configuration**
Establish different default window sizes (N) per testing framework based on execution patterns and statistical significance requirements. Jest N=30 for rapid feedback, JUnit N=50 for enterprise stability, PyTest N=40 for scientific computing balance. Repository-level overrides supported via configuration API. This addresses framework-specific execution patterns while maintaining statistical validity.

**ADR-0015: Rerun Weighting Strategy and Configuration**
Implement 0.5 default weight for rerun-induced test failures to balance signal preservation with noise reduction. Configurable per repository via /api/repos/:id/config endpoint. Initial failures always count full weight even if rerun passes. This approach maintains flake detection sensitivity while reducing false positives from transient infrastructure issues.

**ADR-0016: PR Bot Authentication Policy for MVP**
Use GitHub App with minimal permissions (metadata:read, contents:read, pull_requests:write) for production deployments. Support Personal Access Token fallback only for development and demo environments. App installation provides better security posture and rate limit handling. PAT fallback reduces onboarding friction for initial evaluation but should not be used in production.

**ADR-0017: Data Retention Hierarchy and Purge Strategy**
Establish retention defaults: TestRun 30 days (configurable 7-365), FlakeScore 180 days (rolling updates), telemetry events 30 days, aggregate metrics 2 years. Implement cascade deletion via foreign key constraints. Repository owners can trigger immediate purge via DELETE /api/repos/:id. This balances storage costs with analytical value while ensuring user control.

**ADR-0018: Telemetry Event Schema and Opt-in Defaults**
Define structured telemetry schema with three event types: ui.page_view (route, timestamp), ingest.completed (framework, test_count, processing_time), scoring.candidates (total_tests, flaky_count, avg_score). Default disabled in OSS installations, explicit opt-in required via FRA_TELEMETRY_ENABLED=true. Honor DNT headers by skipping all collection. Hash repository identifiers unless user explicitly opts into repo name sharing.

## References

- Developer Ecosystem Reports 2024 [ASSUMPTION]
- CI/CD Market Analysis and Growth Projections [ASSUMPTION]
- Flaky Test Detection Research Papers [ASSUMPTION]
- OSS Governance Best Practices [ASSUMPTION]
- Enterprise Software Adoption Studies [ASSUMPTION]