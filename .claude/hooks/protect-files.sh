#!/bin/bash
# PreToolUse (Edit|Write): paths the agent must never edit.
# Pair with permissions.deny in settings.json: this hook only covers the file tools,
# not shell commands.
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
FILE_PATH="${FILE_PATH//\\//}"

block() {
  echo "$1" >&2
  exit 2
}

case "$FILE_PATH" in
  */.env | */.env.*)
    block "Blocked: $FILE_PATH holds secrets. Don't read or write it." ;;
  */.git/*)
    block "Blocked: don't edit git internals. Use git commands." ;;
  */orders-client/src/*)
    block "Blocked: orders-client is generated from openapi.yaml. Never edit it by hand.
If the API contract needs to change, say so and stop; the client gets regenerated." ;;
  */src/test/resources/golden/*)
    block "Blocked: golden files are the expected output. Never update a golden to get past a failure.
If you think the golden is wrong, stop and explain why." ;;
esac

# Mistake #5: deleting or weakening tests to make a build go green.
# Start a session with HARNESS_LOCK_TESTS=1 for fix-the-bug tasks.
if [ "${HARNESS_LOCK_TESTS:-0}" = "1" ] && [[ "$FILE_PATH" == */src/test/* ]]; then
  block "Blocked: tests are locked for this session (HARNESS_LOCK_TESTS=1).
Fix the production code so the existing tests pass. If a test is wrong, stop and explain why."
fi

exit 0
