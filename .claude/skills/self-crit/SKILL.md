---
name: self-crit
description: Step back and reflect when stuck in a loop of failed attempts
allowed-tools: Read, Write, Edit, WebSearch, WebFetch
---

# Self-Critique: Breaking Out of Failure Loops

Use this skill when you notice you're stuck - trying the same approach repeatedly, making incremental fixes that don't work, or getting frustrated user feedback.

## Warning Signs You Need This

- You've tried the same general approach 2+ times without success
- You're adding complexity to fix something that "should work"
- The user is frustrated or has said something like "this is the Nth time"
- You're debugging symptoms (paths, permissions, syntax) instead of questioning the approach
- You're guessing at solutions instead of looking them up

## Step 1: STOP

Do not make another attempt. Do not run another command. Stop.

## Step 2: State the Problem Clearly

Write out:
1. What are you trying to accomplish?
2. What have you tried? (List each distinct approach)
3. What happened each time?

## Step 3: Question Your Assumptions

Ask yourself:
- "Is this the standard/recommended way to do this?"
- "Am I using the right tool for this job?"
- "Is there an official CLI command or API for this?"
- "Have I actually read the documentation, or am I guessing?"
- "Am I solving the right problem?"

## Step 4: Search for Documentation

Before trying anything else:

1. **Web search** for the official/standard way to do this thing
2. **Look for CLI help**: `<tool> --help`, `<tool> <command> --help`
3. **Check if there's a dedicated command** instead of manual file editing

Example searches:
- "how to configure [thing] [tool name]"
- "[tool name] [thing] setup official docs"
- "[error message] [tool name]"

## Step 5: Consider the User

- They may know the answer - ask them directly
- They can search the web faster than you can guess
- Their frustration is valid feedback that your approach is wrong

## Step 6: Document and Reset

Before trying a new approach:
1. Document what you tried and why it failed (in session notes)
2. Delete/revert any partial changes from failed attempts
3. Start fresh with the new approach

## Common Failure Patterns

### Pattern: "Just need to fix this one thing"
**Reality:** If you're on fix #3 for the same problem, the approach is wrong.

### Pattern: "The config looks correct but doesn't work"
**Reality:** You're probably configuring the wrong file, wrong format, or there's a CLI command that does this.

### Pattern: "It worked before / should work"
**Reality:** Something changed, or you're misremembering. Verify from scratch.

### Pattern: Adding complexity (scripts, wrappers, workarounds)
**Reality:** The simple approach exists; you haven't found it yet.

### Pattern: Debugging paths, permissions, timing
**Reality:** You're treating symptoms. The root cause is usually "wrong approach."

## Example Self-Critique

**Problem:** Playwright MCP not loading after 5 Claude Code restarts

**What I tried:**
1. Created manual `.mcp.json` file - didn't work
2. Wrote setup script to modify `~/.claude.json` - didn't work
3. Fixed paths in setup script (`$HOME` → `/home/sandbox`) - didn't work
4. Added file permissions fixes - didn't work

**Questioning assumptions:**
- "Is manually editing config files the right way?" - NO
- "Is there a CLI command for this?" - YES: `claude mcp add`

**What I should have done:**
- After attempt #2 failed, searched "how to add MCP server to Claude Code"
- Would have found `claude mcp add` immediately

**Lesson:** I was treating symptoms (paths, permissions) when the root cause was "wrong approach entirely."

## After Using This Skill

1. Tell the user what you learned
2. Try the correct approach
3. If it still doesn't work, ask the user for help - they have access to resources you don't
