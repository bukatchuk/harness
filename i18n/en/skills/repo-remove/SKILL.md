---
name: repo-remove
description: Remove a repository from the harness registry (registry/repos.json) and, at the owner's decision, its clone from repos/. Use when the owner says a project is no longer managed through harness.
argument-hint: "<repo>"
---

Remove a repository from the registry. Arguments: $ARGUMENTS

1. Find the project in the registry and look at the state of the clone: `bin/harness status`. Note whether there are modified files and unpushed commits.
2. Show which links refer to it: `bin/harness map <repo>`.
3. Explain the consequences:
   - the entry is removed from the registry; the remote repository on GitHub is not affected;
   - links in which this repository is the configuration source are removed entirely with the `--unlink` flag — name them by name;
   - the clone in `repos/<name>` stays on disk by default. Deleting it is a separate decision of the owner.
4. **Ask for consent and wait for the answer.** Ask about the clone separately. If the clone has modified files or unpushed commits, say so directly and give the numbers: deleting the clone will destroy that work with no way to recover it.
5. Remove: `bin/harness repo-remove <repo>` with the needed flags:
   - `--unlink` — also remove the links of this repository; without the flag the command refuses if there are links;
   - `--delete-clone` — delete the clone; the command refuses if it contains unsaved work;
   - `--force` — delete the clone even with unsaved work. Only after the owner's explicit consent to losing exactly that work.
   Before changing anything, the command saves a copy of the registry to `.harness-backup/`; clones are not copied there.
6. Verify: the project is not in `bin/harness status`, `bin/harness doctor` reports no broken references.
7. If `registry/` is tracked in this harness's git, this is a change to harness: when committed, it raises the patch version.
