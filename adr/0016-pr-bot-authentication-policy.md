# ADR-0016: PR Bot Authentication Policy for MVP

## Status
Proposed

## Context
The PR bot requires GitHub API access to post comments and apply labels. Two authentication approaches are available:

1. **GitHub App**: More secure with fine-grained permissions, better rate limits, but requires app installation
2. **Personal Access Token (PAT)**: Simpler setup but broader permissions, user-tied rate limits

For MVP deployment, we need to balance security with onboarding friction.

## Decision
Use GitHub App with minimal permissions as the primary authentication method:

- **Production deployments**: GitHub App only with permissions (metadata:read, contents:read, pull_requests:write, checks:write)
- **Development/demo environments**: Support PAT fallback for reduced setup friction
- **Installation process**: Provide clear documentation for GitHub App installation
- **Rate limiting**: Leverage GitHub App's superior rate limit handling

## Consequences

### Positive
- Better security posture with minimal required permissions
- Superior rate limit handling for production use
- Audit trail tied to app rather than individual user
- Professional appearance in GitHub integrations

### Negative
- More complex initial setup requiring app installation
- Additional documentation needed for app configuration
- Fallback complexity for development environments

### Neutral
- Environment variable configuration for both auth methods
- Clear separation between production and development practices

## Implementation Notes
- GitHub App creation and installation guide required
- PAT fallback only enabled via feature flag in development
- Clear warnings about PAT security implications in documentation
- Migration path from PAT to GitHub App for existing users