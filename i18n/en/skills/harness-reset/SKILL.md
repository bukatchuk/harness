---
name: harness-reset
description: Reset harness to its initial state — remove all repositories, servers and links from the registry. Use only at the owner's direct request to reset harness or start with a clean registry.
argument-hint: "[--delete-clones]"
---

Reset the harness registry. Arguments: $ARGUMENTS

This is the most destructive action in harness. Do not perform it on indirect signs ("clean up", "tidy up") — only at a direct request for a reset.

1. Show what will be deleted: `bin/harness reset` without `--yes` changes nothing and prints a plan — how many repositories, servers and links are in the registry and in what state the clones are.
2. Explain to the owner what is reset and what stays:
   - all entries in `registry/repos.json`, `registry/servers.json`, `registry/services.json` are deleted;
   - the settings in `harness.json` (owner, language, integrations), the rules and the skills stay;
   - servers, the services on them and the remote repositories are not affected;
   - the clones in `repos/` stay on disk unless `--delete-clones` is given.
3. If the owner wants to delete the clones too, name by name those that have modified files or unpushed commits (they are visible in the plan). With `--delete-clones` such clones are skipped and stay on disk; they can be deleted only with `--force`, after the owner's explicit consent to losing that work.
4. **Ask for consent and wait for the answer.** The consent must name the reset directly; a "yes" in reply to a different question does not count.
5. Run: `bin/harness reset --yes` (add `--delete-clones` and, if agreed, `--force`). Before changing anything, the command saves a copy of the three registry files to `.harness-backup/<timestamp>/`.
6. Verify: `bin/harness status`, `bin/harness servers`, `bin/harness map` are empty; `bin/harness doctor` reports no errors.
7. Report the result with numbers "before → after", the path to the backup and the list of clones that stayed on disk.
8. If `registry/` is tracked in this harness's git, this is a change to harness: when committed, it raises the major version — the old registry state is unavailable after it.

The registry can be restored by copying the files from `.harness-backup/<timestamp>/` back to `registry/` and running `bin/harness sync`.
