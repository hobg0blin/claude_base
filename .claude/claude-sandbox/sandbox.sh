#!/bin/bash
# Claude Code Sandbox Helper Script
#
# Generic sandbox for running Claude Code with --dangerously-skip-permissions safely.
#
# Usage:
#   ./sandbox.sh start    - Start sandbox (code mounted, changes affect host)
#   ./sandbox.sh enter    - Enter the sandbox
#   ./sandbox.sh stop     - Stop the sandbox
#   ./sandbox.sh clean    - Remove the sandbox
#
# Secure mode (code copied, host files untouched):
#   ./sandbox.sh start-secure  - Start with code COPIED (fully isolated)
#   ./sandbox.sh enter-secure  - Enter the secure sandbox
#   ./sandbox.sh extract       - Copy changes from container to sandbox_staging/
#   ./sandbox.sh apply         - Apply sandbox_staging/ changes to host
#
# Customization:
#   Edit the CUSTOMIZE section below for your project structure.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ============================================================
# CUSTOMIZE: Project-specific settings
# ============================================================

# Container name prefix (used for container naming)
CONTAINER_PREFIX="claude-sandbox"

# Project directory to mount/copy (relative to this script)
# Set to your main code directory
PROJECT_DIR="./project"

# Additional directories to extract in secure mode (space-separated)
# Example: "src lib packages"
EXTRACT_DIRS=""

# ============================================================
# END CUSTOMIZE
# ============================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_git_status() {
    if [ -d "$PROJECT_DIR/.git" ]; then
        cd "$PROJECT_DIR"
        if [ -n "$(git status --porcelain)" ]; then
            echo -e "${YELLOW}Warning: You have uncommitted changes in $PROJECT_DIR${NC}"
            echo "Consider committing before starting sandbox:"
            echo "  cd $PROJECT_DIR && git status"
            echo ""
            read -p "Continue anyway? [y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
        cd "$SCRIPT_DIR"
    fi
}

