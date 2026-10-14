---
name: release-public
description: Build and publish the open version of harness to the public repository — without the owner's data, with leak checks. Use when the owner asks to make a public release, and right after a release of the private repository if auto-publishing is on.
argument-hint: "[--push]"
---

Make a public harness release. Arguments: $ARGUMENTS

Publishing is irreversible: whatever reaches the public repository may have been copied. That is why building and pushing are two separate steps with consent between them. The consent may be given in advance: `release.auto_publish: true` in `harness.json`.

1. Make sure the release is ready: the working tree is clean, `VERSION` is not below 1.0.0, the current commit has the tag `v<version>`, `bin/harness selfcheck` passes.
2. Build: `bin/harness release-build`. The command takes only the files tracked at the tag, removes `harness.json`, `registry/` and the private changelog entries, adds a block with user data to `.gitignore`, and checks the result for leaks. The output is a directory and an archive in `dist/`.
3. If the check found a leak, stop. Show the owner the file and line, fix the source in the core (not in `dist/`), release a new version and build again. Adding a word to `release.allow_terms` in `harness.json` is allowed only by the owner's decision.
4. Show the owner what will go out: the number of files, `git diff --stat` against the public repository (printed by `bin/harness release-publish` without `--push`), the changelog entries of this version.
5. **Ask for consent to push and wait for the answer.** If auto-publishing is on (`release.auto_publish: true`), the consent is already given — do not ask, but stop and ask if `git diff --stat` shows files you did not expect in this version.
6. Push: `bin/harness release-publish --push`. The command adds one commit per release to the public repository, creates the tag `v<version>` and creates a GitHub release with the archive. The public repository stays on GitHub even when the private one lives in GitLab. It does not carry over the history of the private repository and does not rewrite anyone else's history.
7. Return the release link to the owner.

The address of the public repository is in `harness.json`: `release.public_repo`. If the key is absent, the command refuses to work.

If the public repository is several versions behind, release each of them in order: for every missed tag, build and push from a working copy of that tag (`git worktree add <dir> v<version>`); never newest first.
