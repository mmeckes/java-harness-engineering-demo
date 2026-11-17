#!/bin/bash
# Stop: don't let a turn end on a red build when code changed.
# Runs the repo's fast check (plugin option check_command, default ./scripts/fast-check.sh).
# Stop fires after every response, so it only gates when Java sources or build files have
# uncommitted changes. Claude Code ends the turn anyway after 8 consecutive blocks.
cat > /dev/null
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
CHECK="${CLAUDE_PLUGIN_OPTION_CHECK_COMMAND:-./scripts/fast-check.sh}"

# No check command in this repo: nothing to gate on.
[ -x "${CHECK%% *}" ] || exit 0

if ! git status --porcelain 2>/dev/null | grep -Eq '(\.java|pom\.xml|\.gradle|\.gradle\.kts)$'; then
  exit 0
fi

if ! OUT=$($CHECK 2>&1); then
  {
    echo "Stop gate: the fast check is red, so this turn isn't done."
    echo "$OUT" | tail -n 40
    echo "If a failing test encodes behaviour you were asked to change, update the test and say so."
    echo "Otherwise fix the code, not the test. Re-run $CHECK and quote its PASS line."
  } >&2
  exit 2
fi
exit 0
