# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow [semver](https://semver.org/). Русский: [CHANGELOG.md](CHANGELOG.md).

## [1.2.0] — 2026-10-11

### Added

- mailcow integration: the `.claude/integrations/mailcow.md` cheat sheet (calling the API, creating a mailbox, response specifics), the `MAILCOW_TOKEN` token, the `integrations.mailcow.url` key in `harness.json`. `bin/harness doctor` checks that the token is present and the API is reachable.

### Changed

- The secrets rule: `MAILCOW_TOKEN` joins the environment tokens; creating and deleting mailboxes and aliases in mailcow requires the owner's confirmation.

## [1.1.2] — 2026-10-11

### Changed

- Registry of this install: a new repository, a service link and a server description.

## [1.1.1] — 2026-10-11

### Changed

- Registry of this install: server descriptions and the links between repositories and services were brought up to date.

## [1.1.0] — 2026-10-11

### Changed

- How changes are made to a project (a direct push or a branch and a PR, branch naming, deploy) lives in the project's own `CLAUDE.md`, not in the harness registry. The `push` skill checks the project rules before pushing; if they do not describe it, it asks the owner and offers to record the answer in the project.
- The `repo-add` skill no longer fills in the `flow` field and looks for the workflow in the project rules.

### Removed

- The `flow` field from the `registry/repos.json` entries.

## [1.0.0] — 2026-10-10

The first public release, under the MIT license. The harness core is separated from the owner's data, so the same version works both as a personal install and as an open project.

### Added

- **Install settings in `harness.json`**: the owner (name and email for commits), the language, the enabled integrations. Created by `bin/harness init`, which the installer calls as well.
- **Two languages**: rules, skills and cheat sheets exist in Russian and English (`i18n/ru`, `i18n/en`), and so do the CLI messages. Switch with `bin/harness lang ru|en`.
- **Installer** `install.sh`: one command downloads harness, checks the dependencies and runs the setup.
- **Removal from the registry**: the `repo-remove`, `server-remove` and `service-remove` skills and commands. A server or a repository referenced by links is removed only with an explicit `--unlink`; a clone with unsaved work only with `--force`.
- **Reset**: the `harness-reset` skill and the `bin/harness reset` command empty the registry of repositories, servers and links. Without `--yes` the command only prints the plan.
- **Registry backup** in `.harness-backup/` before every removal and reset.
- **Public release**: `bin/harness release-build` builds the open version without the owner's data and scans it for leaks — emails, IP addresses, identifiers, tokens, keys, home directories and everything named in the settings and registry of the install. `bin/harness release-publish` pushes the build to the public repository as one commit per release. The `release-public` skill walks through the steps.
- **Integrity check** `bin/harness selfcheck` and the end-to-end test `tests/smoke.sh`; CI on Linux and macOS.
- `README.en.md`, `CONTRIBUTING.md`, `SECURITY.md`, issue and pull request templates, the MIT license.

### Changed

- Rules, skills and cheat sheets are stored in `i18n/`, and `.claude/` is their deployed copy in the chosen language. The agent's entry point is now `.claude/CLAUDE.md`. The user's own rules and skills in `.claude/` survive a language switch.
- The commit author comes from `harness.json` and is pinned in `.claude/settings.local.json`, not in the shared `.claude/settings.json`.
- Integrations (Plane, n8n, GitGuardian, Yandex Cloud) are enabled by a key in `harness.json`; `doctor` checks only the enabled ones. Service URLs are read from the settings.
- `doctor`: a missing `gh` or `docker` is a warning, not an error; a "Setup" section was added.
- `bin/harness map` prints a table with named columns, like `servers` and `status`.
- A missing registry file is treated as an empty registry and is created automatically.

### Removed

- The `env` block with the commit author in `.claude/settings.json`.
