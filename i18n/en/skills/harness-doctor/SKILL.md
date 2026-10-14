---
name: harness-doctor
description: Full check of the harness environment — utilities, tokens, real access to Plane, n8n, GitGuardian, GitLab, Yandex Cloud, GitHub and Docker. Use on a new device, on access errors, or when the owner asks to check the environment.
---

Check the environment.

1. Run `bin/harness doctor --deep`. The script checks only the presence of tokens and response codes; it does not print token values — and you do not print them either.
2. Group the result for the owner: what works (one line), what requires action.
3. For each `FAIL` and `warn`, give a concrete next step:
   - a utility is not installed — the install command for this OS (on macOS `brew install …`, for `ggshield` `pipx install ggshield`);
   - the owner is not set or the rules are not deployed — `bin/harness init`;
   - a token is not set — which variable to put it in and where it is issued (see `.claude/integrations/<service>.md`);
   - HTTP 401/403 — the token has expired or lacks permissions;
   - no `yc` profile or the Yandex Cloud request failed — the owner runs `yc init` (the sign-in is interactive, see `.claude/integrations/yandex-cloud.md`);
   - no connection — check the network or VPN and the availability of the service.
4. Install utilities and change the environment configuration only with the owner's consent.
