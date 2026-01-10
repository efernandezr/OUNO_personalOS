---
description: Rebuild STATUS.md to restore project state after /clear or manual changes
---

# /sync-status

Rebuild STATUS.md by scanning the project state. Use this to restore accurate status after manual changes or if STATUS.md becomes stale.

## Usage

```
/sync-status
```

No parameters required. The command scans the project and rebuilds STATUS.md.

## Execution Steps

### 1. Scan Output Directories

Check each output folder for recent files:

```
2-research/
├── market-briefs/   → List files, note most recent
├── daily-briefs/    → Check if empty or has content
├── analysis/        → Check if empty or has content
├── competitive/     → Check if empty or has content
└── dashboards/      → Check if empty or has content

3-content/
├── linkedin/        → Check if empty or has content
├── newsletter/      → Check if empty or has content
└── twitter/         → Check if empty or has content
```

### 2. Read Config Summaries

For each config file, extract key counts:

| Config | What to Count |
|--------|---------------|
| topics.yaml | Number of primary, secondary, emerging topics |
| sources.yaml | Count by type (blogs, newsletters, news, industry, research) |
| competitors.yaml | Count by tier |
| goals.yaml | Check if metrics are at 0 or have values |
| voice-profile.yaml | Read the `status` field |
| notion-mapping.yaml | Count configured databases |

### 3. Check Input Directories

```
1-capture/brain-dumps/         → Check if any .md files exist
1-capture/voice-samples/      → Check if voice samples exist
1-capture/documents/         → Check if PDFs exist
```

### 4. Determine Last Command

- Find most recent file in 2-research/
- Extract date and infer command from folder location

### 5. Build Activity Log

- Read existing STATUS.md if it exists
- Preserve activity log entries from last 30 days
- Add any new outputs discovered

### 6. Generate STATUS.md

Write the rebuilt file with:
- Updated timestamp
- Accurate Quick State section
- Updated checklists (Working / Pending)
- Preserved activity log (last 30 days)
- Fresh config summaries
- Suggested next actions based on gaps

## Output Format

```markdown
# PersonalOS Status

> Last updated: {CURRENT_DATE}
> Run `/sync-status` to rebuild this file from project state

## Quick State
...

## What's Working
...

## What's Pending
...

## Recent Activity Log
...

## Next Suggested Actions
...

## Config Summaries
...

## Commands Available
...
```

## Logic for "What's Pending"

Mark as pending if:
- `1-capture/brain-dumps/` is empty → "Brain dumps - no notes captured"
- `voice-profile.yaml` status is "placeholder" → "Voice calibration pending"
- `3-content/` is empty → "Content outputs - none generated"
- `2-research/competitive/` is empty → "Competitive tracking - not started"
- `2-research/market-briefs/` is empty → "Intelligence archive - no deep scans"
- `goals.yaml` all metrics are 0 → "Goals baseline - needs setting"

## Logic for "Next Suggested Actions"

Generate 3-4 suggestions based on gaps:
1. If no brain dumps → "Capture first brain dump"
2. If no intelligence scans → "Run /market-intelligence"
3. If voice not calibrated → "Add voice samples for calibration"
4. If goals at 0 → "Set baseline metrics in goals.yaml"
5. If no content → "Run /content-repurpose on recent insights"

## Post-Execution

After rebuilding STATUS.md:
1. Display summary of what changed
2. Show the new Quick State section
3. Highlight any issues found (e.g., config errors)

## Notes

- This command is read-only except for STATUS.md
- Safe to run anytime without side effects
- Preserves activity log history (last 30 days)
- Good practice to run after `/clear` if STATUS.md seems stale
