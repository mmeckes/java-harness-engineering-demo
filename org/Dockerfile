# A "developer laptop" with the org policy installed, for demoing managed settings safely.
# Build from the repo root:  docker build -f org/Dockerfile -t harness-org-demo .
FROM node:22-slim
RUN apt-get update && apt-get install -y --no-install-recommends git jq ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @anthropic-ai/claude-code@latest
# The platform team's marketplace, served from a read-only directory.
COPY .claude-plugin /opt/harness-marketplace/.claude-plugin
COPY plugins /opt/harness-marketplace/plugins
# The org policy: one file per owning team, merged in name order.
COPY org/managed-settings.d /etc/claude-code/managed-settings.d
COPY org/demo.sh /usr/local/bin/org-demo
RUN useradd -m dev && chmod +x /usr/local/bin/org-demo
USER dev
WORKDIR /home/dev
CMD ["org-demo"]
