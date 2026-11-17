#!/bin/bash
# PostToolUse (Edit|Write): format the Java file Claude just touched with google-java-format.
# Looks for the formatter on PATH, then in <repo>/.tools/. Without it, the hook does nothing.
# If the file doesn't parse, exit 2 so the parse error goes back to Claude.
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[[ "$FILE_PATH" == *.java ]] || exit 0
[ -f "$FILE_PATH" ] || exit 0
head -n 5 "$FILE_PATH" | grep -Eq 'DO NOT EDIT|@Generated' && exit 0

FMT=$(command -v google-java-format || true)
[ -z "$FMT" ] && [ -x "${CLAUDE_PROJECT_DIR:-.}/.tools/google-java-format" ] && FMT="${CLAUDE_PROJECT_DIR:-.}/.tools/google-java-format"
[ -n "$FMT" ] || exit 0

if ! err=$("$FMT" --replace "$FILE_PATH" 2>&1); then
  echo "google-java-format could not parse $FILE_PATH:" >&2
  echo "$err" | head -10 >&2
  exit 2
fi
exit 0
