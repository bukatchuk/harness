# Yandex Cloud

The integration is enabled if `harness.json` has the key `integrations.yandex_cloud`.

- Authorization: through the `yc` profile (`~/.config/yandex-cloud/config.yaml`). On a new device the owner runs `yc init` once and signs in through the browser; the `YC_TOKEN` variable is not used — `yc` does not read it from the environment, and signing in to the CLI with an OAuth token is deprecated.
- Check the sign-in: `yc config profile list` — there must be a profile marked `ACTIVE`. If there is no profile or a request answers `Unauthenticated`, tell the owner; do not run `yc init` yourself: it is interactive.
- CLI installation: https://yandex.cloud/ru/docs/cli/quickstart
- Documentation: https://yandex.cloud/ru/docs/cli/cli-ref/

## Usage

```bash
yc resource-manager cloud list --format json | jq '.[] | {id, name}'
yc resource-manager folder list --cloud-id <id> --format json | jq '.[] | {id, name}'
yc compute instance list --folder-id <id> --format json | jq '.[] | {id, name, status}'
```

## Rules

- Always specify `--folder-id` (or `--cloud-id`) explicitly: the `yc` profile on different devices may point to different folders.
- Always use `--format json` and select with `jq`.
- Reading (`list`, `get`) is free.
- Anything that creates, changes, stops or deletes resources, or changes access permissions, — only after the owner's confirmation with a list of the specific resources: it costs money and affects production infrastructure.
- Do not print secrets from responses (`yc lockbox payload get`, service account keys, `yc iam create-token`).
