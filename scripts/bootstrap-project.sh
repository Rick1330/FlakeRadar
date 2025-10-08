#!/bin/bash
# bootstrap-project.sh

# Requires: gh CLI with proper authentication

set -euo pipefail

echo "Bootstrapping FlakeRadar Roadmap project and Sprint-01 milestone..."

# Create project
echo "Creating FlakeRadar Roadmap project..."
gh project create "FlakeRadar Roadmap" --owner rick1330 --format json

# Create milestone
echo "Creating Sprint-01 milestone..."
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/rick1330/flakeradar-program/milestones \
  -f title="Sprint-01" \
  -f description="First development sprint"

echo "Project bootstrap complete!"
echo ""
echo "Next steps:"
echo "1. Set up GH_TOKEN_SEED secret with repo and project scopes"
echo "2. Run the issue seeding script: bash scripts/seed-issues.sh"