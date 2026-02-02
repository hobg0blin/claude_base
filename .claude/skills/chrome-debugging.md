# Chrome Remote Debugging for Playwright MCP

## Current Working Setup (January 2026)

**Architecture**: Docker container in WSL2 → Chrome running in WSL (with GUI via WSLg)

### Step 1: Start Chrome in WSL (not Windows)

```bash
# In WSL terminal (Rocky Linux)
google-chrome --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0 --no-sandbox --disable-dev-shm-usage --user-data-dir=/tmp/chrome-debug --remote-allow-origins=*
```

To run in background:
```bash
nohup google-chrome --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0 --no-sandbox --disable-dev-shm-usage --user-data-dir=/tmp/chrome-debug --remote-allow-origins=* > ~/chrome-debug.log 2>&1 &
```

**Required flags:**
- `--user-data-dir` - Chrome ignores debug port without this
- `--remote-debugging-address=0.0.0.0` - Allow non-localhost connections
- `--no-sandbox` - Required for WSL
- `--disable-dev-shm-usage` - Prevents shared memory issues
- `--remote-allow-origins=*` - Allow cross-origin connections

### Step 2: Configure Playwright MCP

Edit `/home/sandbox/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/playwright/.mcp.json`:

```json
{
  "playwright": {
    "command": "npx",
    "args": ["@playwright/mcp@latest", "--cdp-endpoint", "http://192.168.65.254:9222"]
  }
}
```

**Key insight**: Chrome rejects connections with `Host: host.docker.internal` header, but accepts IP addresses. The IP `192.168.65.254` is what `host.docker.internal` resolves to from Docker.

### Step 3: Restart Claude Code

After changing the MCP config, restart Claude Code for it to take effect.

---

## Why Windows Chrome Didn't Work

We tried running Chrome on Windows with remote debugging, but Chrome's DevTools server rejects any HTTP request where the `Host` header isn't `localhost` or an IP address. Playwright MCP sends `Host: host.docker.internal`, which Chrome rejects with:
```
Host header is specified and is not an IP address or localhost.
```

Flags like `--remote-allow-origins=*` don't bypass this check.

## Install Chrome in WSL (Rocky Linux)

```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
sudo dnf install -y ./google-chrome-stable_current_x86_64.rpm
```

WSLg (Windows 11) should automatically provide GUI support. Test with `xclock` if needed.

## Troubleshooting

**Command not working? Check for line breaks!**
When copying the Chrome command from Claude, line breaks often get inserted which cause flags to be ignored. Make sure the entire command is on ONE line before running. If Chrome starts but `curl localhost:9222/json/version` fails, this is likely the issue - kill Chrome and try again with the command on a single line.

**Verify Chrome is listening:**
```bash
curl -s http://localhost:9222/json/version  # from WSL
curl -s http://192.168.65.254:9222/json/version  # from Docker container
```

**Check what host.docker.internal resolves to:**
```bash
getent hosts host.docker.internal  # Inside Docker container
```

**If IP changes**, update the `--cdp-endpoint` in the MCP config.
