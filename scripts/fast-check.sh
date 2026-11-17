#!/bin/bash
# The fast sensor: format check + compile + unit tests for the modules you changed.
# Target: under 60 seconds. The Stop hook and the verify skill both run this.
set -uo pipefail
cd "$(dirname "$0")/.."

MODULES=(orders-domain orders-client orders-api)
CHANGED=$(git status --porcelain 2>/dev/null | sed -E 's/^.. //; s/.* -> //')

selected=()
if echo "$CHANGED" | grep -qx 'pom.xml'; then
  selected=("${MODULES[@]}")
else
  for m in "${MODULES[@]}"; do
    echo "$CHANGED" | grep -q "^$m/" && selected+=("$m")
  done
fi
[ ${#selected[@]} -eq 0 ] && selected=("${MODULES[@]}")
PL=$(IFS=,; echo "${selected[*]}")

# 1. Formatting (the PostToolUse hook formats on edit; this catches files changed by shell commands).
FMT=.tools/google-java-format
if [ -x "$FMT" ]; then
  java_files=$(echo "$CHANGED" | grep '\.java$' | grep -v '^orders-client/' | while read -r f; do [ -f "$f" ] && echo "$f"; done)
  if [ -n "$java_files" ]; then
    unformatted=$(echo "$java_files" | xargs "$FMT" --dry-run 2>&1)
    if [ -n "$unformatted" ]; then
      echo "FAIL format: these files are not google-java-format clean:"
      echo "$unformatted"
      echo "Fix: .tools/google-java-format --replace <file>"
      exit 1
    fi
  fi
fi

# 2. Compile and unit-test the changed modules (plus what they depend on).
echo "fast-check: ./mvnw -q -B -pl $PL -am test"
if ! out=$(./mvnw -q -B -pl "$PL" -am test 2>&1); then
  echo "FAIL build/tests:"
  # Keep the signal (failing tests, assertions, compile errors); drop Maven's boilerplate.
  echo "$out" \
    | grep -E '<<< FAIL|^\[ERROR\] .*\.java:\[|expected|but was|Expecting|COMPILATION ERROR|Tests run:.*Fail' \
    | grep -Ev 'Help 1|re-run Maven|resume the build|-rf :|For more information|Failed to execute goal|See .*(reports|dump)' \
    | sed "s#$PWD/##" | awk '!seen[$0]++' \
    | head -30
  echo "Re-run one test: ./mvnw -q -pl <module> test -Dtest=<Class>#<method>"
  exit 1
fi
echo "PASS fast-check ($PL)"
