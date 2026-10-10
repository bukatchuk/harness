---
name: repo-sync
description: Clone the missing and update the existing repositories from the harness registry. Use on a new device, at the start of work on a project, or when the owner asks to sync repositories.
argument-hint: "[project]"
---

Sync the repositories. Arguments: $ARGUMENTS

1. Run `bin/harness sync` (or `bin/harness sync <name>` for one project).
2. The script is safe for local work: it clones what is missing, and updates what exists only when the tree is clean and only by fast-forward. Everything else it marks `fetch only` and does not touch.
3. For repositories marked `fetch only` or `ERROR`, show the details: `bin/harness status`. Do not run `stash`, `reset`, `rebase` yourself; offer the owner the options.
4. Report briefly: how many were cloned, how many updated, what needs attention.
