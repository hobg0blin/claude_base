# Claude Code Sandbox - Mounted Mode
# Code is mounted (changes affect host), ideal for normal development
#
# Customize for your project:
# 1. Update requirements installation (line ~35)
# 2. Adjust PYTHONPATH if needed (in docker-compose.yml)

FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
# Add/remove packages based on your project needs
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc g++ make \
    # Uncomment if you need LDAP support:
    # libldap2-dev libsasl2-dev \
    # Uncomment if you need PostgreSQL:
    # libpq-dev \
    git curl vim sqlite3 \
    ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x (required for Claude Code CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI (and optionally other npm packages)
RUN npm install -g @anthropic-ai/claude-code
# Uncomment if your project needs lessc:
# RUN npm install -g less

# Create directories
WORKDIR /app

# Install Python dependencies
# Option 1: From requirements file (uncomment and adjust path)
# COPY project/requirements.txt /app/requirements.txt
# RUN pip install --no-cache-dir -r /app/requirements.txt

# Option 2: Direct pip install (uncomment and adjust)
# RUN pip install --no-cache-dir django celery redis

# Create non-root user for Claude Code (required - can't run as root)
RUN useradd -m -s /bin/bash sandbox && \
    chown -R sandbox:sandbox /app && \
    mkdir -p /home/sandbox/.claude && \
    chown -R sandbox:sandbox /home/sandbox/.claude && \
    # Add sandbox indicator to bash prompt
    echo 'export PS1="[SANDBOX] \w \$ "' >> /home/sandbox/.bashrc && \
    echo 'echo ""' >> /home/sandbox/.bashrc && \
    echo 'echo "╔══════════════════════════════════════════════════════════════╗"' >> /home/sandbox/.bashrc && \
    echo 'echo "║  SANDBOX - Code mounted from host                            ║"' >> /home/sandbox/.bashrc && \
    echo 'echo "║  Run: claude --dangerously-skip-permissions                  ║"' >> /home/sandbox/.bashrc && \
    echo 'echo "╚══════════════════════════════════════════════════════════════╝"' >> /home/sandbox/.bashrc && \
    echo 'echo ""' >> /home/sandbox/.bashrc

ENV SANDBOX_MODE=mounted
ENV SANDBOX_CONTAINER=true

# Set working directory (adjust to your project structure)
WORKDIR /app/project

USER sandbox

CMD ["/bin/bash"]
