# Secrets and access

- Tokens live only in environment variables: `PLANE_TOKEN`, `N8N_TOKEN`, `GITGUARDIAN_TOKEN`, `MAILCOW_TOKEN`, `TW_TOKEN` — for the integrations enabled in `harness.json`. Access to Yandex Cloud is through the `yc` profile, with no token in the environment. How to use them is in `.claude/integrations/`.
- Never print token values: no `echo $TOKEN`, `env`, `printenv`, `set -x` near them. Check only presence (`[ -n "$PLANE_TOKEN" ]`).
- Do not write secrets into files, commits, messages, logs and request bodies to third-party services. A token is sent only to its own service.
- If you find a secret in code or history, stop and tell the owner; do not commit and do not "fix" it silently.
- If a token or access is missing, say so directly and continue the part of the work that does not need it. Do not look for workarounds or other people's credentials.
- Changing actions in external services (creating and deleting resources in Yandex Cloud, running and editing workflows in n8n, bulk changes in Plane, creating and deleting mailboxes and aliases in mailcow, any changes in Timeweb Cloud) — only after the owner's confirmation. Reading is free.
- In Timeweb Cloud, create or delete nothing without the owner's knowledge and explicit instruction for the specific resource.
