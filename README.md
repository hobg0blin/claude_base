# LORD HELP ME

I have finally decided to follow in the footsteps of every other programmer and developed my own memory management system for Claude Code. I do not know what "beads" is and I find Gas Town terrifying but I wanted to build out a bit of scaffolding so that Claude would remember what it had done in previous sessions. This is where I wound up.

Basically:


### Overview

`PROJECT.md`:

- Project-specific details, structure, documentation, TODOs, etc.


`memory/` folder:

- `HISTORY.md`: overarching log of everything Claude's done, big picture stuff.

- `./sessions/`: session-specific notes - more detailed log of choices made and problems solved.

Key skills:

- `/start`: check history for where we're at, give a quick status report

- `/checkpoint`: save status/recent work to history before compacting

- `/signoff`: do the same but to prepare for a handoff to another Claude session

- `/self-crit`: make Claude reflect on its actions when it gets stuck in a loop. I considered calling this "shame" but it felt cruel.

### Sandbox 
`claude-sandbox/`:
- Mostly untested generic version of a local Docker container I run Claude in, just intended allow me to run --dangerously-skip-permissions with a minimum of danger. Presumably unnecessary for anyone with a system compatible with the standard Claude sandbox, but as a punished WSL user I have to do this myself.


---

This is a work in progress, do not email me, etc.
