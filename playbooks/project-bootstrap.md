# Project Bootstrap Playbook

## Create FlakeRadar Roadmap Project

1. Navigate to https://github.com/users/rick1330/projects
2. Click "New project"
3. Select "Board" template
4. Name it "FlakeRadar Roadmap"
5. Set visibility to "Public"
6. Click "Create project"

## Create Sprint-01 Milestone

1. Navigate to https://github.com/rick1330/flakeradar-program/milestones
2. Click "New milestone"
3. Title: "Sprint-01"
4. Description: "First development sprint"
5. Due date: (set appropriate date)
6. Click "Create milestone"

## Set up GH_TOKEN_SEED Secret

1. Navigate to https://github.com/rick1330/flakeradar-program/settings/secrets/actions
2. Click "New repository secret"
3. Name: "GH_TOKEN_SEED"
4. Value: (personal access token with repo and project scopes)
5. Click "Add secret"

## Optional: Bootstrap Script

You can use the following script to automate project creation:

```bash
#!/bin/bash
# bootstrap-project.sh

# Requires: gh CLI with proper authentication

# Create project
gh project create "FlakeRadar Roadmap" --owner rick1330 --format json

# Create milestone
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/rick1330/flakeradar-program/milestones \
  -f title="Sprint-01" \
  -f description="First development sprint"
```