---
name: commit
description: Commit changes in harness or in a project from repos/ in the owner's name, without AI attribution. Use when the owner asks to make a commit.
argument-hint: "[project] [commit note]"
---

Make a commit. Arguments: $ARGUMENTS

1. Determine the repository: the project in `repos/<name>` whose files changed, or harness itself. If there are changes in several repositories, these are separate commits, one per repository; name all of them to the owner.
2. Look at the state: `git -C <path> status --short` and `git -C <path> diff --stat`. Read the full diff only for files whose changes you do not already understand.
3. Check that nothing extra gets into the index: secrets, `.env`, build artifacts, unrelated edits. If you find a secret, stop and report it.
4. If `ggshield` is installed and `GITGUARDIAN_TOKEN` is set, check the changes after staging them: `GITGUARDIAN_API_KEY="$GITGUARDIAN_TOKEN" ggshield secret scan pre-commit` (run in the repository directory).
5. Add files by name: `git -C <path> add <files>`.
6. Compose the message per `.claude/rules/git.md`: the project's style from `git log --oneline -10`, otherwise Conventional Commits.
7. If this is harness, before committing raise `VERSION`, add an entry to `CHANGELOG.md` and `CHANGELOG.en.md`, and include all three files in the index: every commit raises the version (see `.claude/rules/harness.md`).
8. Commit: `git -C <path> commit -m "<title>" -m "<body>"`. No `--author`, no `--no-verify`, no AI trailers. For harness, immediately create an annotated tag with a description in the owner's language: `git tag -a v<version> -m "<what changed>"`.
9. Show the result: `git -C <path> log -1 --format='%h %an <%ae> %s'`.

Do not push until the owner asks.
