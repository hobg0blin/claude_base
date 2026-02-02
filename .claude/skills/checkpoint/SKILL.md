---
name: checkpoint
description: Save session state to memory files before context compaction
allowed-tools: Read, Write, Edit, Glob
---

# /checkpoint - Save Session State Before Compaction

Use this skill when:
- Approaching context window limits (user mentions "compact" or "running out of context")
- Before a long break or handoff
- After completing a significant piece of work
- User explicitly requests `/checkpoint`

## What This Skill Does

1. **Update session history** (`.claude/memory/sessions/session-history-{DATE}.md`):
   - Add a new section with timestamp
   - Document what was accomplished since last update
   - List files modified/created
   - Note any debugging steps or decision rationale worth preserving

2. **Update PROJECT.md handoff section** (or CLAUDE.md if no PROJECT.md exists):
   - Current status (what's working, what's not)
   - Running servers/processes
   - Uncommitted changes
   - Next steps or outstanding work

3. **Summarize for the user**:
   - Brief summary of what was saved
   - Any critical context that should be mentioned in the compact prompt

## Execution Steps

1. Read the current session history file to see what's already documented
2. Read PROJECT.md (or CLAUDE.md) to see the current handoff state
3. Determine what work has been done since the last update by reviewing:
   - Recent tool calls and their results
   - Files modified in this session
   - Problems solved or in-progress
4. Update both files with new information
5. Report to user what was saved

## Output Format

After updating files, respond with:

```
**Checkpoint saved.**

Session notes updated with:
- [bullet points of what was documented]

Ready for compaction. Key context to preserve:
- [critical items the compact summary should include]
```

## Notes

- Don't duplicate information already in the session history
- Keep the handoff section concise - detailed notes go in session history
- If there are uncommitted code changes, list the files
- If servers are running, note the ports
