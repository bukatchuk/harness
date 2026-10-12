# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow [semver](https://semver.org/). Русский: [CHANGELOG.md](CHANGELOG.md).

## [1.5.0] — 2026-10-12

### Added

- Timeweb Cloud integration: the `integrations/timeweb.md` cheat sheet — calling the API, reading servers, S3 buckets and addresses. The token lives in the `TW_TOKEN` environment variable; `bin/harness doctor` checks that it is set and, with `--deep`, that the API answers.
- A rule in `rules/secrets.md`: nothing is created or deleted in Timeweb Cloud without the owner's knowledge and explicit instruction for the specific resource.
- README: a "Registry" section — what the three files hold, an S3 bucket recorded as a separate link, the hosting data block of a server and of a bucket.

### Changed

- Registry: a server now has `ipv4`, `ipv6` and a `timeweb` block (identifier, project, zone, plan, creation date, PTR); S3 buckets are recorded as `s3-<bucket>` links.
- Registry of this installation: hosting data for every server and links for every bucket.

## [1.4.2] — 2026-10-12

### Changed

- Registry of this installation: a new project, a link for it and the purpose of three servers.

## [1.4.1] — 2026-10-12

### Changed

- Registry of this installation: the description of one project brought in line with its actual state.

## [1.4.0] — 2026-10-11

### Added

- Telegram notification about a release: `.github/workflows/release-notify.yml` sends a message when a release is published on GitHub — title, time, notes and link. It needs two repository secrets, `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID`; without them the step is skipped. The notes go as plain text and are cut to 2500 characters.

## [1.3.1] — 2026-10-11

### Fixed

- Changelog: two entries used the name of a registry link, and the leak check of the public build rejected them. The entries are reworded; versions 1.2.2, 1.2.3 and 1.3.0 are not published separately, their changes are part of this one.

## [1.3.0] — 2026-10-11

### Added

- Auto-publishing of the open version: with `release.auto_publish: true` in `harness.json` the public release goes out right after every successful release of the private repository, without a reminder from the owner. The `push` skill runs `release-public` itself; in this mode `release-public` does not ask for consent, but stops on a leak and on unexpected files in the build.
- The `release-public` skill: how to catch up when the public repository is several versions behind.

### Changed

- The rule on changing harness: a public release is no longer "only at the owner's request" — with auto-publishing on, it is required after every release.

## [1.2.3] — 2026-10-11

### Changed

- Registry of this install: the entry about metrics collection was extended.

## [1.2.2] — 2026-10-11

### Changed

- Registry of this install: the entry about metrics collection was brought up to date.

## [1.2.1] — 2026-10-11

### Changed

- Registry of this install: the repository, service and server descriptions were brought up to date.

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
