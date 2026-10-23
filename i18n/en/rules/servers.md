# Servers

The servers harness has access to are listed in `registry/servers.json`. List: `bin/harness servers`; sign-in check: `bin/harness server-check [name]`.

## Where a server is configured from

- The links "repository → server → service" are recorded in `registry/services.json`. Before any work with a server or service, look at them: `bin/harness map <server | repo | service>`.
- The source of truth for configuration is the repository from the link. Change the configuration there and deliver it by the method in the `deploy` field; do not edit it on the server itself.
- If a server has a service but there is no link for it, tell the owner and offer to record one through the `service-add` skill.

## How to connect

- Only over SSH and only with a key from the owner's environment (ssh-agent, `~/.ssh/config`). Keys, passwords and passphrases are not stored in harness, not requested and not printed.
- Always non-interactively: `ssh -o BatchMode=yes -o ConnectTimeout=10 -p <port> <user>@<host> '<command>'`. Without `-A` (agent forwarding) and without `-t` unless the task needs it.
- Do not accept the key of an unknown host yourself: show the owner the fingerprint and wait for confirmation (this is a step of the `server-add` skill).
- Do not connect to a server that is not in the registry — first add it through `server-add`.

## What you may do

- Reading is free: the state of services and containers, logs, metrics, configuration, free space.
- Anything that changes the server — only after the owner's confirmation with a list of the specific actions: restarting and stopping services and containers, editing configuration, installing and updating packages, deleting files, changing firewall rules, users and keys, rebooting.
- On servers with `"env": "prod"`, additionally state what exactly the action will affect and how to roll it back.
- Deliver code and image changes through the project's standard pipeline (commit → tag → deploy), not by manual commands on the server. A manual edit in production is only an urgent measure by the owner's decision, and it must be carried over to the repository immediately.

## Output and secrets

- Limit output: `tail -n`, `journalctl -n`, `docker logs --tail`, `grep`. Do not pull whole logs into the context.
- Do not print secrets from the server: `.env`, private keys, dumps of container environment variables (`docker inspect`, `printenv`). If you need to check a variable, check presence, not the value.
- Do not copy anything from the server into repositories without the owner's request.

## Maintenance window

This rule applies if `maintenance.window` is set in `harness.json` (time in the `maintenance.timezone` zone).

- Work with downtime that can be postponed waits for the window: reboots for kernels and libraries, Docker Engine updates, updates that restart databases, minor updates of large services. An urgent security fix does not wait for the window — by the owner's decision.
- Each window gets a task in the tracker. Before the window, fill it from monitoring (servers waiting for a reboot, pending packages) and from open update MRs: server, action, what it affects, rollback.
- In the window: before the first command — an alert silence, if monitoring has one; servers one at a time, after each — check the services and monitoring targets; servers sharing one role (name servers, VPN) — not at the same time.
- The "before → after" result goes into the window task; when closing it, open a task for the next window.
