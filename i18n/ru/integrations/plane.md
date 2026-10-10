# Plane

Трекер задач. Интеграция включена, если в `harness.json` есть ключ `integrations.plane`.

- Адрес и рабочее пространство — в `harness.json`: `integrations.plane.url`, `integrations.plane.workspace`.
- База API: `<url>/api/v1`
- Авторизация: заголовок `X-API-Key: $PLANE_TOKEN`
- Токен выпускается в Plane: Profile Settings → Personal Access Tokens.
- Документация: https://developers.plane.so/api-reference/introduction

## Вызов

```bash
PLANE_URL="$(jq -r '.integrations.plane.url' harness.json)"
WS="$(jq -r '.integrations.plane.workspace' harness.json)"
plane() { curl -sS --max-time 20 -H @<(printf 'X-API-Key: %s' "$PLANE_TOKEN") -H 'Content-Type: application/json' "$PLANE_URL/api/v1$1" "${@:2}"; }

plane /users/me/ | jq '{id, email, display_name}'
plane "/workspaces/$WS/projects/" | jq '.results[] | {id, identifier, name}'
plane "/workspaces/$WS/projects/$PROJECT_ID/issues/?per_page=20" | jq '.results[] | {sequence_id, name, state, priority}'
```

`$WS` — slug рабочего пространства. Проект берётся из полей `plane_project` (идентификатор, например `SHOP`) и `plane_project_id` в `registry/repos.json`. Как выбрать проект для задачи и какой проект используется по умолчанию — в `.claude/rules/tasks.md`.

Ссылка на задачу для владельца: `<url>/<workspace>/browse/<ИДЕНТИФИКАТОР>-<номер>/`.

## Особенности API

- При создании задачи Plane игнорирует `state_id` и молча кладёт её в Backlog. После создания сделай `PATCH` с полем `state` (не `state_id`).
- Идентификаторы состояний свои у каждого проекта: бери их из `/workspaces/$WS/projects/$PROJECT_ID/states/`, не переноси из другого проекта.

## Правила

- Всегда выбирай поля через `jq`: ответы Plane объёмные, целиком в контекст их не выводи.
- Списки разбиты на страницы: `per_page` и `cursor`.
- Читать можно свободно. Создавать и менять задачи — по просьбе владельца; массовые изменения — после подтверждения.
- Ограничение — 60 запросов в минуту на токен.
