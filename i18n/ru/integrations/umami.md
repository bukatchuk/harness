# Umami

Веб-аналитика сайтов. Интеграция включена, если в `harness.json` есть ключ `integrations.umami`.

- Адрес — в `harness.json`: `integrations.umami.url`.
- База API: `<url>/api`
- Авторизация: заголовок `Authorization: Bearer $UMAMI_TOKEN`
- Ключ API выпускается в панели: Settings → Profile → API keys. Ключ действует от имени выпустившего его пользователя, но не даёт доступа к паролю, двухэтапной проверке, пользователям и другим ключам.
- Документация: https://umami.is/docs/api

## Вызов

```bash
UMAMI_URL="$(jq -r '.integrations.umami.url' harness.json)"
um() { curl -sS --max-time 20 -H @<(printf 'Authorization: Bearer %s' "$UMAMI_TOKEN") -H 'Content-Type: application/json' "$UMAMI_URL/api$1" "${@:2}"; }

um /websites | jq '.data[] | {id, name, domain}'
um "/websites/<id>/stats?startAt=$(( ($(date +%s) - 86400) * 1000 ))&endAt=$(( $(date +%s) * 1000 ))" | jq
```

Завести сайт:

```bash
jq -n '{name:"<имя>", domain:"<домен без схемы>"}' | um /websites -X POST -d @- | jq '{id, name, domain}'
```

## Подключить сайт

1. Проверь, нет ли сайта уже (`um /websites`), и только потом заводи. `id` ответа — Website ID.
2. Скрипт в `<head>`, только в production-сборке:

   ```html
   <script defer src="<url>/<скрипт>" data-website-id="<Website ID>" data-domains="<домен>"></script>
   ```

   Имя скрипта и адрес приёма событий у установки могут отличаться от стандартных `script.js` и `/api/send`: смотри `integrations.umami.script` в `harness.json` и README репозитория установки.
3. Если у сайта есть Content-Security-Policy, добавь адрес Umami в `script-src` и `connect-src`.
4. Проверь после выкладки: страница сайта отдаёт скрипт, а в `um "/websites/<id>/active"` или в панели появляется посетитель.

## Правила

- Читать можно свободно. Создание сайтов — по правилу `analytics` или по просьбе владельца; удаление сайтов и их данных — только по слову владельца.
- Website ID не секрет: он виден в коде страницы. Ключ API — секрет.
