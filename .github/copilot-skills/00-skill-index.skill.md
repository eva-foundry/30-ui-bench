---
skill: 00-skill-index
version: 1.0.0
project: 30-ui-bench
last_updated: 2026-03-15
---

# Skill Index -- UI Bench

> This is the skills menu for 30-ui-bench.
> Read this file first when the user asks: "what skills are available", "what can you do", or "list skills".
> Then read the matched skill file in full before starting any work.

## Project Context

**Goal**: Screen-factory governance and handoff support for Project 37 client work
**37-data-model record**: `GET /model/projects/30-ui-bench`

Current operating model:

- Project 30 owns sprint framing, acceptance rules, handoff notes, and reusable UI delivery guidance.
- Project 37 owns runtime data, routes, contracts, and the active `37-data-model/ui` client surface.
- This index is intentionally small until repeated screen-factory workflows justify dedicated skill files.

---

## Available Skills

| # | File | Trigger phrases | Purpose |
| --- | --- | --- | --- |
| 0 | 00-skill-index.skill.md | list skills, what can you do, skill menu | This index |
| 1 | none published yet | execute handoff, wave 2 routes, acceptance audit, dependency note | Use the repo instructions plus the current handoff packet directly until a recurring workflow is formalized |

---

## Skill Creation Guide

When recurring workflows appear, add numbered skill files under `.github/copilot-skills/` and keep the scope narrow.

Suggested layout:

```text
.github/copilot-skills/
  00-skill-index.skill.md
  01-screen-generation.skill.md
  02-acceptance-audit.skill.md
```

Suggested sections for any new skill file:

- frontmatter with `skill`, `version`, and `triggers`
- context
- steps
- validation
- anti-patterns

---

*Current state*: No project-specific skill files are published beyond this index.
