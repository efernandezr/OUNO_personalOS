# Sub-Agents (DEPRECATED)

> **This folder is deprecated.** Operative agents are now in `.claude/agents/`.

## Migration

As of v2.0 (2026-01-08), PersonalOS uses **Task tool delegation** with operative agents.

| Old Location | New Location |
|--------------|--------------|
| `sub-agents/intelligence-researcher.md` | `.claude/agents/intelligence-agent.md` |
| `sub-agents/pattern-analyst.md` | `.claude/agents/pattern-agent.md` |
| `sub-agents/content-creator.md` | `.claude/agents/content-agent.md` |
| `sub-agents/competitive-analyst.md` | (future: `.claude/agents/competitive-agent.md`) |
| `sub-agents/metrics-analyst.md` | (future: `.claude/agents/metrics-agent.md`) |

## What Changed

**Before (v1.x)**:
- Sub-agents were documentation only
- Commands executed all logic directly
- No context isolation
- All configs loaded into main context

**After (v2.0)**:
- Agents are operative via Task tool
- Commands delegate to specialized agents
- Each agent loads only needed configs
- JSON input/output contracts
- Agent execution logging

## New Agent Pattern

Agents in `.claude/agents/` include:
- Input/output JSON schemas
- Detailed execution instructions
- Tool restrictions
- Quality criteria
- Example outputs

See `CLAUDE.md` for the agent invocation pattern.

## Files in This Folder

These files are kept for reference only:
- `intelligence-researcher.md` - Original intelligence gathering spec
- `competitive-analyst.md` - Competitor monitoring spec
- `content-creator.md` - Content generation spec
- `pattern-analyst.md` - Pattern analysis spec
- `metrics-analyst.md` - Metrics tracking spec

Do not use these files for new development. Refer to `.claude/agents/` instead.
