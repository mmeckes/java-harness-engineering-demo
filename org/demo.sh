#!/bin/bash
# Shows org policy being enforced. No model calls and no credentials needed.
# The forced plugin itself installs at the start of the first real session; to see it load, run a
# session with model credentials and check the init event's "plugins" list (see org/README.md).
step() { printf '\n\033[1m$ %s\033[0m\n' "$*"; }

step claude --version
claude --version

step ls /etc/claude-code/managed-settings.d
ls /etc/claude-code/managed-settings.d

step "claude plugin marketplace add some-team/unreviewed-plugins   # not on the allowlist"
claude plugin marketplace add some-team/unreviewed-plugins 2>&1 | tail -4

step "claude --plugin-dir ./my-local-plugin -p hi                 # sideloading is off"
mkdir -p my-local-plugin
claude --plugin-dir ./my-local-plugin -p hi 2>&1 | tail -3

step "claude plugin marketplace list                               # what policy registered and blocked"
claude plugin marketplace list 2>&1 | head -8

step "claude plugin disable java-harness@mmeckes-harness-demo      # users can't switch it off"
claude plugin disable java-harness@mmeckes-harness-demo 2>&1 | tail -2
