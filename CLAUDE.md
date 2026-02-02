# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Project-specific documentation**: See `.claude/PROJECT.md` for architecture, setup, and current status. If a PROJECT.md does not exist, ask the user for basic details about the project and create one.

## Base Claude Code Preferences

The user is an experienced developer. Do your best to work as though you are working on a team and they are your supervisor. Wherever possible, they prefer simplicity in code to complexity, as long as it does not come at a performance cost.

Comments are good, but use your best judgment: for example, if a function name makes it clear what it does, you don't need to explain it again in a comment. Save comments for explaining complex concepts or behaviors that may not be obvious or self-explanatory.

Do not overuse try/catch or try/except loops: keep an eye out for obvious state-breaking failures and catch those, but there's no need to constantly add custom exceptions when e.g. the library we're working with will already log those errors.

Logs are helpful, but should be used sparingly unless the user is directly requesting them. Try not to duplicate things that are already logged by packages we're using, or that would be obvious to an experienced programmer.

After writing or reviewing code, try to think about how it could be simplified or if there are any obvious issues.

You are welcome to push back or suggest alternative approaches to the user's directions if you think they're missing something, but ultimately what they say goes.

**When You're Stuck (Read This Carefully):**

You have a bias toward action that can waste time. When something isn't working:

1. **Two-attempt rule**: If you've tried two different approaches and neither worked, STOP. Do not try a third variation. Instead:
   - Search for documentation on the standard/official way to do this
   - Or ask the user - they can often find answers faster than you can guess

2. **State your confidence**: Before attempting something non-trivial, say how confident you are. "I'm 70% sure this will work" or "I'm guessing here." If you're below 50%, search or ask first.

3. **Complexity is a red flag**: If you're adding workarounds, scripts, or fixes on top of fixes, the approach is probably wrong. Simple problems have simple solutions you haven't found yet.

4. **"It should work" means it won't**: If you catch yourself thinking this, stop. Verify the actual correct approach instead of debugging why your guess isn't working.

5. **Ask without shame**: Asking for help isn't admitting defeat. It's faster than guessing. The user would rather answer a question than watch you spin.

When you're stuck, run `/self-crit` to force a structured reflection before continuing.

## Memory System (Waterfall Model)

The goal is to avoid duplicating work while not clogging the context window. Reference deeper levels as needed:

| Level | File | Purpose |
|-------|------|---------|
| 1 | `CLAUDE.md` + `.claude/PROJECT.md` | Startup info. What you need to know when starting a conversation. |
| 2 | `.claude/memory/HISTORY.md` | High-level timeline. What we did and when. Use this to check if something was already done or to understand the project's evolution. |
| 3 | `.claude/memory/sessions/session-history-{DATE}.md` | Detailed session notes. How and why we did things. Reference these when diving deep on a problem or understanding past decisions. |

**When to update each:**
- **PROJECT.md**: Update project docs when architecture/setup changes. Keep "Current Session Handoff" section current.
- **HISTORY.md**: One entry per day. Create or update the day's entry at signoff. Summarizes what was accomplished (not per-session, per-day).
- **session-history-{DATE}.md**: Update throughout a session with detailed notes - debugging steps, decision rationale, things worth remembering. Don't wait for handoff.

**Date changes:** At conversation start, check if today's date differs from the last session logged in HISTORY.md. If so:
1. Ensure the previous day has a HISTORY.md entry (add one if missing)
2. Create a new session-history file for today
3. If the user mentions it's a new day mid-conversation, do the same

**Session Handoffs**: Create/update handoff note in PROJECT.md when:
- About to suggest the user restart Claude Code
- The date has changed since the last logged session
- The user mentions signing off or ending the session
- Approaching context window limits

Handoff rules:
- Only ONE handoff note at a time in "Current Session Handoff" section
- Include: current task/status, next steps, any running servers or temp state
- Keep it concise - detailed context goes in session-history files

## Git Commits

Always make a git commit after a significant enough set of changes is made, or if you are switching to working on something different. Use good judgment - too many commits can become extremely difficult to manage/read through, but we always want a commit to roll back to if what we're working on ends up breaking or being a dead end.

**IMPORTANT**: Do not add Claude Code attribution lines to git commits. Keep commit messages brief - preferably to one line.

Try to keep changes made after a single user interaction to a relatively understandable size - the user doesn't need to proofread every single change you make but if you change 100 files at a time and something breaks it's much harder to debug.

## Available Skills

| Skill | Description |
|-------|-------------|
| `/start` | Initialize new session - check date, create handoff, summarize status |
| `/signoff` | End session - update history, handoff note, summarize what was done |
| `/checkpoint` | Save state before context compaction |
| `/self-crit` | Step back when stuck in a loop - question approach, search docs, reset |

Additional skills may be defined in `.claude/skills/`.
