# mailcow

Почтовый сервер. Интеграция включена, если в `harness.json` есть ключ `integrations.mailcow`.

- Адрес — в `harness.json`: `integrations.mailcow.url`.
- База API: `<url>/api/v1`
- Авторизация: заголовок `X-API-Key: $MAILCOW_TOKEN`
- Ключ выпускается в админке mailcow: Система → Конфигурация → Доступ → API. Ключ «Чтение и запись» действует только с адресов, перечисленных там же.
- Документация: `<url>/api/` (Swagger самого сервера).

## Вызов

```bash
MAILCOW_URL="$(jq -r '.integrations.mailcow.url' harness.json)"
mc() { curl -sS --max-time 20 -H @<(printf 'X-API-Key: %s' "$MAILCOW_TOKEN") -H 'Content-Type: application/json' "$MAILCOW_URL/api/v1$1" "${@:2}"; }

mc /get/domain/all | jq '.[] | {domain_name, active, mboxes_in_domain, mboxes_left}'
mc /get/mailbox/all | jq '.[] | {username, name, active, quota}'
mc /get/alias/all | jq '.[] | {address, goto, active}'
```

Создание ящика (квота — в мегабайтах):

```bash
jq -n --arg pw "$PW" '{local_part:"<имя>", domain:"<домен>", name:"<подпись>", quota:"1024", password:$pw, password2:$pw, active:"1", force_pw_update:"0", tls_enforce_in:"1", tls_enforce_out:"1"}' \
  | mc /add/mailbox -X POST -d @- | jq '.[] | {type, msg}'
```

## Особенности API

- Успех и ошибка приходят с кодом 200: смотри поле `type` (`success`, `danger`, `error`) в каждом элементе ответа.
- Запрос несуществующего объекта возвращает пустой объект, а не 404.
- Запрос с адреса, которого нет в списке разрешённых, получает отказ `api access denied` — это не ошибка ключа.

## Правила

- Ответы содержат много полей: выбирай нужные через `jq`.
- Пароль ящика генерируй сам (`openssl rand`), держи в переменной и передавай сразу туда, где он нужен; не выводи и не записывай в файлы репозиториев.
- Читать можно свободно. Создание, изменение и удаление ящиков, алиасов и доменов — только после подтверждения владельца: это боевая почта.
