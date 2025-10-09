# Migrate Legacy Issue Templates → Issue Forms

Why this matters
- GitHub's legacy templates use the `about:` key, which is invalid for Issue Forms and surfaces "about is not a permitted key".

Steps
1) Check for legacy templates:
   - Look for `.github/ISSUE_TEMPLATE/*` files containing `about:` or legacy `.md` templates.
   - Our CI now flags these in PRs that touch `.github/ISSUE_TEMPLATE`.

2) Choose a path:
   - Replace with forms (preferred): use the provided epic.yml, story.yml, bug.yml.
   - Or disable legacy: rename old files to `.disabled` or remove them.

3) Verify forms:
   - Each template must have top-level `name`, `description`, and a `body` with at least one non-markdown input.
   - Labels can be set top-level. Ensure unique `id` and `label` per input within a form.

4) Test locally:
   - Open the repository's "New issue" page in a browser; ensure only the desired forms are shown and no warnings appear.

Notes
- You can keep both forms and legacy `.md` templates, but GitHub will highlight invalid legacy YAML with `about:` in the UI. Prefer cleaning them up.