# Yandex Cloud

Интеграция включена, если в `harness.json` есть ключ `integrations.yandex_cloud`.

- Авторизация: через профиль `yc` (`~/.config/yandex-cloud/config.yaml`). На новом устройстве владелец один раз выполняет `yc init` и входит через браузер; переменная `YC_TOKEN` не используется — `yc` её из окружения не читает, а вход по OAuth-токену в CLI устарел.
- Проверить вход: `yc config profile list` — должен быть профиль с пометкой `ACTIVE`. Профиля нет или запрос отвечает `Unauthenticated` — скажи владельцу, сам `yc init` не запускай: он интерактивный.
- Установка CLI: https://yandex.cloud/ru/docs/cli/quickstart
- Документация: https://yandex.cloud/ru/docs/cli/cli-ref/

## Вызов

```bash
yc resource-manager cloud list --format json | jq '.[] | {id, name}'
yc resource-manager folder list --cloud-id <id> --format json | jq '.[] | {id, name}'
yc compute instance list --folder-id <id> --format json | jq '.[] | {id, name, status}'
```

## Правила

- Всегда указывай `--folder-id` (или `--cloud-id`) явно: профиль `yc` на разных устройствах может смотреть в разные каталоги.
- Всегда `--format json` и выборка через `jq`.
- Читать (`list`, `get`) можно свободно.
- Всё, что создаёт, меняет, останавливает или удаляет ресурсы, а также меняет права доступа, — только после подтверждения владельца с перечнем конкретных ресурсов: это стоит денег и затрагивает боевую инфраструктуру.
- Не выводи секреты из ответов (`yc lockbox payload get`, ключи сервисных аккаунтов, `yc iam create-token`).
