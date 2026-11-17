#!/bin/bash
# PreToolUse (Bash): block the build commands agents keep getting wrong in Java repos.
# Exit 2 blocks the call; stderr goes back to Claude, so every message names the fix.
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
CHECK="${CLAUDE_PLUGIN_OPTION_CHECK_COMMAND:-./scripts/fast-check.sh}"
ROOT="${CLAUDE_PROJECT_DIR:-.}"

block() {
  echo "$1" >&2
  exit 2
}

# System Maven in a repo that pins Maven with the wrapper.
if [ -x "$ROOT/mvnw" ] && echo "$CMD" | grep -Eq '(^|[;&|(`[:space:]])mvn([[:space:]]|$)'; then
  block "Blocked: this repo pins Maven with ./mvnw; don't call 'mvn' directly.
Fast check:  $CHECK
One module:  ./mvnw -q -pl <module> -am test -Dtest=<TestClass>"
fi

# Skipping tests is never a fix.
if echo "$CMD" | grep -Eq -- '-DskipTests|-Dmaven\.test\.skip|-Dsurefire\.skip|-DskipITs|gradlew?[^;&|]*[[:space:]]-x[[:space:]]+test'; then
  block "Blocked: skipping tests is not a fix. Run the failing test, read the assertion, fix the cause:
  ./mvnw -q -pl <module> test -Dtest=<TestClass>#<method>"
fi

# 'install' of the whole reactor for a change that only needs a test run.
if echo "$CMD" | grep -Eq '(mvnw?|mvn)[^;&|]*[[:space:]](clean[[:space:]]+)?install([[:space:]]|$)'; then
  block "Blocked: you don't need 'install' to check a change. Run only what you changed:
  $CHECK
Full build, only when the user asks:  ./mvnw -q verify"
fi

exit 0
