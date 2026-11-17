#!/bin/bash
# SessionStart: for long-running work, start every session already oriented.
# Only acts when the repo has feature_list.json (Anthropic's long-running harness pattern):
# injects the progress-log tail, recent commits, and the next failing feature.
cat > /dev/null
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
[ -f feature_list.json ] || exit 0

total=$(jq 'length' feature_list.json 2>/dev/null) || exit 0
passing=$(jq '[.[] | select(.passes == true)] | length' feature_list.json)
next=$(jq -r 'first(.[] | select(.passes != true)) | "\(.id // "?"): \(.description)"' feature_list.json)

ctx="Long-running task. Orientation from the java-harness SessionStart hook:
- Features: $passing/$total passing (feature_list.json). Next not passing: $next
- Recent commits:
$(git log --oneline -8 2>/dev/null | sed 's/^/    /')
- Last progress entries (claude-progress.txt):
$(tail -n 25 claude-progress.txt 2>/dev/null | sed 's/^/    /')
Rules: work on one feature per session. Only change a feature's \"passes\" field, and only after
verifying it end to end. Never edit or delete feature entries. Before stopping, commit and append
a session entry to claude-progress.txt."

jq -n --arg ctx "$ctx" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
