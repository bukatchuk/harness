---
name: pr-create
description: Create a GitHub pull request or a GitLab merge request for a project from repos/ or for harness, without AI attribution. Use when the owner asks to open a PR or an MR.
argument-hint: "[project] [base branch]"
---

Create a pull request. Arguments: $ARGUMENTS

1. Determine the repository and the branch. If the current branch is the main one, first create a working branch: `git -C <path> switch -c <type>/<short-summary>`.
2. Check the commits: `bin/harness check-commits <path>`. On `FAIL`, stop and report.
3. Push the branch: `git -C <path> push -u origin <branch>`.
4. Compose the description from all the commits of the branch, not only the last one: `git -C <path> log --oneline <base>..HEAD` and `git -C <path> diff --stat <base>...HEAD`.
5. If the project has a template (`.github/pull_request_template.md`, `.gitlab/merge_request_templates/`), follow it. Otherwise the structure is:
   - **What and why** — 1–3 sentences.
   - **Changes** — a list of the essentials.
   - **How to verify** — steps or commands.
   - A link to the task in Plane, if known.
6. Put the description in a file and create the request where the repository lives (`bin/harness forge <path>`). No "Generated with …" and no 🤖.
   - `github` — from the repository directory: `gh pr create --base <base> --title "<title>" --body-file <file>`;
   - `gitlab` — `bin/harness mr <path> --base <base> --title "<title>" --body-file <file>`.
7. Return the request link to the owner. The pipeline state in GitLab: `bin/harness mr-status <path> <number>`.

Merging is a separate action: when the owner asks, or by the project's rules if they allow merging on a green pipeline.
