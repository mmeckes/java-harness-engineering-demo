# Agent mistake log

Every time the agent does something we have to correct, add a row. Review it weekly:
the top entries are the harness backlog. "Fix level" is the ladder:
CLAUDE.md line -> skill -> hook / deny rule / lint -> then delete the CLAUDE.md line.
Fixes that apply to every Java repo live in the java-harness plugin (`plugins/java-harness/`);
repo-specific ones stay in `.claude/`. The plugin's `/java-harness:mistake-log` skill adds rows here.

This log is illustrative: it shows the pattern on a fixture repo, not measured data.

| # | What the agent did | Times | Fix level | Fix |
|---|---|---|---|---|
| 1 | Ran system `mvn` instead of `./mvnw` | 5 | hook | java-harness `guard-build-cmd.sh` blocks bare `mvn` and names the right command |
| 2 | Ran `mvn clean install` on the whole reactor for a one-line change | 4 | hook | same guard blocks `install`; `scripts/fast-check.sh` tests only changed modules |
| 3 | Said "all tests pass" without running them | 3 | hook | java-harness Stop hook `stop-gate.sh` runs the fast check before a turn can end |
| 4 | Edited the generated client in `orders-client/` | 2 | hook | java-harness `protect-files.sh` blocks files with a generated-code header |
| 5 | Changed a test's expected value to make a red build green | 2 | hook (opt-in) | `HARNESS_LOCK_TESTS=1` makes protect-files block `src/test/` |
| 6 | Reformatted imports differently every edit | 4 | hook | java-harness PostToolUse `format-java.sh` runs google-java-format |
| 7 | Added `-DskipTests` to get past a red build | 2 | hook | guard blocks skip flags |
| 8 | Used `double` for money | 2 | CLAUDE.md | one line under Conventions (has exceptions in tests and logging, so not a hook) |
| 9 | Got the release steps in the wrong order | 2 | skill | `/release`, manual-only (`disable-model-invocation: true`) |
| 10 | Put business rules in the controller | 2 | path rule | `.claude/rules/api.md`, loads only for `orders-api/**` |
| 11 | Reviewed its own diff and said "looks good" | 3 | subagent | `java-harness:reviewer`, read-only, checks the diff against SPEC.md |
