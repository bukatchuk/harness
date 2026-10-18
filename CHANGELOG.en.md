# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow [semver](https://semver.org/). Русский: [CHANGELOG.md](CHANGELOG.md).

## [1.14.1] — 2026-10-18

### Changed

- Registry of this installation: a project description corrected.

## [1.14.0] — 2026-10-18

### Added

- The "Project context" rule (`.claude/rules/context.md`): a project's context and the warm-up prompt for starting a session live in the project's repository (`CLAUDE.md`, `.claude/`) and are checked for being current when each task is closed, so that a new session carries on without the owner explaining things again. The warm-up prompt is a short snapshot of "where we are and what is next"; outdated parts are rewritten.

### Changed

- `.claude/rules/tasks.md`: before moving a task to `Done`, check the repository context and the warm-up prompt.

## [1.13.6] — 2026-10-18

### Changed

- Settings of this installation: one more password of the secret store for sessions.

## [1.13.5] — 2026-10-18

### Changed

- Registry of this installation: a project description corrected.

## [1.13.4] — 2026-10-18

### Fixed

- `bin/harness sync` clones an empty repository (no commits yet): cloning with the registry branch used to fail with "Remote branch main not found". The clone gets HEAD on the registry branch, and the next `sync` after the first commit in origin creates the tracking branch. `bin/harness status` shows such a clone as "(empty)" instead of `HEAD ? ?`. Covered in `tests/smoke.sh`.

## [1.13.3] — 2026-10-18

### Changed

- Settings of this installation: one more token of the secret store for sessions.

## [1.13.2] — 2026-10-18

### Fixed

- `bin/harness`: the public repository CI passes shellcheck again — since 1.12.0 it was failed by findings in the self-check (unquoted `-m done`, a function called through `check_bg`, assigning `ERRORS` in a subshell) and `A && B || C` in `mr-status`.

## [1.13.1] — 2026-10-18

### Fixed

- `bin/harness`: time-limited checks (Docker in `doctor`, `fetch` at session start) no longer make the shell print `Terminated: 15` — the watcher is stopped and reaped. The `fetch_origin` watcher is now stopped too instead of waiting out its limit.

## [1.13.0] — 2026-10-17

### Added

- Skill `service-remove`: the order of full decommissioning of a service — links, monitoring, the proxy before the certificate, the server (containers, all images, deploy keys, certificate), DNS, a repository copy with a checksum check and final deletion at the code host, the registry, tasks. Tried out on decommissioning one site.

## [1.12.7] — 2026-10-17

### Changed

- Registry of this installation: a decommissioned site removed together with its repository and server link.

## [1.12.6] — 2026-10-17

### Changed

- Registry of this installation: a new service linked to its server, a note of an existing service updated.

## [1.12.5] — 2026-10-17

### Changed

- Registry of this installation: two new repositories and services linked to their servers.

## [1.12.4] — 2026-10-17

### Changed

- Settings of this installation: a word matching an integration name is allowed in the public build check by the owner's decision.

## [1.12.3] — 2026-10-17

### Changed

- Registry of this installation: a new repository and a service linked to its server.

## [1.12.2] — 2026-10-17

### Removed

- Registry of this installation: a deleted server removed from the registry.

## [1.12.1] — 2026-10-16

### Changed

- Registry of this installation: a server replaced with a new one, the old one kept until removal.

## [1.12.0] — 2026-10-16

### Added

- `bin/harness doctor --md` prints the result as a table with emoji (✅ ⚠️ ❌) and a result line. The `harness-doctor` skill runs `doctor --deep --md` without cutting the output and shows the whole table to the owner in its reply.
- Progress: while `doctor` runs, stderr shows what is being checked right now (`⏳ SSH <server>…`); in a terminal it is a single line updated in place. Silent with `--quiet` (the session start check).

### Changed

- `doctor --deep` starts the API requests, the origin check and the SSH logins in parallel at the beginning and shows them in the same order as before; `bw status` is called once. A full check takes 12 s instead of 122 s with 8 servers and 6 services.
- An unknown `doctor` option is now refused with a hint. The checks are in `bin/harness selfcheck`.

