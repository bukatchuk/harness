# Plane

Task tracker. The integration is enabled if `harness.json` has the key `integrations.plane`.

- The address and the workspace are in `harness.json`: `integrations.plane.url`, `integrations.plane.workspace`.
- API base: `<url>/api/v1`
- Authorization: header `X-API-Key: $PLANE_TOKEN`
- The token is issued in Plane: Profile Settings → Personal Access Tokens.
- Documentation: https://developers.plane.so/api-reference/introduction

## Usage

```bash
PLANE_URL="$(jq -r '.integrations.plane.url' harness.json)"
WS="$(jq -r '.integrations.plane.workspace' harness.json)"
plane() { curl -sS --max-time 20 -H @<(printf 'X-API-Key: %s' "$PLANE_TOKEN") -H 'Content-Type: application/json' "$PLANE_URL/api/v1$1" "${@:2}"; }

plane /users/me/ | jq '{id, email, display_name}'
plane "/workspaces/$WS/projects/" | jq '.results[] | {id, identifier, name}'
plane "/workspaces/$WS/projects/$PROJECT_ID/issues/?per_page=20" | jq '.results[] | {sequence_id, name, state, priority}'
```

`$WS` is the workspace slug. The project comes from the fields `plane_project` (the identifier, for example `SHOP`) and `plane_project_id` in `registry/repos.json`. How to choose a project for a task and which project is the default is in `.claude/rules/tasks.md`.

Link to a task for the owner: `<url>/<workspace>/browse/<IDENTIFIER>-<number>/`.

## API quirks

- When a task is created, Plane ignores `state_id` and silently puts it in Backlog. After creating, do a `PATCH` with the field `state` (not `state_id`).
- State identifiers are specific to each project: take them from `/workspaces/$WS/projects/$PROJECT_ID/states/`, do not carry them over from another project.

## Rules

- Always select fields with `jq`: Plane responses are large, do not print them whole into the context.
- Lists are paginated: `per_page` and `cursor`.
- Reading is free. Create and change tasks when the owner asks; bulk changes only after confirmation.
- The limit is 60 requests per minute per token.
