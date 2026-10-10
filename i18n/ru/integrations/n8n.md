# n8n

Автоматизации. Интеграция включена, если в `harness.json` есть ключ `integrations.n8n`.

- Адрес — в `harness.json`: `integrations.n8n.url`.
- База API: `<url>/api/v1`
- Авторизация: заголовок `X-N8N-API-KEY: $N8N_TOKEN`
- Токен выпускается в n8n: Settings → n8n API.
- Документация: https://docs.n8n.io/api/

## Вызов

```bash
N8N_URL="$(jq -r '.integrations.n8n.url' harness.json)"
n8n() { curl -sS --max-time 20 -H @<(printf 'X-N8N-API-KEY: %s' "$N8N_TOKEN") -H 'Content-Type: application/json' "$N8N_URL/api/v1$1" "${@:2}"; }

n8n '/workflows?limit=50' | jq '.data[] | {id, name, active}'
n8n "/workflows/$ID" | jq '{name, active, nodes: [.nodes[] | {name, type}]}'
n8n "/executions?workflowId=$ID&status=error&limit=10" | jq '.data[] | {id, startedAt, stoppedAt}'
```

## Правила

- JSON workflow большой и может содержать учётные данные в параметрах узлов: выбирай поля через `jq`, целиком не выводи и в файлы репозиториев не сохраняй.
- Списки разбиты на страницы: `limit` и `cursor` (значение `nextCursor` из ответа).
- Читать можно свободно. Создание, правка, активация, деактивация, удаление и запуск workflow — только после подтверждения владельца: это боевые автоматизации.