case "${1:-help}" in
    #
    # === DEFAULT SANDBOX (code mounted, changes affect host) ===
    #
    start)
        echo "=== Sandbox (Code Mounted) ==="
        echo ""
        echo -e "${YELLOW}Code changes WILL affect your host filesystem.${NC}"
        echo "Use './sandbox.sh start-secure' for fully isolated mode."
        echo ""

        check_git_status

        echo "Building and starting sandbox container..."
        docker build -t ${CONTAINER_PREFIX} -f Dockerfile .
        docker compose up -d --no-build

        echo ""
        echo -e "${GREEN}Sandbox is running!${NC}"
        echo ""
        echo "Enter the sandbox:  ./sandbox.sh enter"
        echo ""
        echo "Inside, run Claude Code:"
        echo "  claude --dangerously-skip-permissions"
        ;;

    enter)
        echo "Entering sandbox..."
        docker compose exec sandbox bash
        ;;

    stop)
        echo "Stopping sandbox..."
        docker compose stop
        echo -e "${GREEN}Sandbox stopped.${NC}"
        ;;

    clean)
        echo -e "${RED}This will remove the sandbox container.${NC}"
        read -p "Are you sure? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Stopping and removing sandbox..."
            docker compose down -v --rmi local
            echo -e "${GREEN}Sandbox removed.${NC}"
        else
            echo "Cancelled."
        fi
        ;;

    #
    # === SECURE SANDBOX (code copied, fully isolated) ===
    #
    start-secure)
        echo "=== SECURE Sandbox (Full Isolation) ==="
        echo ""
        echo -e "${GREEN}Your original files will be COMPLETELY SAFE.${NC}"
        echo "The container gets a COPY of the code - changes don't affect your files."
        echo ""

        # Create staging directory
        mkdir -p sandbox_staging

        # Backup git history to be extra safe
        if [ -d "$PROJECT_DIR/.git" ]; then
            echo "Creating git backup..."
            mkdir -p sandbox_data
            cd "$PROJECT_DIR"
            git bundle create "$SCRIPT_DIR/sandbox_data/git-backup.bundle" --all 2>/dev/null || true
            cd "$SCRIPT_DIR"
            echo -e "Git backup saved to: ${GREEN}sandbox_data/git-backup.bundle${NC}"
            echo ""
        fi

        echo "Building secure container (this copies all code)..."
        docker build -t ${CONTAINER_PREFIX}-isolated -f Dockerfile.isolated .

        echo "Starting secure container..."
        docker compose -f docker-compose.isolated.yml up -d --no-build

        echo ""
        echo -e "${GREEN}Secure sandbox is running!${NC}"
        echo ""
        echo "Enter with:  ./sandbox.sh enter-secure"
        echo ""
        echo "Inside, you can run Claude Code with full permissions safely:"
        echo "  claude --dangerously-skip-permissions"
        echo ""
        echo "When done, extract changes with: ./sandbox.sh extract"
        ;;

    enter-secure)
        echo "Entering secure sandbox..."
        docker compose -f docker-compose.isolated.yml exec sandbox-isolated bash
        ;;

    stop-secure)
        echo "Stopping secure sandbox..."
        docker compose -f docker-compose.isolated.yml stop
        echo -e "${GREEN}Secure sandbox stopped.${NC}"
        echo "Changes are preserved inside the container."
        echo "Use './sandbox.sh extract' to copy changes out."
        ;;

    clean-secure)
        echo -e "${RED}This will remove the secure container and staging area.${NC}"
        read -p "Are you sure? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker compose -f docker-compose.isolated.yml down -v --rmi local 2>/dev/null || true
            rm -rf sandbox_staging
            echo -e "${GREEN}Secure sandbox removed.${NC}"
        fi
        ;;

    extract)
        echo "=== Extract Changes from Secure Sandbox ==="
        echo ""

        CONTAINER="${CONTAINER_PREFIX}-isolated"
        mkdir -p sandbox_staging

        echo "Copying files from container to sandbox_staging/..."

        # Always extract Claude config
        docker cp ${CONTAINER}:/app/.claude sandbox_staging/ 2>/dev/null || true
        docker cp ${CONTAINER}:/app/CLAUDE.md sandbox_staging/ 2>/dev/null || true

        # Extract project directory
        docker cp ${CONTAINER}:/app/project sandbox_staging/ 2>/dev/null || true

        # Extract additional directories
        for dir in $EXTRACT_DIRS; do
            docker cp ${CONTAINER}:/app/${dir} sandbox_staging/ 2>/dev/null || true
        done

        echo ""
        echo -e "${GREEN}Files extracted to: sandbox_staging/${NC}"
        echo ""
        echo "Review the changes:"
        echo "  diff -rq $PROJECT_DIR sandbox_staging/project"
        echo "  diff -rq .claude sandbox_staging/.claude"
        echo ""
        echo "To apply changes: ./sandbox.sh apply"
        ;;

    apply)
        echo "=== Apply Changes from Secure Sandbox ==="
        echo ""

        CONTAINER="${CONTAINER_PREFIX}-isolated"

        if [ ! -d "sandbox_staging/project" ] && [ ! -d "sandbox_staging/.claude" ]; then
            echo "No staging directory found. Running extract first..."
            $0 extract
        fi

        echo "Changes to apply:"
        echo "─────────────────"

        if [ -d "sandbox_staging/project" ] && [ -d "$PROJECT_DIR" ]; then
            echo "project/:"
            diff -rq "$PROJECT_DIR" sandbox_staging/project 2>/dev/null | grep -v "__pycache__" | head -20 || echo "  No differences"
            echo ""
        fi

        echo ".claude/:"
        diff -rq .claude sandbox_staging/.claude 2>/dev/null | head -10 || echo "  No differences"
        echo ""

        DIFF_COUNT=0
        if [ -d "sandbox_staging/project" ] && [ -d "$PROJECT_DIR" ]; then
            DIFF_COUNT=$(diff -rq "$PROJECT_DIR" sandbox_staging/project 2>/dev/null | grep -v "__pycache__" | wc -l)
        fi
        echo "Total: $DIFF_COUNT file(s) differ in project/"
        echo ""

        if [ "$DIFF_COUNT" -eq 0 ]; then
            echo "Nothing to apply."
            exit 0
        fi

        if [ -d "$PROJECT_DIR/.git" ]; then
            echo "Creating git backup before applying..."
            mkdir -p sandbox_data
            cd "$PROJECT_DIR"
            git bundle create "$SCRIPT_DIR/sandbox_data/git-backup-pre-apply.bundle" --all 2>/dev/null || true

            if [ -n "$(git status --porcelain)" ]; then
                echo -e "${YELLOW}You have uncommitted changes. Creating stash...${NC}"
                git stash push -m "Pre-sandbox-apply checkpoint $(date +%Y%m%d-%H%M%S)"
            fi
            cd "$SCRIPT_DIR"
            echo -e "Backup saved: ${GREEN}sandbox_data/git-backup-pre-apply.bundle${NC}"
            echo ""
        fi

        echo -e "${YELLOW}This will overwrite files with sandbox changes.${NC}"
        read -p "Apply all changes? [y/N] " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Applying changes..."

            if [ -d "sandbox_staging/project" ]; then
                rsync -av --exclude='.git' --exclude='__pycache__' --exclude='.venv' \
                      --exclude='*.pyc' --exclude='.DS_Store' \
                      sandbox_staging/project/ "$PROJECT_DIR/"
            fi

            if [ -d "sandbox_staging/.claude" ]; then
                rsync -av sandbox_staging/.claude/ .claude/
            fi
            if [ -f "sandbox_staging/CLAUDE.md" ]; then
                cp sandbox_staging/CLAUDE.md CLAUDE.md
            fi

            echo ""
            echo -e "${GREEN}Changes applied successfully!${NC}"
            echo ""
            echo "Next steps:"
            echo "  cd $PROJECT_DIR && git status   # Review changes"
            echo "  cd $PROJECT_DIR && git diff     # See details"
            echo "  cd $PROJECT_DIR && git add -A && git commit -m 'Apply sandbox changes'"
        else
            echo "Cancelled. No changes applied."
            echo ""
            echo "You can still manually copy specific files:"
            echo "  cp sandbox_staging/project/path/to/file $PROJECT_DIR/path/to/file"
        fi
        ;;

    #
    # === UTILITIES ===
    #
    status)
        echo "=== Sandbox Status ==="
        echo ""
        echo "Default sandbox (mounted):"
        docker compose ps 2>/dev/null || echo "  Not running"
        echo ""
        echo "Secure sandbox (isolated):"
        docker compose -f docker-compose.isolated.yml ps 2>/dev/null || echo "  Not running"
        echo ""
        if [ -f "sandbox_data/git-backup.bundle" ]; then
            echo -e "Git backup: ${GREEN}exists${NC} ($(du -h sandbox_data/git-backup.bundle | cut -f1))"
        fi
        ;;

    help|*)
        echo "Claude Code Sandbox Helper"
        echo ""
        echo "Usage: ./sandbox.sh <command>"
        echo ""
        echo "=== Default Sandbox (code mounted, changes affect host) ==="
        echo "  start    - Start sandbox with code mounted"
        echo "  enter    - Enter the sandbox"
        echo "  stop     - Stop the sandbox"
        echo "  clean    - Remove the sandbox"
        echo ""
        echo "=== Secure Sandbox (code copied, fully isolated) ==="
        echo "  start-secure  - Start with code COPIED (host files safe)"
        echo "  enter-secure  - Enter the secure sandbox"
        echo "  stop-secure   - Stop the secure sandbox"
        echo "  clean-secure  - Remove secure sandbox and staging"
        echo "  extract       - Copy changes from container to sandbox_staging/"
        echo "  apply         - Apply sandbox_staging/ changes to host"
        echo ""
        echo "=== Utilities ==="
        echo "  status    - Show sandbox status"
        echo ""
        echo "Use 'start-secure' if you want full isolation from host files."
        ;;
esac
