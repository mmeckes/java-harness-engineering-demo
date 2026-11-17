#!/bin/bash
# PostToolUse (Edit|Write): format the Java file Claude just touched.
# Replaces the CLAUDE.md line "ALWAYS run the formatter after editing!!!".
# If the file doesn't parse, exit 2 so the compiler-style error goes back to Claude.
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
FMT="$CLAUDE_PROJECT_DIR/.tools/google-java-format"

[[ "$FILE_PATH" == *.java ]] || exit 0
[[ "$FILE_PATH" == */orders-client/* ]] && exit 0
[ -f "$FILE_PATH" ] || exit 0
[ -x "$FMT" ] || exit 0   # run scripts/setup-tools.sh to enable

if ! err=$("$FMT" --replace "$FILE_PATH" 2>&1); then
  echo "google-java-format could not parse $FILE_PATH:" >&2
  echo "$err" | head -10 >&2
  exit 2
fi
exit 0
