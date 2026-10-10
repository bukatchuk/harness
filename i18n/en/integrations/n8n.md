# n8n

Automations. The integration is enabled if `harness.json` has the key `integrations.n8n`.

- The address is in `harness.json`: `integrations.n8n.url`.
- API base: `<url>/api/v1`
- Authorization: header `X-N8N-API-KEY: $N8N_TOKEN`
- The token is issued in n8n: Settings → n8n API.
- Documentation: https://docs.n8n.io/api/

## Usage

```bash
N8N_URL="$(jq -r '.integrations.n8n.url' harness.json)"
n8n() { curl -sS --max-time 20 -H @<(printf 'X-N8N-API-KEY: %s' "$N8N_TOKEN") -H 'Content-Type: application/json' "$N8N_URL/api/v1$1" "${@:2}"; }

n8n '/workflows?limit=50' | jq '.data[] | {id, name, active}'
n8n "/workflows/$ID" | jq '{name, active, nodes: [.nodes[] | {name, type}]}'
n8n "/executions?workflowId=$ID&status=error&limit=10" | jq '.data[] | {id, startedAt, stoppedAt}'
```

## Rules

- Workflow JSON is large and may contain credentials in node parameters: select fields with `jq`, do not print it whole and do not save it to repository files.
- Lists are paginated: `limit` and `cursor` (the `nextCursor` value from the response).
- Reading is free. Creating, editing, activating, deactivating, deleting and running a workflow — only after the owner's confirmation: these are production automations.
