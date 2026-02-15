---
description: Analyze writing samples to calibrate voice profile with optional inspiration blending
---

# /voice-calibrate

Analyze your writing samples to extract voice characteristics and update the voice profile. Optionally blend in techniques from admired writers via inspiration samples.

## Usage

```
/voice-calibrate [options]
```

## Parameters (Optional)

- `--auto-approve`: Apply all recommendations without review (default: false)
- `--min-samples`: Minimum samples required (default: 1)
- `--platform`: Filter to specific platform — `linkedin`, `newsletter`, `all` (default)
- `--focus`: Calibration focus — `tone`, `vocabulary`, `patterns`, `structure`, `all` (default)
- `--no-inspiration`: Skip inspiration samples even if they exist
- `--inspiration-weight`: Override total inspiration influence (range: 0.1 to 0.3, capped at 30%)

## Orchestration Flow

```
Orchestrator                     →     Agents
─────────────────────────────────────────────────────────
1. Scan core sample directories (your writing)
1b. Scan inspiration directories (admired writers)
2. Load all sample content with metadata
2b. Load inspiration samples with frontmatter
2c. Calculate total inspiration weight (cap at 30%)
3. Load current voice-profile.yaml
4. Check sample count vs --min-samples
5. Construct calibration input
                                 →    6. voice-calibration-agent (analysis + blending)
                                 →    7. Return analysis + recommendations
8. Receive + validate JSON       ←
9. Present recommendations (unless --auto-approve)
10. Update voice-profile.yaml (if approved)
11. Generate calibration report
12. Update .metadata.yaml + write agent log
```

## Execution Steps

### Step 1: Scan Core Sample Directories

Scan for YOUR writing samples:
- `1-capture/voice-samples/linkedin-posts/*.md`
- `1-capture/voice-samples/newsletter-samples/*.md`

Read `1-capture/voice-samples/.metadata.yaml` for engagement data if available.

### Step 1b: Scan Inspiration Directories

Unless `--no-inspiration`, scan:
- `1-capture/voice-samples/inspiration/linkedin/**/*.md`
- `1-capture/voice-samples/inspiration/newsletter/**/*.md`

Skip README.md files.

### Step 2: Load Sample Content

For each core sample: read file, parse frontmatter (date, engagement, topics), build samples array:
```json
{ "id": "filename", "type": "linkedin|newsletter", "content": "text", "date": "YYYY-MM-DD", "engagement": {...}, "topics": [] }
```

If no core samples found: display warning with directory paths and instructions, exit.

### Step 2b: Load Inspiration Samples

For each inspiration sample: read file, parse YAML frontmatter. Required fields: `author`, `source_url`, `date`, `style_traits`, `why_admired`. Extract `influence_weight` (default: 0.2).

Skip samples with missing required frontmatter (log warning with filename).

```json
{ "id": "filename", "type": "linkedin|newsletter", "content": "text", "author": "name", "source_url": "url", "style_traits": [], "why_admired": "reason", "influence_weight": 0.2 }
```

### Step 2c: Calculate Inspiration Weight

```
total_weight = sum(sample.influence_weight)
capped_weight = min(total_weight, 0.30)
if --inspiration-weight: capped_weight = min(param, 0.30)
```

If weight capped: show notice "Inspiration weight capped at 30%".

### Step 3: Load Current Voice Profile

Read `config/voice-profile.yaml` for current tone, vocabulary, patterns, structure.

### Step 4: Check Sample Count

If `samples < min_samples`: show message with counts and confidence levels (1-4: low, 5-10: medium, 10+: high), suggest `--min-samples` override.

### Step 5: Invoke Voice Calibration Agent

Follow **Agent Invocation** in `agent-execution-guide.md` with:
- Agent: `voice-calibration-agent`, Model: `sonnet`
- Input: samples, inspiration_samples (or `[]`), current_profile, min_samples, focus_areas

Validate per `agent-execution-guide.md` → **JSON Validation** against `schemas.json → agents.voice-calibration-agent`.

### Step 6: Present Recommendations

If NOT `--auto-approve`, display in readable format:

**Core Voice section**: Tone changes, vocabulary additions (preferred terms, avoid list), pattern additions (openers, closers) — each with reason and [y/n] prompt.

**Inspiration section** (if applicable): Techniques to adopt (from which author, their example, how to adapt), vocabulary from inspiration — each with [y/n] prompt.

**Blend Summary**: core_weight% + inspiration_weight%, rationale.

Use AskUserQuestion for batch approvals.

### Step 7: Update Voice Profile

If approved, update `config/voice-profile.yaml`:
- Tone: primary, attributes
- Vocabulary: preferred, include_often, avoid
- Patterns: openers, closers
- Status: "calibrated", last_calibrated, calibration_confidence, sample_count
- If inspiration used, add `calibration` section with blend weights, inspiration_sources, blend_summary

### Step 8: Generate Calibration Report

Write to: `2-research/analysis/{YYYY-MM-DD}-voice-calibration.md`

Report structure:
- Header: Core samples count, inspiration samples count, voice blend percentages, confidence
- Sample Summary: platform breakdown table, inspiration sources table
- Core Voice Analysis: sentence structure, vocabulary patterns, rhetorical patterns, tone assessment
- Inspiration Analysis (if applicable): extracted traits, complementary/conflicting classification
- Changes Applied: tone, vocabulary, pattern updates (from core and inspiration)
- Voice Blend Summary
- Confidence Factors and Next Steps

### Step 9: Write Agent Log + Update Metadata

- Agent log: `system/logs/{YYYY-MM-DD}-voice-calibration-agent.json`
- Update `1-capture/voice-samples/.metadata.yaml`: last_calibration, calibration_count, calibration_history entry

## Edge Cases

- **No samples**: Show directory paths and instructions, exit without error
- **Single platform only**: Proceed, note "partial" coverage in confidence
- **No inspiration samples**: Valid mode — pass `[]`, agent does core-only calibration
- **Invalid inspiration frontmatter**: Skip sample, log warning, continue
- **Inspiration weight > 0.30**: Cap at 30%, show notice
- **Conflicting traits**: Present in recommendations, default to skip, allow user override

## Agent Reference

- **Voice Calibration Agent**: `.claude/agents/voice-calibration-agent.md`
