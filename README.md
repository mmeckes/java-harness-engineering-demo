# order-service: a starter harness for Claude Code

A small Java 21 / Spring Boot 4 service with a **harness** around it: the hooks, skills, rules and
subagent that stop a coding agent from making the same mistake twice. It's the running example
from the talk *Harness Engineering: Building the Rails Your Coding Agent Runs On*.

The service itself is deliberately boring: order pricing with promo codes, free shipping, and a
REST API. The interesting part is `.claude/`, and how the git history gets there.

## Quick start

```bash
./scripts/setup-tools.sh     # downloads google-java-format into .tools/ (used by the formatter hook)
./scripts/fast-check.sh      # format + compile + unit tests for changed modules (~3 s)
./scripts/test-hooks.sh      # offline test of every hook, no model calls
claude                       # accept the workspace trust prompt so project permissions apply
```

Requirements: JDK 21+, `jq`, `git`, Claude Code 2.1.286 or later (for verify-before-commit).

## What's in the harness

| Mistake (from `docs/agent-mistakes.md`) | Rung | File |
|---|---|---|
| Inconsistent formatting | PostToolUse hook | `.claude/hooks/format-java.sh` |
| `mvn` instead of `./mvnw`, `clean install`, `-DskipTests` | PreToolUse hook | `.claude/hooks/guard-build-cmd.sh` |
| "All tests pass" without running them | Stop hook | `.claude/hooks/stop-gate.sh` → `scripts/fast-check.sh` |
| Editing generated code, secrets, goldens; weakening tests | PreToolUse hook + deny rules | `.claude/hooks/protect-files.sh`, `.claude/settings.json` |
| Claiming a change works without exercising it | Skill (auto-runs before commit) | `.claude/skills/verify/SKILL.md` → `scripts/smoke-test.sh` |
| Release steps in the wrong order | Manual-only skill | `.claude/skills/release/SKILL.md` |
| Business rules in controllers | Path-scoped rule | `.claude/rules/api.md` |
| Reviewing its own diff and saying "looks good" | Read-only subagent | `.claude/agents/reviewer.md` |
| `double` for money | One CLAUDE.md line | `CLAUDE.md` (it has exceptions, so it isn't a hook) |

Every hook message says what to do instead, not only what's wrong. That text goes straight back
to the agent.

`HARNESS_LOCK_TESTS=1 claude` locks `src/test/` for fix-the-bug sessions.

## The history is the story

```bash
git log --oneline
git log -p --follow CLAUDE.md          # watch each rung delete the prose it replaces
git diff stage-0-manifesto stage-1-harness --stat
```

| Tag | State |
|---|---|
| `stage-0-manifesto` | The service plus a 143-line CLAUDE.md ([`docs/talk/CLAUDE.before.md`](docs/talk/CLAUDE.before.md)) and no hooks |
| `stage-1-harness` | 20-line CLAUDE.md plus the full harness |

## Demo runbook

Each demo was run headless on Amazon Bedrock with Claude Code 2.1.326 on 2026-11-17, and the
results were as described below. Model output varies, so rehearse each demo and keep a
recording as a fallback. Every hook behaviour can also be shown offline with
`VERBOSE=1 ./scripts/test-hooks.sh`.

**A. No sensor (`git checkout stage-0-manifesto`)**
> Change the free-shipping threshold to 60.00 EUR. Just make the edit. Don't run any tests or builds.

Claude made the edit, also edited CLAUDE.md and SPEC.md without being asked, and finished with the
build red (`shippingFreeAtExactlyThreshold` fails).

**B. Stop gate (`stage-1-harness`), same prompt.**
Claude made the edit and tried to finish. The Stop hook returned the failing test. Claude decided the
test encoded the old rule it had been asked to change, updated it, re-ran `./scripts/fast-check.sh`,
and quoted `PASS`. 10 turns, about 50 s.

**C. Build-command guard**
> Run mvn clean install and tell me whether the build is green.

The hook blocked `install`. Claude ran `./mvnw -q verify`, the command CLAUDE.md lists for a full
build, and said that `install` never ran.

**D. Formatter**
> Add a method isEmpty() to Order ... on a single line: public boolean isEmpty(){return lines.isEmpty();}

The PostToolUse hook reformatted the method immediately, and Claude reported it.

**E. Protected paths**
> Add a deleteOrder(String id) method to OrdersApiClient.

The hook didn't need to fire. Claude read the CLAUDE.md line and the generated-code header and
stopped to say the API contract has to change first. The guide did the work and the hook is the
backstop. To show the hook itself, ask it to "edit the file anyway", or use `test-hooks.sh`.

**F. Verify skill, Stop gate and reviewer together**
> Implement the bulk discount described in SPEC.md, with tests, and commit it.

Claude:
1. Ran the fast check for a baseline.
2. Implemented the change.
3. Invoked the `verify` skill before committing.
4. Hit a red test, which the Stop gate also caught, and updated it because it encoded pre-spec behaviour.
5. Ran `fast-check.sh` and `smoke-test.sh`.
6. Asked the `reviewer` subagent to review the change. The reviewer found an edge case with no test, and Claude added that test.
7. Committed.

26 turns, about 3 minutes.

## Notes

- **Hooks run arbitrary shell commands with your permissions.** Read them before you use them, and
  review changes to `.claude/` like production code.
- `docs/agent-mistakes.md` is illustrative: it shows the pattern, not measured data.
- In a headless `claude -p` run in an untrusted folder, project `permissions.allow` rules are
  ignored, but hooks still run.
- On Amazon Bedrock, nothing here needs extra configuration.

## License

MIT-0. See [LICENSE](LICENSE). Copy the harness into your own repo; no attribution needed.
