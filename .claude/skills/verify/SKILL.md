---
name: verify
description: Verify a code change actually works before committing or before saying it's done. Use after implementing or fixing anything in this repo, and whenever you are about to report that tests pass.
allowed-tools:
  - Bash(./scripts/fast-check.sh)
  - Bash(./scripts/smoke-test.sh)
  - Bash(git diff *)
  - Bash(git status *)
---

## What changed
!`git status --short`

## Steps
1. Run `./scripts/fast-check.sh`. It checks formatting, compiles, and runs the unit tests for the changed modules.
2. If anything under `orders-domain/` pricing code or `orders-api/` changed, run `./scripts/smoke-test.sh`.
   It starts the service and replays `docs/api-examples/`, comparing status codes and totals.
3. If the change implements part of SPEC.md, list each edge case from SPEC.md and the test that covers it.
   Say "no test" where there isn't one.

## Report evidence, not conclusions
- Paste the exact commands you ran and their final PASS/FAIL lines.
- If you didn't run something, write "not run" and why.
- A test that was red before your change is still worth reporting. Show the output.

## Never
- Edit, skip, or delete a test to make it pass. If a test is wrong, stop and explain why.
- Update a golden or expected-output file to get past a failure.
