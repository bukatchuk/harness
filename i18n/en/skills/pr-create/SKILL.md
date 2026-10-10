---
name: pr-create
description: Create a pull request on GitHub for a project from repos/ or for harness, without AI attribution. Use when the owner asks to open a PR.
argument-hint: "[project] [base branch]"
---

Create a pull request. Arguments: $ARGUMENTS

1. Determine the repository and the branch. If the current branch is the main one, first create a working branch: `git -C <path> switch -c <type>/<short-summary>`.
2. Check the commits: `bin/harness check-commits <path>`. On `FAIL`, stop and report.
3. Push the branch: `git -C <path> push -u origin <branch>`.
4. Compose the description from all the commits of the branch, not only the last one: `git -C <path> log --oneline <base>..HEAD` and `git -C <path> diff --stat <base>...HEAD`.
5. If the project has a PR template (`.github/pull_request_template.md`), follow it. Otherwise the structure is:
   - **What and why** — 1–3 sentences.
   - **Changes** — a list of the essentials.
   - **How to verify** — steps or commands.
   - A link to the task in Plane, if known.
6. Create the PR from the repository directory: `gh pr create --base <base> --title "<title>" --body "<description>"`. No "Generated with …" and no 🤖.
7. Return the PR link to the owner.

Merging a PR is a separate action, only at the owner's request.
