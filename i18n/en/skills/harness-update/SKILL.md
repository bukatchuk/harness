---
name: harness-update
description: Update the harness configuration to the version from origin within the current session, without a restart and only with the owner's consent. Use when an available update was reported at start or the owner asks to update harness.
---

Update harness in the running session. Run all commands in the harness root.

1. Get the fresh state of origin: `git fetch origin`. If the command fails, show the owner the error text and stop: without a connection to origin there is nothing to update from.
2. Compare versions: `bin/harness version`. If there is no `update available` line, double-check directly: `git rev-list --count HEAD..origin/main`. Zero means there really is no update; say so and stop.
3. Check that the update will go through cleanly:
   - `git status --short` — with uncommitted changes, stop and ask the owner what to do with them;
   - `git rev-list --count origin/main..HEAD` — if it is not zero, there are unpushed commits locally: a fast-forward is impossible, stop and report.
4. Show the owner what will change, without loading extra into the context:
   - `git log --oneline HEAD..origin/main`
   - new changelog entries: `git diff HEAD..origin/main -- CHANGELOG.md`
   - affected files: `git diff --stat HEAD..origin/main`
5. **Ask for consent and wait for the answer.** Without an explicit "yes", change nothing.
6. Remember the current commit (`git rev-parse HEAD`) and update: `git pull --ff-only`. If the command fails, stop and explain; do not run `merge`, `rebase` or `reset`.
7. Update the copy of the rules and skills in the selected language: `bin/harness lang`.
8. Apply the new files in the current session:
   - `CLAUDE.md` and `.claude/rules/*.md` are not re-read on their own — read again each file changed in `git diff --name-only <old-commit>..HEAD` and follow the new version from then on;
   - skills, hooks and permissions from `.claude/settings.json` are picked up automatically; a new skill may appear in the list with a delay — if it is not there, ask the owner to run `/reload-skills`.
9. Pull in the projects that appeared in the registry: `bin/harness sync`. Then `bin/harness doctor`: the new version may have added dependencies.
10. Report: "before vX → after vY", what changed in the rules and what of that affects the current task. Subagents launched earlier work on the old version — say so if there are any.
