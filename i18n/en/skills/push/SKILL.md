---
name: push
description: Push commits of harness or of a project from repos/ to the remote repository with an authorship check. Use when the owner asks to push.
argument-hint: "[project]"
---

Push the commits. Arguments: $ARGUMENTS

1. Determine the repository (a project in `repos/<name>` or harness itself) and the current branch: `git -C <path> rev-parse --abbrev-ref HEAD`.
2. Check the outgoing commits: `bin/harness check-commits <path>`. If there is a `FAIL`, do not push; show the owner what is wrong and propose a fix.
3. Show what will go out: `git -C <path> log --oneline @{u}..HEAD` (if there is no upstream, `git log --oneline -10`).
4. Check against the registry: if the project has `"flow": "pr"` and the current branch is the main one, do not push directly. Propose a branch and a PR through the `pr-create` skill. If `flow` is not set (`null`), ask the owner how changes are made to this project and record the answer in the registry.
5. Push: `git -C <path> push` (for a new branch, `git push -u origin <branch>`). For harness, push the version tag too: `git push origin <branch> v<version>`; a push of commits without a version bump is rejected by the git hook.
6. If the push is rejected because the remote branch has moved ahead, run `git pull --rebase` and repeat. `--force` and `--force-with-lease` only with the owner's explicit consent to that specific push.
7. For harness, create a release for each pushed tag: `gh release create v<version> --verify-tag --title "v<version> — <summary>" --notes "<description>"`. The description is in the owner's language, lists all functionality changes with links to md files; the format is in `.claude/rules/harness.md`.
8. Report the result: the branch, the number of pushed commits, the link to the repository or release.
