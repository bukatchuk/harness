---
name: push
description: Push commits of harness or of a project from repos/ to the remote repository with an authorship check. Use when the owner asks to push.
argument-hint: "[project]"
---

Push the commits. Arguments: $ARGUMENTS

1. Determine the repository (a project in `repos/<name>` or harness itself) and the current branch: `git -C <path> rev-parse --abbrev-ref HEAD`.
2. Check the outgoing commits: `bin/harness check-commits <path>`. If there is a `FAIL`, do not push; show the owner what is wrong and propose a fix.
3. Show what will go out: `git -C <path> log --oneline @{u}..HEAD` (if there is no upstream, `git log --oneline -10`).
4. Check against the project rules: how changes are made (a direct push or a branch and a PR, branch naming, deploy) is described in its `CLAUDE.md` or `.claude/CLAUDE.md`; the harness registry does not hold it. If changes go through a PR and the current branch is the main one, do not push directly: propose a branch and a PR through the `pr-create` skill. If the project does not describe it, ask the owner and offer to record the answer in the project `CLAUDE.md`.
5. Push: `git -C <path> push` (for a new branch, `git push -u origin <branch>`). For harness, push the version tag too: `git push origin <branch> v<version>`; a push of commits without a version bump is rejected by the git hook.
6. If the push is rejected because the remote branch has moved ahead, run `git pull --rebase` and repeat. `--force` and `--force-with-lease` only with the owner's explicit consent to that specific push.
7. For harness, create a release for each pushed tag. The description is in the owner's language, lists all functionality changes with links to md files; the format is in `.claude/rules/harness.md`. Put it in a file and pass the absolute path. `bin/harness forge .` shows where to create it:
   - `github` — `gh release create v<version> --verify-tag --title "v<version> — <summary>" --notes-file <file>`;
   - `gitlab` — `bin/harness release-create . v<version> --title "v<version> — <summary>" --notes-file <file>`.
8. For harness: if `harness.json` has `release.auto_publish: true`, release this version publicly right away through the `release-public` skill — without a reminder from the owner.
9. Report the result: the branch, the number of pushed commits, the link to the repository or release; for harness, also the link to the public release.
