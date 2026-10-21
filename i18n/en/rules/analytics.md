# Website analytics

The rule applies if `harness.json` has the `integrations.umami` key. How to connect — `.claude/integrations/umami.md`.

- Every new project with a public website and open user sign-up is connected to Umami in the task that releases the website.
- The counter goes into the production build only: local development and staging are not counted.
- Connecting is an item of the task plan. When closing the task, check that the live website serves the counter and a visit has reached Umami.
- Connect other websites (without sign-up or already running) when the owner asks for it.
