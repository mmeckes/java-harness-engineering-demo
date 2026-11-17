---
name: release
description: Cut a release of order-service. Run only when a human asks for a release.
disable-model-invocation: true
argument-hint: <version, e.g. 0.2.0>
---

Release version $ARGUMENTS. Stop at the first failure and report it.

1. Check the tree is clean and on `main`: `git status --short` must be empty.
2. Run the full build: `./mvnw -q verify`.
3. Set the version: `./mvnw -q versions:set -DnewVersion=$ARGUMENTS -DgenerateBackupPoms=false`.
4. Add a `## $ARGUMENTS` section at the top of CHANGELOG.md listing the commits since the last tag
   (`git log --oneline $(git describe --tags --abbrev=0)..HEAD`).
5. Commit with message `release: $ARGUMENTS` and tag `v$ARGUMENTS`.
6. Don't push. Print the commands a human runs to push the commit and the tag.
