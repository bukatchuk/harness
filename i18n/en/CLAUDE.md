# Harness

You work in harness, the single hub for all of the owner's projects. The session-start hook tells you who the owner is; their name and email are recorded in `harness.json`. Talk to the owner in English.

## What lives where

- `VERSION`, `CHANGELOG.md` — the harness configuration version. To get the current one: `bin/harness version`.
- `harness.json` — settings of this install: the owner (`owner`), the language (`lang`), the connected integrations (`integrations`). Created and changed by `bin/harness init`.
- `registry/repos.json` — the project registry. Clones live in `repos/<name>`; they are separate git repositories and are not committed to harness.
- `worktrees/<name>/<branch>` — separate working copies of the clones for parallel sessions; created by `bin/harness worktree`, never committed to harness.
- `registry/servers.json` — the server registry: address, user, environment, location, purpose.
- `registry/services.json` — links: which repository is responsible for the configuration of which server and which service on it. To view: `bin/harness map <name>`.
- `.claude/rules/` — universal rules that apply in all projects.
- `.claude/skills/` — procedures: `commit`, `push`, `pr-create`, `repo-add`, `repo-remove`, `repo-sync`, `server-add`, `server-remove`, `service-add`, `service-remove`, `harness-reset`, `harness-update`, `harness-doctor`, `release-public`.
- `.claude/integrations/` — cheat sheets for external services (the Bitwarden secret store, Plane, n8n, GitGuardian, GitLab, Yandex Cloud, mailcow, Timeweb Cloud, Umami). Read the one you need before first using a service; do not preload them. An integration is enabled if its key is present in `harness.json`.
- `i18n/` — the sources of the rules, skills and cheat sheets in Russian and English. The files in `.claude/` are a copy in the selected language; `bin/harness lang` creates it.
- `bin/harness` — CLI: `init`, `lang`, `doctor`, `sync`, `status`, `servers`, `server-check`, `map`, `repo-remove`, `server-remove`, `service-remove`, `reset`, `check-commits`, `docker-up`, `docker-check`, `docker-clean`, `locks`, `unlock`, `worktree`, `forge`, `mr`, `mr-status`, `release-create`, `task`, `tasks`, `secrets`, `selfcheck`, `release-build`, `release-publish`.

## Working with projects

- Before a task in a project, find it in the registry: it has the description, the stack and the linked project in the task tracker.
- If the project is not in `repos/`, clone it with `bin/harness sync <name>`.
- A project may have its own `CLAUDE.md` and rules. They refine the harness rules; where they contradict on git identity, secrets and Docker cleanup, the harness rules apply.
- Run all git commands for a project in its directory (`git -C repos/<name> …`), not in the harness root.
