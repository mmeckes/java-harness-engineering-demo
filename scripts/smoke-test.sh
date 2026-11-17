#!/bin/bash
# Behaviour check: build the API, start it on a spare port, replay docs/api-examples,
# compare status codes and totals, then stop the app.
# Used by the verify skill for changes that touch pricing or the API.
set -uo pipefail
cd "$(dirname "$0")/.."
PORT="${SMOKE_PORT:-18080}"

./mvnw -q -B -pl orders-api -am package > /tmp/order-service-package.log 2>&1 \
  || { echo "FAIL package (see /tmp/order-service-package.log)"; tail -20 /tmp/order-service-package.log; exit 1; }

java -jar orders-api/target/orders-api-0.1.0-SNAPSHOT.jar --server.port="$PORT" \
  > /tmp/order-service-run.log 2>&1 &
APP=$!
trap 'kill $APP 2>/dev/null' EXIT

for _ in $(seq 1 30); do
  curl -s -o /dev/null "http://localhost:$PORT/orders/ping" && break
  sleep 0.5
done

fail=0
for req in docs/api-examples/*.request.json; do
  name=$(basename "$req" .request.json)
  expected_status=$(jq -r '.status' "docs/api-examples/$name.expected.json")
  expected_total=$(jq -r '.total // empty' "docs/api-examples/$name.expected.json")
  body=$(mktemp)
  status=$(curl -s -o "$body" -w '%{http_code}' -H 'Content-Type: application/json' \
    --data @"$req" "http://localhost:$PORT/orders")
  total=$(jq -r '.total // empty' "$body" 2>/dev/null)
  if [ "$status" != "$expected_status" ] || { [ -n "$expected_total" ] && [ "$total" != "$expected_total" ]; }; then
    echo "FAIL $name: got status=$status total=$total, expected status=$expected_status total=$expected_total"
    fail=1
  else
    echo "ok   $name: status=$status total=${total:--}"
  fi
  rm -f "$body"
done
[ $fail -eq 0 ] && echo "PASS smoke-test" || exit 1
