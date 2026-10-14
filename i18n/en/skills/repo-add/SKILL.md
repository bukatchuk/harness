---
name: repo-add
description: Add a repository to the harness registry (registry/repos.json) and clone it into repos/. Use when the owner names a new project or gives a list of repositories.
argument-hint: "<git-url> [name]"
---

Add a repository to the registry. Arguments: $ARGUMENTS

1. Take the URL in SSH form: `git@github.com:<owner>/<name>.git` or, for the owner's GitLab, `git@<GitLab host>:<group>/<name>.git`. The default name is the repository name; it must be unique in the registry.
2. Check access without cloning: `git ls-remote --symref <url> HEAD`. Take the main branch from the same output.
3. Add an entry to `registry/repos.json` with `jq`, keeping the sort by name. Fields:
   - `name` — the directory name in `repos/`;
   - `url` — the clone address;
   - `branch` — the main branch;
   - `description` — one line: what this project is;
   - `stack` — the main technologies;
   - `plane_project` — the project identifier in Plane (for example, `SHOP`) or `null`;
   - `plane_project_id` — the `id` of this project in Plane or `null`.
4. Clone: `bin/harness sync <name>`.
5. Fill in `description` and `stack` from facts: look at the README and manifests (`package.json`, `go.mod`, `pyproject.toml`, `Dockerfile`). Ask the owner about what you do not know (`plane_project`); do not make it up.
6. Note whether the project has its own `CLAUDE.md`, `AGENTS.md`, `.claude/`. How changes are made (a direct push or a branch and a PR, branch naming, deploy) lives there, not in the registry: if it is not described, ask the owner and offer to record it in the project `CLAUDE.md`. If there are rules there that duplicate or contradict harness, list them to the owner; do not edit them yourself.
7. Show the resulting entry. If `registry/` is tracked in this harness's git, adding to the registry is a change to harness: when committed, it raises the patch version (see `.claude/rules/harness.md`).

Add several repositories at once with a single registry edit and a single `bin/harness sync`.
