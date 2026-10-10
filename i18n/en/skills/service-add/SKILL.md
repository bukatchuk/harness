---
name: service-add
description: Record in the harness registry (registry/services.json) a link — which repository is responsible for the configuration of which server or service on it. Use when the owner describes what is deployed where and where it is configured from.
argument-hint: "<repo> <server> [service]"
---

Add a link between a repository and a server. Arguments: $ARGUMENTS

1. Make sure both sides are in the registries: the repository in `registry/repos.json`, the server in `registry/servers.json`. Add what is missing first through `repo-add` or `server-add`.
2. Determine the kind of the link (`scope`):
   - `"service"` — the repository is responsible for one service on the server (an application, a site, a database, a VPN);
   - `"host"` — the repository configures the server itself: the system, users, firewall, base packages.
3. Add an entry to `registry/services.json` with `jq`, keeping the sort by name. Fields:
   - `name` — a unique name of the link, usually the service name (`shop-backend`, `vpn-eu`);
   - `scope` — `"service"` or `"host"`;
   - `description` — one line: what it is;
   - `repo` — the repository name from the registry, the configuration source;
   - `path` — the directory or file in the repository where the configuration lives, or `null`;
   - `servers` — a list of server names from the registry;
   - `runtime` — how it is run: `docker compose`, `systemd`, a static site, etc.;
   - `deploy` — how changes reach the server (for example, "tag → n8n → scripts/deploy.sh") or `null`;
   - `url` — the public address or `null`;
   - `notes` — anything important for work, or `null`.
4. Fill in `path`, `runtime` and `deploy` from facts — from the repository and, if needed, by reading from the server. Ask the owner about what you do not know; do not make it up.
5. Verify: `bin/harness map <name>` shows the link, `bin/harness doctor` reports no broken references.
6. If `registry/` is tracked in this harness's git, adding to the registry is a change to harness: when committed, it raises the patch version.

Add several links at once with a single registry edit.
