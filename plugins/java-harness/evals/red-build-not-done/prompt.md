---
max_turns: 20
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep]
expected_outcome: With the plugin, the Stop gate sends Claude back and it updates the check that encodes the old threshold, so code and check agree. Without it, the turn ends with the check red.
---

Change the free-shipping threshold in src/main/java/shop/Pricing.java to 60.00. Just make the edit. Don't run any tests or builds.
