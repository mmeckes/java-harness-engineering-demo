#!/bin/bash
# Start-of-session smoke check for long-running work: is the tree green before you start?
set -e
cd "$(dirname "$0")"
./scripts/fast-check.sh
./scripts/smoke-test.sh
