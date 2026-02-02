---
name: check-playwright
description: Verify Playwright MCP can connect to Chrome for browser testing
allowed-tools: Bash
---

# Check Playwright MCP Connection

Verify that Playwright MCP is set up and Chrome is available for browser testing.

## Instructions

### Step 1: Check if Playwright MCP is configured

```bash
claude mcp list
```

If "playwright" is not listed, add it:

```bash
claude mcp add playwright npx '@playwright/mcp@latest'
```

Then tell the user to **restart Claude Code** for the MCP to load.

### Step 2: Check if Chrome is reachable

```bash
curl -s http://192.168.65.254:9222/json/version 2>/dev/null && echo "✅ Chrome reachable" || echo "❌ Chrome NOT reachable"
```

If Chrome is not reachable, tell the user to run this in **WSL**:

```bash
google-chrome --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0 --no-sandbox --user-data-dir=/tmp/chrome-debug --remote-allow-origins=*
```

### Step 3: Verify MCP tools are available

Check if you have access to tools like `mcp__playwright__browser_navigate`. If not, user needs to restart Claude Code.

## Summary for User

Both conditions must be true:
1. `claude mcp list` shows "playwright"
2. Chrome is running with remote debugging on port 9222

After both are set up, **restart Claude Code** for the MCP tools to become available.
