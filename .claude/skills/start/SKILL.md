---
name: start
description: Initialize a new session - check date, create handoff, summarize status
allowed-tools: Read, Write, Edit, Glob
---

# Start New Session

Initialize a new Claude Code session by checking the date, creating session files, and summarizing current status.

## Instructions

### Step 1: Check Dates

1. Read `/app/.claude/memory/HISTORY.md` to find the last session date
2. Compare to today's date
3. List files in `/app/.claude/memory/sessions/` to see existing session files

### Step 2: Create Session File (if new day)

If today's date differs from the last logged session:

1. Create a new session file at `/app/.claude/memory/sessions/session-history-{DATE}.md` using format like `session-history-feb02.md`

Template:
```markdown
# Session History - {Full Date}

## Session Start

**Starting state:** [Brief description of where things left off]

**Outstanding items from previous session:**
- [List any incomplete work from HISTORY.md or previous handoff]

---

## Work Log

(Session notes will be added here as work progresses)
```

### Step 3: Update Handoff in CLAUDE.md

Update the "Current Session Handoff" section in `/app/CLAUDE.md` with:
- Today's date
- Current status
- Outstanding work items

### Step 4: Report to User

Summarize:
- Session date initialized
- Current project status (from HISTORY.md)
- Outstanding/remaining work items
- Ask what they'd like to work on

## Notes

- If it's the same day as the last session, just report current status without creating new files
- Keep handoff notes concise - detailed context goes in session-history files
