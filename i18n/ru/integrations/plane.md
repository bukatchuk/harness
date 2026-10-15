# Plane

Трекер задач. Интеграция включена, если в `harness.json` есть ключ `integrations.plane`.

- Адрес, рабочее пространство и проект по умолчанию — в `harness.json`: `integrations.plane.url`, `workspace`, `default_project_id`.
- Авторизация: `PLANE_TOKEN` в окружении. Токен выпускается в Plane: Profile Settings → Personal Access Tokens.
- Документация API: https://developers.plane.so/api-reference/introduction

## Команды harness

Задачи веди командами `bin/harness`, а не прямыми запросами к API: они сами выбирают проект по реестру, находят состояние по группе, переводят текст в HTML, листают страницы и ждут при лимите запросов.

```bash
bin/harness task create --title "<заголовок>" --body-file /абсолютный/путь.md [--repo <имя> | --project <ПРОЕКТ>] [--parent <ПРОЕКТ-N>] [--state todo] [--priority medium]
bin/harness task state <ПРОЕКТ-N> started            # backlog, todo, started, done, cancelled
bin/harness task comment <ПРОЕКТ-N> --body-file /абсолютный/путь.md
bin/harness task link <ПРОЕКТ-N> <url> [--title "<название>"]   # MR, релиз, конвейер
bin/harness task show <ПРОЕКТ-N>
bin/harness task list [--repo <имя> | --project <ПРОЕКТ>] [--state open|all|started|…] [--limit N]
bin/harness tasks [--stale 7]                        # задачи в работе по всем проектам и дни без движения
```

- `--repo` выбирает проект репозитория из реестра. В проекте по умолчанию, где лежат задачи многих репозиториев, задача получает метку `repo:<имя>`; метка создаётся, если её нет. `task list --repo <имя>` показывает задачи по этой метке.
- Текст — файл в Markdown (абзацы, заголовки `#`, списки `-` и `1.`, `` `код` ``, `**жирный**`) или готовый HTML. Хук и сама команда проверяют его на AI-атрибуцию.
- Задача указывается как `ПРОЕКТ-номер`, например `SHOP-12`; ссылку печатают `create` и `show`.
- Задачи в работе без движения дольше 7 дней называет хук на старте сессии; список — `bin/harness tasks --stale 7`.

## Прямые запросы к API

Нужны для того, чего команды не умеют. База — `<url>/api/v1/workspaces/<workspace>`, заголовок `X-API-Key: $PLANE_TOKEN`.

- `GET /work-items/<ПРОЕКТ-N>/` — задача по номеру.
- `fields=id,name,state,updated_at` — только нужные поля: ответ легче и быстрее; `expand=state` — состояние объектом с полем `group`.
- Фильтров по состоянию у списка нет: фильтруй через `jq`.
- При создании задачи Plane игнорирует состояние и кладёт её в Backlog — состояние меняется отдельным `PATCH` с полем `state`.
- В HTML не должно быть пробелов и переносов между тегами: Plane превращает их в пустые пункты списка.

## Правила

- Выбирай поля через `jq` или `fields`: ответы Plane объёмные, целиком в контекст их не выводи.
- Читать можно свободно. Создавать и менять задачи — по просьбе владельца и по `.claude/rules/tasks.md`; массовые изменения — после подтверждения.
- Ограничение — 60 запросов в минуту на токен.
