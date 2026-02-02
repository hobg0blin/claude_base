# Claude Code Sandbox

A Docker-based sandbox for running Claude Code with `--dangerously-skip-permissions` safely.

## Quick Start

1. **Copy this folder** to your project root
2. **Customize** the files for your project (see below)
3. **Run** `./sandbox.sh start` to begin

## What This Provides

- **Isolated environment** - Claude Code runs in Docker, separate from your system
- **Two modes**:
  - **Mounted** (default): Code changes affect host - good for normal development
  - **Isolated**: Code is copied - host files completely safe

## Setup for Your Project

### 1. Edit `docker-compose.yml`

Customize the volume mounts for your project structure:

```yaml
volumes:
  # Mount your project code
  - ./src:/app/project:rw

  # Keep these for Claude memory
  - ./.claude:/app/.claude:rw
  - ./CLAUDE.md:/app/CLAUDE.md:rw
```

### 2. Edit `Dockerfile`

Update Python dependencies:

```dockerfile
# Option 1: From requirements file
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Option 2: Direct install
RUN pip install --no-cache-dir django celery redis
```

### 3. Edit `sandbox.sh`

Configure the customization section:

```bash
# Container name prefix
CONTAINER_PREFIX="myproject-sandbox"

# Your main code directory
PROJECT_DIR="./src"
```

## Usage

### Default Mode (Code Mounted)

```bash
./sandbox.sh start     # Build and start
./sandbox.sh enter     # Enter the sandbox
./sandbox.sh stop      # Stop (data preserved)
./sandbox.sh clean     # Remove container
```

Inside the sandbox:
```bash
claude --dangerously-skip-permissions
```

### Secure Mode (Code Copied)

Use when you want host files completely protected:

```bash
./sandbox.sh start-secure   # Build with code copied
./sandbox.sh enter-secure   # Enter sandbox
# ... make changes ...
./sandbox.sh extract        # Copy changes to sandbox_staging/
./sandbox.sh apply          # Apply changes to host
```

### Utilities

```bash
./sandbox.sh status    # Show sandbox status
```

## File Structure

```
claude-sandbox/
├── Dockerfile              # Mounted mode container
├── Dockerfile.isolated     # Isolated mode container
├── docker-compose.yml      # Mounted mode config
├── docker-compose.isolated.yml  # Isolated mode config
├── sandbox.sh              # Helper script
├── sandbox_data/           # Created at runtime (gitignored)
└── sandbox_staging/        # For isolated mode extracts (gitignored)
```

## Recommended .gitignore Additions

```gitignore
# Sandbox runtime data
sandbox_data/
sandbox_staging/
```

## Security Notes

- **Mounted mode**: Code changes affect host immediately. Use for trusted development.
- **Isolated mode**: Code is copied at build time. Use for maximum safety.
- **Git backups**: Automatically created before applying isolated changes.

## Troubleshooting

### Container won't start
- Check Docker is running: `docker info`
- Check ports aren't in use: `lsof -i :8000`

### Changes not appearing
- In mounted mode: changes are immediate
- In isolated mode: run `./sandbox.sh extract` then `./sandbox.sh apply`
