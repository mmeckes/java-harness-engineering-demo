#!/bin/bash
# Downloads the native google-java-format binary into .tools/ (gitignored).
# The PostToolUse formatter hook uses it; without it the hook is a no-op.
set -euo pipefail
VERSION="2.0.0"
cd "$(dirname "$0")/.."
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64)  ASSET="google-java-format_darwin-arm64" ;;
  Linux-x86_64)  ASSET="google-java-format_linux-x86-64" ;;
  Linux-aarch64) ASSET="google-java-format_linux-arm64" ;;
  *) echo "No native binary for $(uname -s)-$(uname -m). Install google-java-format and put it on PATH." >&2; exit 1 ;;
esac
mkdir -p .tools
curl -fsSL -o .tools/google-java-format \
  "https://github.com/google/google-java-format/releases/download/v${VERSION}/${ASSET}"
chmod +x .tools/google-java-format
xattr -d com.apple.quarantine .tools/google-java-format 2>/dev/null || true
.tools/google-java-format --version
