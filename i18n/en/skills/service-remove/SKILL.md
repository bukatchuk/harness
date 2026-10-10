---
name: service-remove
description: Remove from the harness registry (registry/services.json) a link between a repository and a server. Use when the owner says the service is no longer deployed or the link was recorded by mistake.
argument-hint: "<service>"
---

Remove a link from the registry. Arguments: $ARGUMENTS

1. Show the owner what will be deleted: `bin/harness map <service>`. If the name is not found, show all links (`bin/harness map`) and clarify.
2. Explain the consequence: only the registry entry is removed. The service itself on the server and the repository stay as they are; after removal harness will no longer know where this service is configured from.
3. **Ask for consent and wait for the answer.**
4. Remove: `bin/harness service-remove <service>`. Before changing anything, the command saves a copy of the registry to `.harness-backup/`.
5. Verify: `bin/harness map <service>` reports `no links found`; `bin/harness doctor` reports no broken references.
6. If `registry/` is tracked in this harness's git, this is a change to harness: when committed, it raises the patch version.

Stopping and removing the service itself on the server is a separate action, only at a separate request of the owner and under the rules of `.claude/rules/servers.md`.
