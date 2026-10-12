# Timeweb Cloud

Hosting: servers, S3 object storage, addresses. The integration is enabled if `harness.json` has the `integrations.timeweb` key.

- API base: `https://api.timeweb.cloud/api/v1`
- Authorization: the `Authorization: Bearer $TW_TOKEN` header
- The token is issued in the panel: "API and Terraform" → "Create token".
- Documentation: https://timeweb.cloud/tools/api-docs

## Calling

```bash
tw() { curl -sS --max-time 30 -H @<(printf 'Authorization: Bearer %s' "$TW_TOKEN") -H 'Content-Type: application/json' "https://api.timeweb.cloud/api/v1$1" "${@:2}"; }

tw /projects | jq '.projects[] | {id, name, description}'
tw /servers | jq '.servers[] | {id, name, status, location, availability_zone, cpu, ram, project_id, ips: [.networks[]?.ips[]?.ip]}'
tw /storages/buckets | jq '.buckets[] | {id, name, type, location, hostname, object_amount, used_mb: .disk_stats.used, project_id}'
tw /floating-ips | jq '.ips[] | {ip, ptr, resource_type, resource_id}'
tw /account/finances | jq '.finances | {currency, monthly_cost, hours_left}'
```

Other resource kinds: `/databases`, `/balancers`, `/k8s/clusters`, `/network-drives`, `/firewall/groups`, `/domains`, `/ssh-keys`, `/images`, `/mail`, `/dedicated-servers`, `/container-registry`, `/apps`.

## Rules

- Create or delete nothing without the owner's knowledge and explicit instruction for the specific resource: servers, buckets, disks, addresses, databases, access keys, projects. The same goes for changes that cost money or touch a running resource: changing the plan, rebooting, powering off, moving between projects.
- Reading (`GET`) is free.
- Responses contain secrets: `root_pass` and `vnc_pass` for servers, `access_key` and `secret_key` for buckets. Always pick fields by name with `jq`; never print a whole response or save it to a file.
- Record resource data in the registry: a `timeweb` object for a server in `registry/servers.json`, a separate `s3-<bucket>` link for a bucket in `registry/services.json`. After changes at the hosting provider, reconcile the registry with the API.
- The owner creates a project's bucket and its key. Do not use one project's keys in another.
