---
name: service-remove
description: Remove from the harness registry (registry/services.json) a link between a repository and a server. Use when the owner says the service is no longer deployed or the link was recorded by mistake, and for full decommissioning of a service (server, proxy, DNS, repository).
argument-hint: "<service>"
---

Remove a link from the registry. Arguments: $ARGUMENTS

1. Show the owner what will be deleted: `bin/harness map <service>`. If the name is not found, show all links (`bin/harness map`) and clarify.
2. Explain the consequence: only the registry entry is removed. The service itself on the server and the repository stay as they are; after removal harness will no longer know where this service is configured from.
3. **Ask for consent and wait for the answer.**
4. Remove: `bin/harness service-remove <service>`. Before changing anything, the command saves a copy of the registry to `.harness-backup/`.
5. Verify: `bin/harness map <service>` reports `no links found`; `bin/harness doctor` reports no broken references.
6. If `registry/` is tracked in this harness's git, this is a change to harness: when committed, it raises the patch version.

## Full decommissioning of a service

If the owner closes a service entirely (server, repository, domain), removing the entry is the last step. First find every trace: `bin/harness map <service>`, a search for the name and domain across all clones (`grep -rIl <domain> repos/`), the server (containers, directories, keys, certificates), the task tracker. Give the owner a plan with the list of actions step by step; changing steps follow `.claude/rules/servers.md`, each irreversible one comes with a rollback or a copy. Warn neighbouring sessions that use the service in advance.

Order matters — each step must not break the next one:

1. **Links to the service** in other projects (site menus and footers, README, examples) — through their normal release process.
2. **Monitoring** — probes, targets, alerts, key tables. Before stopping, otherwise false alerts fire.
3. **Entry proxy** — the domain configuration. Before deleting the certificate: a proxy that refers to a deleted certificate fails its configuration test.
4. **Server:** containers, all images of the service (not only the current tag) and its network, the deployment directory, deploy keys in `authorized_keys` (copy the file before editing), the certificate. If compose requires variables set by the deploy script, `docker compose down` fails — stop by container name and check the result, not the exit code of a command pipeline.
5. **DNS** — the domain record, a higher zone serial; check — `NXDOMAIN` from every name server.
6. **Repository:** a full copy (`git bundle create <file> --all`, `git bundle verify`), upload to the owner's backup storage and a checksum comparison of the copy downloaded back; then delete the project at the code host and its mirrors. GitLab deletes a project with a delay (renames it to `…-deletion_scheduled-<id>`) — for good: a second `DELETE /projects/<id>` with `permanently_remove=true` and `full_path`. Deleting on GitHub needs `gh` with the `delete_repo` scope; if it is missing, tell the owner.
7. **harness registry:** `bin/harness service-remove <service>`, then `bin/harness repo-remove <repository> --unlink --delete-clone`; mentions in other projects' `.claude`; a harness release.
8. **Tasks** about the service in the tracker — close with a comment as the owner decides.

After each step check that neighbouring services on the same server answer as before.
