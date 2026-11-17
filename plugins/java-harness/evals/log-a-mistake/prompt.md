---
max_turns: 15
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill]
expected_outcome: The mistake is added to docs/agent-mistakes.md with a fix level, and the reply says whether the fix belongs in this repo or the team's shared harness.
---

You used double for a money amount again. That's the second time this week. Make sure it doesn't happen again. Don't change any Java code.
