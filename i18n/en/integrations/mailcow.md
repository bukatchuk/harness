# mailcow

The mail server. The integration is enabled if `harness.json` has the `integrations.mailcow` key.

- The address is in `harness.json`: `integrations.mailcow.url`.
- API base: `<url>/api/v1`
- Authorization: the `X-API-Key: $MAILCOW_TOKEN` header
- The key is issued in the mailcow admin UI: System → Configuration → Access → API. A "Read-Write" key only works from the addresses listed there.
- Documentation: `<url>/api/` (the server's own Swagger).

## Calling

```bash
MAILCOW_URL="$(jq -r '.integrations.mailcow.url' harness.json)"
mc() { curl -sS --max-time 20 -H @<(printf 'X-API-Key: %s' "$MAILCOW_TOKEN") -H 'Content-Type: application/json' "$MAILCOW_URL/api/v1$1" "${@:2}"; }

mc /get/domain/all | jq '.[] | {domain_name, active, mboxes_in_domain, mboxes_left}'
mc /get/mailbox/all | jq '.[] | {username, name, active, quota}'
mc /get/alias/all | jq '.[] | {address, goto, active}'
```

Creating a mailbox (the quota is in megabytes):

```bash
jq -n --arg pw "$PW" '{local_part:"<name>", domain:"<domain>", name:"<display name>", quota:"1024", password:$pw, password2:$pw, active:"1", force_pw_update:"0", tls_enforce_in:"1", tls_enforce_out:"1"}' \
  | mc /add/mailbox -X POST -d @- | jq '.[] | {type, msg}'
```

## API specifics

- Success and failure both come with status 200: look at the `type` field (`success`, `danger`, `error`) of each response item.
- A request for an object that does not exist returns an empty object, not a 404.
- A request from an address that is not on the allowed list is refused with `api access denied` — that is not a key error.

## Rules

- Responses carry many fields: select the ones you need with `jq`.
- Generate a mailbox password yourself (`openssl rand`), keep it in a variable and pass it straight to where it is needed; do not print it or write it to repository files.
- Reading is free. Creating, changing and deleting mailboxes, aliases and domains — only after the owner's confirmation: this is production mail.