## [1.11.1] — 2026-10-16

### Fixed

- The hook refused any command where the word "secrets" followed "harness" (for example `git -C …/harness log --grep secrets` or a description text). Now only a call of the `harness secrets` command without `--check` is refused. The checks are in `bin/harness selfcheck`.

### Changed

- Registry and settings of this installation: a link between a new service and a server, the secret store connected.

## [1.11.0] — 2026-10-16

### Added

- `bin/harness secrets` — the tokens of the enabled integrations from a Bitwarden (or compatible) vault: the owner runs `eval "$(bin/harness secrets)"` before starting claude, and the tokens reach the environment without being written to disk or printed to a terminal. The item name in the vault folder equals the variable name; `secrets.extra` in `harness.json` adds more. Before, the tokens were typed in by hand on every device. Described in `integrations/bitwarden.md`.
- `bin/harness secrets --check` and the `doctor` section "Secret store": whether `bw` is installed, logged in, bound to the right server, which tokens the environment lacks — names only.
- The hook gives no vault values to the agent: `bin/harness secrets` without `--check`, `bw get`, `bw list items`, `bw unlock`, `bw export` are refused. The rule is in `rules/secrets.md`; the checks are in `bin/harness selfcheck`.
- `HARNESS_CONF` — the path to `harness.json` for the `selfcheck` checks.
- Registry of this installation: a new repository.

## [1.10.0] — 2026-10-16

### Changed

- `bin/harness docker-clean` by default removes only this session's resources and stopped resources without a session label: running containers of neighbour sessions no longer vanish in the middle of their tests. `--all` removes every harness resource — only on the owner's word. A resource's session is the `harness.session` label or the suffix of a compose project named `harness-<project>-<session>`; the session start hook sets `HARNESS_SESSION`. The rule is in `rules/docker.md`.
- `bin/harness docker-check` requires zeros only for this session and shows other sessions' and unlabelled resources separately; `doctor` warns about them.

## [1.9.4] — 2026-10-16

### Fixed

- The session start hook no longer hangs when Docker answers `docker info` but never finishes `docker ps`. Every Docker call in `doctor`, `docker-check`, `docker-clean` and `docker-up` has a time limit (10 s, `HARNESS_DOCKER_TIMEOUT`); a hung daemon gives the remark "Docker does not respond — restart Docker Desktop". Before, the session started without the harness context until the hook timed out. The check is in `bin/harness selfcheck`.

## [1.9.3] — 2026-10-16

### Changed

- Registry of this installation: a new repository, the deploy method of services updated.

## [1.9.2] — 2026-10-16

### Changed

- Registry of this installation: a repository renamed — the former name matched a common word and failed the leak check of the public build.

## [1.9.1] — 2026-10-16

### Changed

- `bin/harness task create --repo` puts the `repo:<name>` label in any project, not only in the default one: a repository's tasks are found with one view across all projects. The rule is in `rules/tasks.md`.
- Registry of this installation: a new repository.

## [1.9.0] — 2026-10-16

### Added

- Plane task commands: `bin/harness task create|state|comment|link|show|list`. The project is picked from the registry (`--repo`), the state by its group (`todo`, `started`, `done`…), the task and comment text comes from a Markdown or HTML file, without whitespace between tags. The commands walk through pages, wait at the request limit and check the text for AI attribution. Before, the agent wrote the API calls anew in every session. Described in `integrations/plane.md`.
- The `repo:<name>` label: a task about a repository in the default project gets it automatically, `task list --repo` shows the repository's tasks. The rule is in `rules/tasks.md`.
- `bin/harness tasks [--stale N]` — tasks in progress across all projects and how many days they have not moved. The session start hook reports the number of tasks that have not moved for more than 7 days; the count runs in the background and does not slow the start.

### Changed

- The `pr-create` skill: the request link is attached to the task in Plane (`task link`).

## [1.8.0] — 2026-10-15

### Added

