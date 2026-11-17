# Org policy: managed settings for the team harness

One policy, split by owner. Claude Code merges `managed-settings.d/*.json` in name order: lists
combine and scalars from later files win. Each team owns one file and reviews changes to it.

| File | Owner | What it enforces |
|---|---|---|
| `10-platform.json` | Developer platform | Only allowlisted marketplaces (`strictKnownMarketplaces`). Registers the team marketplace and force-enables `java-harness` (`extraKnownMarketplaces` + `enabledPlugins`). Rejects `--plugin-dir` and friends (`disableSideloadFlags`) |
| `20-security.json` | Security | Deny rules for secrets, and no `bypassPermissions` mode |
| `30-finops.json` | FinOps | Team and cost-centre attributes on telemetry (`OTEL_RESOURCE_ATTRIBUTES`) |

On a real fleet these files go to `/etc/claude-code/managed-settings.d/` (Linux/WSL) or
`/Library/Application Support/ClaudeCode/managed-settings.d/` (macOS), through MDM or your config
management. Don't install them on your own laptop to try them out: they apply to every Claude Code
session on the machine.

## Try it in a container

```bash
docker build -f org/Dockerfile -t harness-org-demo .     # from the repo root
docker run --rm harness-org-demo
```

No credentials or model calls needed. The demo shows:

- `claude plugin marketplace add some-team/unreviewed-plugins` fails: *is blocked by enterprise policy*, with the allowed sources listed.
- `claude --plugin-dir ./my-local-plugin` exits, naming `disableSideloadFlags`.
- The built-in Anthropic directory shows as *blocked by your organization*.
- `claude plugin disable java-harness@mmeckes-harness-demo` fails: *This plugin is managed by your organization*.

The forced plugin installs at the start of the first real session. To see it load, run one session
with model credentials and check the `init` event:

```bash
docker run --rm -e CLAUDE_CODE_USE_BEDROCK=1 -e AWS_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
  -e AWS_SESSION_TOKEN harness-org-demo bash -c 'mkdir r && cd r && git init -q &&
  claude -p "Reply ok." --output-format stream-json --verbose --max-turns 1 |
  jq -c "select(.subtype==\"init\") | {plugins: [.plugins[].name], plugin_errors}"'
```

Pass short-lived credentials only. The image never stores them.

## Bedrock notes

- On Bedrock, managed settings come from files or MDM. The claude.ai admin console doesn't apply.
- Pin model versions in a managed `env` block (`ANTHROPIC_DEFAULT_SONNET_MODEL` and friends). Unpinned,
  the `sonnet` alias resolves to Claude Code's built-in Bedrock default.
- With Bedrock, telemetry carries only `user.id` and `session.id`. Add team and cost centre with
  `OTEL_RESOURCE_ATTRIBUTES`, as `30-finops.json` does.
