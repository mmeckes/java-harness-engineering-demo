# order-service: a starter harness for Claude Code

A small Java 21 / Spring Boot 4 service with a **harness** around it: the hooks, skills, rules and
subagent that stop a coding agent from making the same mistake twice. It's the running example
from the talk *Harness Engineering: Building the Rails Your Coding Agent Runs On*.

The service itself is deliberately boring: order pricing with promo codes, free shipping, and a
REST API. The interesting parts are the harness and how the git history gets there: from one
engineer's `.claude/` folder, to a team plugin, to an org policy.

## Quick start

Install the team harness (Claude Code 2.1.275 or later):

```
/plugin install java-harness --marketplace mmeckes/java-harness-engineering-demo
```

Then, in a clone of this repo:

```bash
./scripts/setup-tools.sh     # downloads google-java-format into .tools/ (used by the formatter hook)
./scripts/fast-check.sh      # format + compile + unit tests for changed modules (~3 s)
./scripts/test-hooks.sh      # offline test of every hook, no model calls
claude                       # accept the workspace trust prompt so project settings apply
```

Requirements: JDK 21+, `jq`, `git`, Claude Code 2.1.286 or later (for verify-before-commit).

## What's in the harness

| Mistake (from `docs/agent-mistakes.md`) | Rung | Where |
|---|---|---|
| Inconsistent formatting | PostToolUse hook | plugin: `format-java.sh` |
| `mvn` instead of `./mvnw`, `clean install`, `-DskipTests` | PreToolUse hook | plugin: `guard-build-cmd.sh` |
| "All tests pass" without running them | Stop hook | plugin: `stop-gate.sh` → repo: `scripts/fast-check.sh` |
| Editing generated code, secrets, goldens; weakening tests | PreToolUse hook + deny rules | plugin: `protect-files.sh`; repo: `.claude/settings.json` |
| Reviewing its own diff and saying "looks good" | Read-only subagent | plugin: `java-harness:reviewer` |
| A correction that only becomes another CLAUDE.md line | Skill | plugin: `/java-harness:mistake-log` |
| Claiming a change works without exercising it | Skill (auto-runs before commit) | repo: `.claude/skills/verify/` → `scripts/smoke-test.sh` |
| Release steps in the wrong order | Manual-only skill | repo: `.claude/skills/release/` |
| Business rules in controllers | Path-scoped rule | repo: `.claude/rules/api.md` |
| `double` for money | One CLAUDE.md line | repo: `CLAUDE.md` (it has exceptions, so it isn't a hook) |

What goes where:
- **The plugin** (`plugins/java-harness/`) holds what every Java repo on the team needs.
- **The repo** (`.claude/`, `CLAUDE.md`) holds what only this service needs.
- **The `verify` skill stays in the repo on purpose.** Claude Code runs a skill named `verify` before
  each commit only when it's a project skill, not when it comes from a plugin.

Every hook message says what to do instead, not only what's wrong. That text goes straight back
to the agent. `HARNESS_LOCK_TESTS=1 claude` locks `src/test/` for fix-the-bug sessions.

## The history is the story

```bash
git log --oneline
git log -p --follow CLAUDE.md          # watch each rung delete the prose it replaces
```

| Tag / branch | State |
|---|---|
| `stage-0-manifesto` | The service plus a 143-line CLAUDE.md ([`docs/talk/CLAUDE.before.md`](docs/talk/CLAUDE.before.md)) and no hooks |
| `stage-1-harness` | One engineer's harness: 20-line CLAUDE.md, hooks in `.claude/hooks/` |
| `stage-2-team` | The hooks and reviewer moved into the `java-harness` plugin, with an eval suite, org policy and CI |
| branch `long-running-demo` | Multi-session state: `feature_list.json`, `claude-progress.txt`, `init.sh` |

## Team: the plugin and its marketplace

This repo is also a plugin marketplace (`.claude-plugin/marketplace.json`, name `mmeckes-harness-demo`).
`.claude/settings.json` declares it and enables the plugin, so teammates who trust the folder get
prompted to install it.

```bash
claude plugin validate . --strict                 # marketplace
claude plugin validate ./plugins/java-harness --strict
claude plugin details java-harness                # always-on cost: ~99 tokens per session
```

### Prove the harness helps: `claude plugin eval`

`plugins/java-harness/evals/` runs each case with and without the plugin. Results from
2026-11-17 (Bedrock, 3 runs per arm, about $1):

| Case | With plugin | Without | Δ |
|---|---|---|---|
| `red-build-not-done`: behaviour change, "don't run tests" | 1.00 | 0.33 | +0.67 |
| `log-a-mistake`: "you used double for money again" | 1.00 | 0.00 | +1.00 |

Without the plugin, all three baseline runs of `log-a-mistake` answered the correction by writing a
new CLAUDE.md rule. With it, the mistake was logged with a fix level and a scope. A single smoke run
had scored the baseline 1.0, so run enough times to trust the number.

```bash
cd plugins/java-harness
claude plugin eval . --scaffold --trust-plugin --allow-tools Edit Write --no-publish
```

## Org: managed settings

`org/` holds a managed-settings policy split across three teams (platform, security, FinOps), and
a container that demonstrates enforcement with no credentials. See [org/README.md](org/README.md).

## CI

| Workflow | Runs | Needs |
|---|---|---|
| `harness-ci` | Validates the marketplace and plugin, runs the offline hook tests, builds | Nothing |
| `claude-review` | Reviews each PR with the team plugin loaded, through Amazon Bedrock | `CLAUDE_REVIEW_ENABLED=true` variable, `AWS_ROLE_TO_ASSUME` secret (OIDC) |
| `plugin-eval` | The eval suite, on demand | Same as `claude-review` |

## Demo runbook

Each demo was run headless on Amazon Bedrock with Claude Code 2.1.326 on 2026-11-17, and the
results were as described below. Model output varies, so rehearse each demo and keep a recording
as a fallback. Every hook behaviour can also be shown offline with `VERBOSE=1 ./scripts/test-hooks.sh`.

**A. No sensor (`git checkout stage-0-manifesto`)**
> Change the free-shipping threshold to 60.00 EUR. Just make the edit. Don't run any tests or builds.

Claude made the edit, also edited CLAUDE.md and SPEC.md without being asked, and finished with the
build red.

**B. Stop gate, same prompt** (`stage-1-harness`, and again with the plugin)
Claude made the edit and tried to finish. The Stop hook returned the failing test. Claude decided the
test encoded the old rule it had been asked to change, updated it, re-ran the fast check and
reported it green. About 45 s.

**C. Build-command guard**
> Run mvn clean install and tell me whether the build is green.

The hook blocked `install`. Claude ran `./mvnw -q verify`, the full-build command in CLAUDE.md,
and said that `install` never ran.

**D. Formatter**
> Add a method isEmpty() to Order ... on a single line: public boolean isEmpty(){return lines.isEmpty();}

The PostToolUse hook reformatted the method immediately, and Claude reported it.

**E. Protected paths**
> Add a deleteOrder(String id) method to OrdersApiClient.

The hook didn't need to fire. Claude read CLAUDE.md and the generated-code header and stopped to
say the API contract has to change first. The guide did the work and the hook is the backstop.

**F. Verify skill, Stop gate and reviewer together**
> Implement the bulk discount described in SPEC.md, with tests, and commit it.

Claude:
1. Ran the fast check for a baseline.
2. Implemented the change.
3. Invoked the `verify` skill before committing.
4. Hit a red test, which the Stop gate also caught, and updated it because it encoded pre-spec behaviour.
5. Ran the fast check and smoke test.
6. Asked the reviewer subagent to review the change. The reviewer found an edge case with no test, and Claude added it.
7. Committed.

About 3 minutes.

**G. Mistake log** (plugin)
> You just used double for a money amount in PricingService again. That's the second time this week. Log it and suggest where the fix should live.

The `mistake-log` skill fired from plain phrasing. Claude found the existing row, raised its count,
and drafted the fix for approval without changing code.

**H. Shift handoff** (`git checkout long-running-demo`, plugin installed)
> Pick up where we left off. In three short bullets, tell me what you'll work on first and why.

The SessionStart hook injected the feature count, recent commits and progress log, and Claude picked
F-04 with no exploration. Without the plugin, Claude found the progress file itself in one extra turn,
so the hook's value is reliability (it also fires after compaction), not a different answer.

## Notes

- **Hooks run arbitrary shell commands with your permissions.** Read them before you use them, and
  review changes to `.claude/` and `plugins/` like production code.
- `docs/agent-mistakes.md` is illustrative: it shows the pattern, not measured data.
- In a headless `claude -p` run in an untrusted folder, project `permissions.allow` and
  `extraKnownMarketplaces` are ignored, but hooks still run.
- The API listens on `127.0.0.1` by default. Set `SERVER_ADDRESS` to change it deliberately.

## License

MIT-0. See [LICENSE](LICENSE). Copy the harness into your own repo; no attribution needed.

## Branch `long-running-demo`

Anthropic's long-running harness pattern on this repo: `feature_list.json` (only `passes` may
change), an append-only `claude-progress.txt`, and `init.sh`. The java-harness plugin's
SessionStart hook (`orient.sh`) injects the progress tail, recent commits and the next failing
feature, so a fresh session starts oriented without being told to read anything.