- Secrets rule: a secret reaches a command only through a file or stdin, never as an argument like `--password=$(cat …)`. An argument shows in `ps`, and a program that does not know the option (busybox `wget`) prints it together with the value — that is how a password ended up in a session log and had to be rotated. A password-protected target is checked through what monitoring reports, not by a manual request. The rule is in `rules/secrets.md`.

## [1.7.11] — 2026-10-15

### Fixed

- `bin/harness worktree <name> <branch> --remove` deletes the branch of the working copy too when everything in it is in `origin`: the commits are pushed or merged, a squash merge included (checked with `git cherry` and `git patch-id`). Otherwise the branch stays and the command says why. Before, the branch always stayed, and the hook would not let it be deleted from a clone held by another session. Covered by `bin/harness selfcheck`, the rule is in `rules/git.md`.

## [1.7.10] — 2026-10-15

### Changed

- Registry of this installation: the notes of four links reflect that the former backup scheduler was removed.

## [1.7.9] — 2026-10-15

### Changed

- Registry of this installation: a new repository and its link to servers; three links changed how they are run, one changed its servers.

## [1.7.8] — 2026-10-15

### Changed

- Registry of this installation: a repository renamed; the leak-check exception that is no longer needed removed.

## [1.7.7] — 2026-10-15

### Changed

- Public build settings of this installation: a registry repository name that matches a common word is excluded from the leak check.

## [1.7.6] — 2026-10-15

### Changed

- Registry of this installation: a new repository.

## [1.7.5] — 2026-10-14

### Changed

- Registry of this installation: a new link between a repository and a server.

## [1.7.4] — 2026-10-14

### Changed

- Registry of this installation: the notes of one link say where the records of its zone are changed now.

## [1.7.3] — 2026-10-14

### Changed

- Registry of this installation: the links of the sites name the deploy webhook token variable differently.

## [1.7.2] — 2026-10-14

### Fixed

- The `guard-bash` hook took the closing parenthesis as part of the text file path when the command stood inside a `$(…)` substitution (for example, the request URL from `bin/harness mr`) and refused it. The test is in `bin/harness selfcheck`.

## [1.7.1] — 2026-10-14

### Fixed

- The comment on the update check in `bin/harness` no longer assumes the harness `origin` is always on GitHub.

## [1.7.0] — 2026-10-14

### Added

- The GitLab integration: the cheat sheet `.claude/integrations/gitlab.md`, the `GITLAB_TOKEN` token in the environment, the address in `integrations.gitlab.url` of `harness.json`.
- Commands `bin/harness forge` (where `origin` lives: gitlab, github or other), `mr` (a merge request from the current branch), `mr-status` (the pipeline and whether the request can be merged), `release-create` (a GitLab release for a pushed tag). Texts go only as a file; the commands refuse AI attribution themselves.
- `bin/harness selfcheck`: the "Texts of requests and releases" section — the hook refuses AI attribution in GitLab request and release texts and in GitHub PR texts.

### Changed

- The `guard-bash` hook checks the texts of `bin/harness mr` and `release-create` the same way as the texts of `gh pr`, `gh issue`, `gh release`.
- The `push` and `pr-create` skills pick GitHub or GitLab by `bin/harness forge`; descriptions are passed as a file.
- The `harness.md` rule: a release is created where the harness repository lives; file links in GitLab are `/-/blob/v<version>/<path>`.
- `bin/harness doctor`: the presence of `GITLAB_TOKEN` and, with `--deep`, a real request to GitLab; the "Git / GitHub" section became "Git".
- `repo-add`, `repo-remove`, `harness-doctor`, `release-public`, README: GitLab on a par with GitHub; the public harness stays on GitHub.

## [1.6.14] — 2026-10-14

### Changed

- Registry of this installation: five more repositories changed their address.

## [1.6.13] — 2026-10-14

### Changed

- Registry of this installation: a new link between a repository and a server.

## [1.6.12] — 2026-10-14

### Fixed

- A branch created with a name from a variable (`git switch -c "fix-$n"`) was not remembered by the hook, which then refused to delete it: the hook reads the new branch name from the command text. Such a command is now refused right away with a request to name the branch literally. The case is covered by `bin/harness selfcheck`.

## [1.6.11] — 2026-10-14

### Changed

