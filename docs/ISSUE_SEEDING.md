# Issue Seeding Documentation

This document explains how the FlakeRadar issue seeding system works, including the schema, script, and CI workflow.

## Overview

The issue seeding system automatically creates and updates GitHub issues based on a JSON seed file. It ensures consistency between the planned work (in [issues/seed.json](../issues/seed.json)) and the actual issues in the repository.

## Components

1. **Schema**: [schemas/issues.seed.schema.json](../schemas/issues.seed.schema.json) - Defines the structure and validation rules for the seed file
2. **Script**: [scripts/seed-issues.sh](../scripts/seed-issues.sh) - Bash script that processes the seed file and interacts with GitHub
3. **CI Workflow**: [.github/workflows/seed-issues.yml](../.github/workflows/seed-issues.yml) - Automates the seeding process on PRs and main branch pushes
4. **Mapping File**: [issues/map.json](../issues/map.json) - Tracks the relationship between seed IDs and GitHub issue numbers

## How It Works

### On Pull Requests

1. Validates the seed.json file against the schema
2. Performs a dry-run of the seeding process (no actual GitHub changes)
3. Comments on the PR with a summary of what would be created/updated

### On Main Branch Pushes

1. Validates the seed.json file against the schema
2. Creates/updates GitHub issues based on the seed file
3. Closes issues that were removed from the seed file (if CLOSE_MISSING=1)
4. Updates the mapping file with any new issue numbers
5. Commits and pushes the updated mapping file

## Seed File Structure

The seed file contains two main sections:

- **Epics**: High-level features or initiatives
- **Stories**: Specific work items that belong to epics

Each item can specify:
- Repository target (defaults to REPO_DEFAULT)
- Labels, milestones, and assignees
- Project board placement
- ADR (Architecture Decision Record) links

## Features

- **Multi-repo support**: Issues can be created in different repositories
- **Standardized labels**: Automatically creates and maintains consistent labels with colors
- **Milestone management**: Creates and assigns milestones
- **Project board integration**: Adds issues to GitHub Projects v2
- **Idempotent operations**: Safe to run multiple times
- **Dry-run mode**: Preview changes without making them
- **Close missing**: Automatically close issues removed from the seed
- **Rate limiting**: Respects GitHub API limits with retries
- **Error handling**: Graceful handling of failures

## Environment Variables

- `REPO_DEFAULT`: Default repository for issues (required)
- `PROJECT_OWNER`: GitHub organization/user owning the project board
- `PROJECT_TITLE`: Title of the project board to use
- `PROJECT_NUMBER`: Specific project number (alternative to PROJECT_TITLE)
- `DRY_RUN`: Set to "1" for preview mode
- `CLOSE_MISSING`: Set to "1" to close removed issues
- `TRANSFER_FALLBACK`: Set to "1" to create issues in default repo if target fails

## Usage

To run manually:
```bash
cd scripts
./seed-issues.sh
```

For a dry run:
```bash
DRY_RUN=1 ./seed-issues.sh
```

## Troubleshooting

If you encounter issues:
1. Check that GH_TOKEN has appropriate permissions (repo, issues, projects)
2. Verify the seed.json file validates against the schema
3. Ensure the target repositories exist and are accessible
4. Check that the project board exists if using project integration