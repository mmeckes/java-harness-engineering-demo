#!/bin/bash
# PreToolUse (Edit|Write): paths the agent must never edit.
# Covers the file tools only. Pair with permissions.deny rules for reads and shell access.
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
  */src/test/resources/golden/* | */__snapshots__/*)
    block "Blocked: golden and snapshot files are the expected output. Never update one to get past a failure.
If you think it's wrong, stop and explain why." ;;
esac

# Generated code, recognised by its header rather than a per-repo path list.
if [ -f "$FILE_PATH" ] && head -n 5 "$FILE_PATH" | grep -Eq 'DO NOT EDIT|@Generated|auto-generated'; then
  block "Blocked: $FILE_PATH is generated (see its header). Never edit it by hand.
Change the source it's generated from, or stop and say what needs regenerating."
fi

# Opt-in for fix-the-bug sessions: HARNESS_LOCK_TESTS=1 claude
if [ "${HARNESS_LOCK_TESTS:-0}" = "1" ] && [[ "$FILE_PATH" == */src/test/* ]]; then
  block "Blocked: tests are locked for this session (HARNESS_LOCK_TESTS=1).
Fix the production code so the existing tests pass. If a test is wrong, stop and explain why."
fi

exit 0
