---
name: mistake-log
description: Record an agent mistake and choose where its fix belongs. Use when the user corrects something Claude did, says "log this", "that's the second time", or asks how to stop a mistake recurring.
---

Turn this correction into a permanent fix, so the mistake gets engineered out once.

1. Add a row to `docs/agent-mistakes.md` (create it with the header below if it's missing).
   If the same mistake is already logged, increment its Times count instead.

   ```
   | # | What the agent did | Times | Fix level | Fix |
   |---|---|---|---|---|
   ```

2. Pick the fix level with this ladder. Choose the lowest rung that makes the mistake impossible
   or very unlikely, and say why:
   - **Hook, deny rule, or lint**: the rule has zero exceptions and a script can check it
     (wrong command, forbidden path, formatting, skipped tests).
   - **Path rule** (`.claude/rules/*.md` with `paths:`): a convention that applies only to some files.
   - **Skill**: a procedure that's needed sometimes, such as a release, a migration, or a runbook.
   - **Subagent**: a judgement call that needs a clean context, such as review against a spec.
   - **CLAUDE.md line**: a convention with legitimate exceptions, or a fact Claude can't discover.
   Prefer fixing the tool itself (a clearer error message, a faster check) over adding prose.

3. Decide the scope:
   - **This repo only**: draft the change in this repo's `.claude/` or CLAUDE.md.
   - **Every Java repo on the team**: it belongs in the java-harness plugin. Draft the change for
     the plugin repo, and note that it needs review and a version bump like any other code change.

4. When the fix is a hook or rule that replaces a CLAUDE.md line, delete that line in the same change.

Show the row and the drafted change. Don't apply a hook or settings change without the user's go-ahead.
