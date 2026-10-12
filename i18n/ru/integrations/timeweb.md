# Timeweb Cloud

Хостинг: серверы, объектное хранилище S3, адреса. Интеграция включена, если в `harness.json` есть ключ `integrations.timeweb`.

- База API: `https://api.timeweb.cloud/api/v1`
- Авторизация: заголовок `Authorization: Bearer $TW_TOKEN`
- Токен выпускается в панели: «API и Terraform» → «Создать токен».
- Документация: https://timeweb.cloud/tools/api-docs

## Вызов

```bash
tw() { curl -sS --max-time 30 -H @<(printf 'Authorization: Bearer %s' "$TW_TOKEN") -H 'Content-Type: application/json' "https://api.timeweb.cloud/api/v1$1" "${@:2}"; }

tw /projects | jq '.projects[] | {id, name, description}'
tw /servers | jq '.servers[] | {id, name, status, location, availability_zone, cpu, ram, project_id, ips: [.networks[]?.ips[]?.ip]}'
tw /storages/buckets | jq '.buckets[] | {id, name, type, location, hostname, object_amount, used_mb: .disk_stats.used, project_id}'
tw /floating-ips | jq '.ips[] | {ip, ptr, resource_type, resource_id}'
tw /account/finances | jq '.finances | {currency, monthly_cost, hours_left}'
```

Другие виды ресурсов: `/databases`, `/balancers`, `/k8s/clusters`, `/network-drives`, `/firewall/groups`, `/domains`, `/ssh-keys`, `/images`, `/mail`, `/dedicated-servers`, `/container-registry`, `/apps`.

## Правила

- Ничего не создавай и не удаляй без ведома и явного распоряжения владельца на конкретный ресурс: серверы, бакеты, диски, адреса, базы, ключи доступа, проекты. То же — для изменений, которые стоят денег или затрагивают работающий ресурс: смена тарифа, перезагрузка, выключение, перенос между проектами.
- Читать (`GET`) можно свободно.
- Ответы содержат секреты: у серверов — `root_pass` и `vnc_pass`, у бакетов — `access_key` и `secret_key`. Всегда выбирай поля через `jq` поимённо, целиком ответ не выводи и в файлы не сохраняй.
- Данные о ресурсах записывай в реестр: у сервера — объект `timeweb` в `registry/servers.json`, у бакета — отдельная связь `s3-<бакет>` в `registry/services.json`. После изменений в хостинге сверь реестр с API.
- Бакет и ключ к нему для проекта создаёт владелец. Ключи одного проекта в другом не используй.
