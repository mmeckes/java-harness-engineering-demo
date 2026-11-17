#!/bin/bash
# Offline check of every java-harness plugin hook: pipes sample hook input into each script and checks the exit code.
# No model calls. Use it in CI, and on stage as the fallback if a live demo misbehaves.
cd "$(dirname "$0")/.."
export CLAUDE_PROJECT_DIR=$PWD
H=plugins/java-harness/scripts
pass=0; fail=0
check() { # expected-exit hook description json [env]
  local want=$1 hook=$2 desc=$3 json=$4
  got=$(echo "$json" | env ${5:-} "$H/$hook" 2>/tmp/test-hooks.err; echo $?)
  if [ "$got" = "$want" ]; then pass=$((pass+1)); printf 'ok    %-14s %s\n' "$hook" "$desc"
  else fail=$((fail+1)); printf 'FAIL  %-14s %s (exit %s, want %s)\n' "$hook" "$desc" "$got" "$want"; fi
  [ "$want" = 2 ] && [ -n "$VERBOSE" ] && sed 's/^/        | /' /tmp/test-hooks.err
}
bash() { printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"; }
file() { printf '{"tool_name":"Edit","tool_input":{"file_path":"%s/%s"}}' "$PWD" "$1"; }

check 2 guard-build-cmd.sh "blocks: mvn test"                    "$(bash 'mvn test')"
check 2 guard-build-cmd.sh "blocks: cd x && mvn package"         "$(bash 'cd orders-api && mvn -q package')"
check 2 guard-build-cmd.sh "blocks: ./mvnw clean install"        "$(bash './mvnw clean install')"
check 2 guard-build-cmd.sh "blocks: -DskipTests"                 "$(bash './mvnw -q -pl orders-api package -DskipTests')"
check 0 guard-build-cmd.sh "allows: ./mvnw -q -pl <m> test"      "$(bash './mvnw -q -pl orders-domain test')"
check 0 guard-build-cmd.sh "allows: ./scripts/fast-check.sh"     "$(bash './scripts/fast-check.sh')"
check 2 protect-files.sh   "blocks: .env"                        "$(file .env)"
check 2 protect-files.sh   "blocks: generated code (by header)"     "$(file orders-client/src/main/java/com/example/orders/client/OrdersApiClient.java)"
check 2 protect-files.sh   "blocks: golden files"                "$(file orders-domain/src/test/resources/golden/x.json)"
check 0 protect-files.sh   "allows: tests (unlocked)"            "$(file orders-domain/src/test/java/X.java)"
check 2 protect-files.sh   "blocks: tests when locked"           "$(file orders-domain/src/test/java/X.java)" HARNESS_LOCK_TESTS=1
check 0 protect-files.sh   "allows: main sources"                "$(file orders-domain/src/main/java/X.java)"
check 0 format-java.sh     "ignores non-Java files"              "$(file README.md)"
check 0 stop-gate.sh       "passes on a clean tree"              "{}"
check 0 orient.sh          "silent without feature_list.json"    "{}"
echo "$pass passed, $fail failed"
[ $fail -eq 0 ]
