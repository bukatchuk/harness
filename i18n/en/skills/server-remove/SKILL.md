---
name: server-remove
description: Remove a server from the harness registry (registry/servers.json) together with the references to it in links. Use when the owner says the server is decommissioned or should no longer be accessible to harness.
argument-hint: "<server>"
---

Remove a server from the registry. Arguments: $ARGUMENTS

1. Find the server: `bin/harness servers`. If the name is not there, ask the owner.
2. Show which links refer to it: `bin/harness map <server>`.
3. Explain the consequences:
   - only the registry entry is removed: the server itself, its services and data are not affected;
   - after removal harness does not connect to this server (see `.claude/rules/servers.md`);
   - if links refer to the server, with the `--unlink` flag it is removed from each of them; a link left with no servers is removed entirely — name such links by name.
4. **Ask for consent and wait for the answer.** If there are links, the consent must explicitly cover them too.
5. Remove: `bin/harness server-remove <server>` if there are no links; `bin/harness server-remove <server> --unlink` if there are and the owner agrees. Without `--unlink` the command refuses to remove a server that links refer to. Before changing anything, it saves a copy of the registry to `.harness-backup/`.
6. Verify: the server is not in `bin/harness servers`, `bin/harness doctor` reports no broken references.
7. If `registry/` is tracked in this harness's git, this is a change to harness: when committed, it raises the patch version.

Do not touch the host entry in `~/.ssh/known_hosts` or the keys: that is the owner's environment.
