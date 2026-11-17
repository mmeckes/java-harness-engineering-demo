#!/bin/bash
# PreToolUse (Bash): block the build commands this repo keeps getting wrong.
# Every rule here came from a row in docs/agent-mistakes.md.
# Exit 2 blocks the call, and stderr goes back to Claude as the reason, so each
# message says what to run instead.
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

block() {
  echo "$1" >&2
  exit 2
}

# Mistake #1: system Maven instead of the wrapper.
if echo "$CMD" | grep -Eq '(^|[;&|(`[:space:]])mvn([[:space:]]|$)'; then
  block "Blocked: don't call 'mvn' directly; this repo pins Maven with the wrapper.
Run the fast check:  ./scripts/fast-check.sh
Or one module:       ./mvnw -q -pl <module> -am test -Dtest=<TestClass>"
fi

# Mistake #7: "fixing" a red build by skipping tests.
if echo "$CMD" | grep -Eq -- '-DskipTests|-Dmaven\.test\.skip|-Dsurefire\.skip|-DskipITs'; then
  block "Blocked: skipping tests is not a fix. Run the failing test, read the assertion, fix the cause:
  ./mvnw -q -pl <module> test -Dtest=<TestClass>#<method>"
fi

# Mistake #2: 'clean install' of the whole reactor for a one-module change.
if echo "$CMD" | grep -Eq 'mvnw.*(clean[[:space:]]+install|[[:space:]]install)'; then
  block "Blocked: nothing here needs 'install'. Build and test only what you changed:
  ./scripts/fast-check.sh            (changed modules, under a minute)
  ./mvnw -q verify                   (full build, only when the user asks)"
fi

exit 0