- Registry of this installation: one more repository changed its address and description, its link deploys another way, and a server got its hosting data.

## [1.6.10] — 2026-10-14

### Changed

- Registry of this installation: the description of one repository and the notes of its service are brought up to date.

## [1.6.9] — 2026-10-14

### Changed

- Registry of this installation: one more repository changed its address.

## [1.6.8] — 2026-10-14

### Fixed

- The protection of clones from neighbouring sessions missed a clone whose path was built from a variable: `for r in …; do git -C repos/$r …`. Such a command passed unchecked and did not take the clone. Now `repos/$…` counts as work with the clones named in the command; `bin/harness selfcheck` has a test for it.

## [1.6.7] — 2026-10-14

### Changed

- Registry of this installation: one more repository changed its address, and its link gets the deploy webhook from another source.

## [1.6.6] — 2026-10-14

### Changed

- Registry of this installation: five more repositories changed their address, and their links get the deploy webhook from another source.

## [1.6.5] — 2026-10-14

### Changed

- Registry of this installation: two more repositories changed their address.

## [1.6.4] — 2026-10-14

### Changed

- Registry of this installation: one repository changed its address.

## [1.6.3] — 2026-10-14

### Changed

- Registry of this installation: a new server, a new repository and the link between them.

## [1.6.2] — 2026-10-13

### Fixed

- Refusing to delete a foreign branch ended in a shell error instead of a refusal in bash 3.2, the stock one on macOS (as in CI): in the message text a variable name stood right next to a guillemet, and the shell read it as part of the name. Variables in such places are now wrapped in braces.

## [1.6.1] — 2026-10-13

### Fixed

- The clone locks code now satisfies `shellcheck`: variables that shared their names with arrays in other functions are renamed, an unused variable is removed, conditions are written with `if`. The behaviour is unchanged; CI passes again.

## [1.6.0] — 2026-10-13

### Added

- Protection of the clones from parallel sessions. A session that starts changing a clone in `repos/` holds it; for another session the hook refuses git commands and file edits in that clone and offers a separate working copy. A clone on its main branch with no uncommitted changes is free. The rule is in [.claude/rules/git.md](i18n/en/rules/git.md), section "Neighbouring sessions".
- Commands `bin/harness worktree <name> <branch> [--remove]`, `bin/harness locks` and `bin/harness unlock <name>`.
- The `guard-edit` hook for the file editing tools: the same check as for Bash commands.
- Only the branches created in this session and named one by one can be deleted: the hook refuses deletion by a list, through a variable or with `xargs`.
- `bin/harness selfcheck` checks all of this with two mock sessions and throwaway clones.

## [1.5.10] — 2026-10-13

### Changed

- Registry of this installation: updated configuration of one server.

## [1.5.9] — 2026-10-12

### Changed

- Registry of this installation: one more link and an updated description of one project.

## [1.5.8] — 2026-10-12

### Changed

- Registry of this installation: one more link and an updated description of one project.

## [1.5.7] — 2026-10-12

### Changed

- Registry of this installation: a new link and an updated description of one project.

## [1.5.6] — 2026-10-12

### Changed

- Registry of this installation: two new links and an updated description of one project.

## [1.5.5] — 2026-10-12

### Changed

- Registry of this installation: a new project and a second address of one server. A server entry may now carry the optional `ipv4_extra` field — a list of additional IPv4 addresses.

## [1.5.4] — 2026-10-12

### Changed

- Registry of this installation: the descriptions of two links now mention name server monitoring.

## [1.5.3] — 2026-10-12

### Changed

- Settings of this installation: the Yandex Cloud integration is disabled — the `integrations.yandex_cloud` key is removed from `harness.json`. `bin/harness doctor` no longer checks the `yc` utility, its profile and access to the cloud. To enable it again, put the key back and log in with `yc init` (see `.claude/integrations/yandex-cloud.md`).

## [1.5.2] — 2026-10-12

### Changed

- Registry of this installation: the note of one bucket link brought up to date.

## [1.5.1] — 2026-10-12

### Changed

- Registry of this installation: the reverse record of one server's address now matches its name.

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
