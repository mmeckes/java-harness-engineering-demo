#!/bin/bash
# Stop: don't let a turn end on a red build when code changed.
# Stop fires after every response, including plain Q&A, so only gate when
# Java sources or POMs have uncommitted changes.
# Exit 2 sends stderr back to Claude and it keeps working. Claude Code ends the
# turn anyway after 8 consecutive blocks with no tool call in between.
cd "$CLAUDE_PROJECT_DIR" || exit 0
cat > /dev/null   # hook input not needed

if ! git status --porcelain 2>/dev/null | grep -Eq '(\.java|pom\.xml)$'; then
  exit 0
fi

if ! OUT=$(./scripts/fast-check.sh 2>&1); then
  {
    echo "Stop gate: the fast check is red, so this turn isn't done."
    echo "$OUT" | tail -n 40
    echo "If a failing test encodes behaviour you were asked to change, update the test and say so."
    echo "Otherwise fix the code, not the test. Re-run ./scripts/fast-check.sh and quote its PASS line."
  } >&2
  exit 2
fi
exit 0
