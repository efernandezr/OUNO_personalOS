---
description: Create a checkpoint commit with all current changes
---

# Checkpoint

Create a comprehensive checkpoint commit following PersonalOS conventions.

## Instructions

### 1. Pre-flight Checks

First, verify the repository state:

```bash
git status
git diff --stat
```

**Safety Check**: Ensure no personal configs are accidentally staged:
- `config/*.yaml` files should NOT appear (they're gitignored)
- `outputs/`, `brain-dumps/`, `logs/` should NOT appear
- `.claude/settings.local.json` should NOT appear

If any of these appear, check `.gitignore` is working correctly.

### 2. Analyze Changes

Understand what's being committed:

```bash
# See all changes
git status

# See detailed diff for modified files
git diff

# Check recent commit style
git log -5 --oneline
```

### 3. Stage All Changes

```bash
git add -A
```

Verify staging:
```bash
git status
```

### 4. Create Commit Message

Follow PersonalOS commit conventions (from CLAUDE.md):

**Format:**
```
type: short description (50-72 chars)

- Detail 1
- Detail 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Commit Types:**
| Type | Use For |
|------|---------|
| `feat` | New features, commands, capabilities |
| `fix` | Bug fixes |
| `docs` | Documentation updates (README, CLAUDE.md) |
| `refactor` | Code restructuring without behavior change |
| `chore` | Maintenance, config updates, dependencies |

**Examples:**
- `feat: add /weekly-dashboard command`
- `fix: resolve Notion sync retry logic`
- `docs: update voice profile documentation`
- `refactor: simplify intelligence-researcher agent`
- `chore: update source URLs in config template`

### 5. Execute Commit

Create the commit with a properly formatted message using HEREDOC:

```bash
git commit -m "$(cat <<'EOF'
type: short description

- What changed
- Why it changed

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### 6. Post-Commit (Optional)

After committing, consider:
- Update `STATUS.md` if significant changes were made
- Run `/sync-status` to refresh project state

## Important Notes

- **Include everything**: Don't skip files - this is a checkpoint
- **Be descriptive**: Someone reading `git log` should understand what was accomplished
- **Framework only**: Only framework files should be committed (templates, commands, agents, docs)
- **Personal data stays local**: Configs, outputs, brain-dumps are gitignored for a reason

## When to Use

Use `/checkpoint` when you want to:
- Save progress on framework development
- Create a restore point before major changes
- Prepare for pushing to GitHub
- Document a completed feature or fix
