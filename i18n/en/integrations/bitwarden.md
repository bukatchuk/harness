# Secret store (Bitwarden or a compatible server)

The tokens of the harness integrations live in the owner's vault, not in files and not in git. The store is
enabled if `harness.json` has `secrets`:

```json
"secrets": {"provider": "bitwarden", "server": "<vault address>", "folder": "harness", "extra": ["ANOTHER_TOKEN"]}
```

- The folder `folder` holds one item per token. The item name equals the variable name (`PLANE_TOKEN`,
  `GITLAB_TOKEN`, …); the value is the password of a Login item or the text of a note.
- Which tokens are needed follows the enabled integrations (`plane`, `n8n`, `gitguardian`, `mailcow`, `gitlab`,
  `timeweb`, `umami`) and the `extra` list.
- The client is the Bitwarden CLI `bw`. It keeps an encrypted copy of the vault on the device: unlocking works
  without the server; the server is needed to log in on a new device and to receive changes.

## A new device (done by the owner)

```bash
brew install bitwarden-cli          # or npm i -g @bitwarden/cli
bw config server <vault address>
bw login                             # email, master password, two-step login
```

## Every session (done by the owner, before starting claude)

```bash
export BW_SESSION="$(bw unlock --raw)"
eval "$(bin/harness secrets)"
claude
```

A function in the shell profile can do the same in one command. The command prints no tokens to a terminal and
writes nothing to disk: the values only reach the environment of that shell.

## What the agent may do

- `bin/harness secrets --check` — whether the vault holds every needed item (names only).
- `bin/harness doctor` — whether `bw` is installed, logged in, bound to the right server, which tokens the
  environment lacks.
- Values are not given to the agent: the hook refuses `bin/harness secrets` without `--check`, `bw get`,
  `bw list items`, `bw unlock`, `bw export`. A token is missing — tell the owner which one and what to run.

## Changing a token

The owner changes the item value in the vault; every device gets the new token on the next
`eval "$(bin/harness secrets)"` (the command syncs the copy first).
