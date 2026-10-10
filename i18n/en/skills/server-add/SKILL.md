---
name: server-add
description: Add a server to the harness registry (registry/servers.json) with an SSH sign-in check and collection of information about it. Use when the owner names a new server or gives a list of servers.
argument-hint: "<user@host[:port]> [name]"
---

Add a server to the registry. Arguments: $ARGUMENTS

1. Parse the address: user, host, port (22 by default). If an alias from `~/.ssh/config` is given, find the real values: `ssh -G <alias> | grep -E '^(hostname|user|port) '`. The default name is the short host name; it must be unique in the registry.
2. Check whether the host is known: `ssh-keygen -F <host>` (for a non-standard port, `ssh-keygen -F '[<host>]:<port>'`). If not, get the fingerprint with `ssh-keyscan -p <port> <host> 2>/dev/null | ssh-keygen -lf -`, show it to the owner and wait for confirmation. Only after that add the key to `~/.ssh/known_hosts`.
3. Check the sign-in: `ssh -o BatchMode=yes -o ConnectTimeout=10 -p <port> <user>@<host> true`. If it fails, report the reason (key, network, user) and stop; do not ask for passwords.
4. Collect the information with one command, read-only:
   `ssh -o BatchMode=yes -p <port> <user>@<host> 'hostname; . /etc/os-release && echo "$PRETTY_NAME"; nproc; free -h | sed -n 2p; df -h / | tail -1; command -v docker >/dev/null && docker ps --format "{{.Names}}" | head -30'`
5. Add an entry to `registry/servers.json` with `jq`, keeping the sort by name. Fields:
   - `name` — the short name of the server;
   - `host` — the DNS name or IP;
   - `port` — the SSH port;
   - `user` — the user to sign in as;
   - `env` — `"prod"`, `"stage"`, `"dev"` or `"lab"`;
   - `provider` — where it is hosted (Yandex Cloud, Hetzner, etc.) or `null`;
   - `location` — the location as "country code, city" (for example, `NL, Amsterdam`) or `null`;
   - `os` — the system, from facts;
   - `description` — one line: what this server is for;
   - `notes` — anything important for work, or `null`.
6. Fill in `os` from facts. Do not write into the server entry which repositories configure this server and its services — that is a separate registry of links, the `service-add` skill. Ask the owner about what you do not know (`env`, `provider`, `location`, purpose); do not make it up. Do not write secrets, keys and passwords into the registry.
7. Check the result: `bin/harness server-check <name>` and show the resulting entry.
8. If `registry/` is tracked in this harness's git, adding to the registry is a change to harness: when committed, it raises the patch version (see `.claude/rules/harness.md`).

Add several servers at once with a single registry edit. The rules for working on servers are in `.claude/rules/servers.md`.
