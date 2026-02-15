---
description: Create a checkpoint commit with all current changes
---

# Checkpoint

Create a comprehensive checkpoint commit following PersonalOS conventions.

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `--push` | No | Push to remote immediately after commit |

## Instructions

### 1. Pre-flight Checks

```bash
git status
git diff --stat
```

**Safety Check**: Ensure no personal configs are staged:
- `config/*.yaml` should NOT appear (gitignored)
- `2-research/`, `1-capture/brain-dumps/`, `system/logs/` should NOT appear
- `.claude/settings.local.json` should NOT appear

### 2. Analyze Changes

```bash
git status
git diff
git log -5 --oneline
```

### 3. Stage All Changes

```bash
git add -A
git status  # verify
```

### 4. Create Commit

Follow PersonalOS conventions — types: `feat`, `fix`, `docs`, `refactor`, `chore`

```bash
git commit -m "$(cat <<'EOF'
type: short description

- What changed
- Why it changed

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

### 5. Push to Remote (if --push)

```bash
# Auto-set upstream if needed
git push -u origin $(git branch --show-current)
```

## Important Notes

- **Include everything**: This is a checkpoint — don't skip files
- **Be descriptive**: `git log` readers should understand what was accomplished
- **Framework only**: Only framework files get committed (templates, commands, agents, docs)
- **Personal data stays local**: Configs, outputs, brain-dumps are gitignored
