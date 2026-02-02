---
name: signoff
description: End session - update session history, handoff note, and HISTORY.md if needed
allowed-tools: Read, Write, Edit, Glob
---

# Sign Off / End Session

Properly close out a Claude Code session by updating all memory files.

## Instructions

### Step 1: Gather Session Context

1. Read the current session file from `/app/.claude/memory/sessions/session-history-{DATE}.md`
2. Read `/app/CLAUDE.md` to see current handoff state
3. Review conversation to identify what was accomplished this session

### Step 2: Update Session History File

Update today's session file (`/app/.claude/memory/sessions/session-history-{DATE}.md`) with:
- Summary of work completed
- Any issues encountered
- Decisions made and rationale
- Any incomplete work or next steps

### Step 3: Update CLAUDE.md Handoff

Update the "Current Session Handoff" section with:
- Today's date
- Brief status summary
- What was done this session (bullet points)
- Any running servers or temporary state to be aware of
- Outstanding work / next steps

### Step 4: Update HISTORY.md (if significant)

If the session included significant milestones (features completed, major bugs fixed, architectural changes), add a dated entry to `/app/.claude/memory/HISTORY.md`.

Skip this for minor sessions (small fixes, exploration, documentation only).

### Step 5: Report to User

Provide a brief summary:
- What was accomplished
- What's documented where
- Any next steps or outstanding items
- Confirm they're ready to close the session

### Step 6: Check and Commit Git Changes

Usually the project should have one root-level repository, but there may be multiple. For each repo with uncommitted changes:
- Show the user what changed
- Offer to commit with a brief message summarizing the session's work
- Keep commit messages to one line when possible

## Notes

- Keep handoff notes concise but complete enough for a fresh Claude instance to pick up
- Session history files can be more detailed - that's where the "how and why" lives
- Always check both repos before signing off - uncommitted work can be lost between sessions
- Follow git safety rules: no `--amend`, `--force`, or history rewriting inside the sandbox
