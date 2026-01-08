---
description: Analyze writing samples to calibrate voice profile for authentic content generation
---

# /voice-calibrate

Analyze your writing samples to extract voice characteristics and update the voice profile.

## Usage

```
/voice-calibrate [options]
```

## Parameters

### Optional
- `--auto-approve`: Apply all recommendations without review (default: false)

- `--min-samples`: Minimum samples required to proceed (default: 1)
  - Set to 0 to run with any available samples
  - Higher values require more samples for better accuracy

- `--platform`: Filter to specific platform samples (default: all)
  - `linkedin` - Only LinkedIn posts
  - `newsletter` - Only newsletter samples
  - `all` - All available samples

- `--focus`: Focus calibration on specific areas (default: all)
  - `tone` - Tone characteristics only
  - `vocabulary` - Vocabulary patterns only
  - `patterns` - Rhetorical patterns only
  - `structure` - Platform structures only
  - `all` - Complete calibration

## Orchestration Pattern

This command uses **Task tool delegation** to the `voice-calibration-agent`.

```
Orchestrator (this command)     →     Agents
─────────────────────────────────────────────────────────
1. Parse parameters
2. Scan sample directories
3. Load samples content
4. Load current voice-profile.yaml
5. Construct calibration input
                                 →    6. voice-calibration-agent (analysis)
                                 →    7. Return analysis + recommendations
8. Receive JSON output           ←
9. Present recommendations to user
10. If approved: Update voice-profile.yaml
11. Generate calibration report
12. Update .metadata.yaml with history
13. Update STATUS.md
```

## Execution Steps

### Step 1: Scan Sample Directories (Orchestrator)

Scan these directories for samples:
- `inputs/samples/linkedin-posts/*.md`
- `inputs/samples/newsletter-samples/*.md`

Read `inputs/samples/.metadata.yaml` for engagement data if available.

### Step 2: Load Sample Content (Orchestrator)

For each sample file found:
1. Read the markdown file
2. Parse frontmatter (if present) for date, engagement, topics
3. Extract the content body
4. Build samples array for agent input

If no samples found:
- Display warning message
- Point user to sample directories
- Show instructions for adding samples
- Exit without error

Sample structure:
```json
{
  "id": "filename without extension",
  "type": "linkedin" | "newsletter",
  "content": "full sample text",
  "date": "from frontmatter or file date",
  "engagement": {
    "likes": 0,
    "comments": 0,
    "shares": 0,
    "opens": 0,
    "clicks": 0
  },
  "topics": ["from frontmatter or empty"]
}
```

### Step 3: Load Current Voice Profile (Orchestrator)

Read `config/voice-profile.yaml` to get:
- Current tone settings
- Current vocabulary (preferred, avoid)
- Current patterns (openers, body, closers)
- Current structure preferences

### Step 4: Check Sample Count (Orchestrator)

Compare samples found against `--min-samples` parameter:

If samples < min_samples:
```markdown
## Insufficient Samples

Found {n} samples, but minimum is {min_samples}.

**To proceed**:
- Add more samples to `inputs/samples/`
- Or run with `--min-samples {n}` to proceed anyway

**Confidence levels**:
- 1-4 samples: Low confidence (basic patterns)
- 5-10 samples: Medium confidence (vocabulary + structure)
- 10+ samples: High confidence (full voice fingerprint)
```

### Step 5: Invoke Voice Calibration Agent (Task Tool)

```
Task tool call:
  - description: "Analyze voice samples for calibration"
  - subagent_type: "general-purpose"
  - model: "sonnet"
  - prompt: |
      You are the voice-calibration-agent for PersonalOS.

      [Read and include content of .claude/agents/voice-calibration-agent.md]

      ## Your Task

      Analyze these writing samples to extract voice characteristics:

      ```json
      {
        "samples": [{sample objects}],
        "current_profile": {
          "tone": {from voice-profile.yaml},
          "vocabulary": {from voice-profile.yaml},
          "patterns": {from voice-profile.yaml},
          "structure": {from voice-profile.yaml}
        },
        "min_samples": {from parameter},
        "focus_areas": ["{from --focus parameter}"]
      }
      ```

      Return valid JSON matching the output schema.
```

### Step 6: Process Agent Output (Orchestrator)

The voice-calibration-agent returns:
- `analysis` - Detailed findings (sentence structure, vocabulary, patterns, tone)
- `recommendations` - Specific profile updates with reasons
- `confidence` - Overall confidence level and score

### Step 7: Present Recommendations (Orchestrator)

If NOT `--auto-approve`:

Display recommendations in readable format:

```markdown
# Voice Calibration Analysis

**Samples Analyzed**: {count} ({by platform breakdown})
**Confidence**: {level} ({score}/100)

## Recommended Updates

### Tone
Current: {current}
Recommended: {recommended}
Reason: {reason}
**Apply this change?** [y/n]

### Vocabulary

**Add to preferred terms**:
- use "{term}" instead of "{alternative}" - {reason}
**Apply?** [y/n]

**Add to avoid list**:
- "{term}" - {reason}
**Apply?** [y/n]

### Patterns

**Add opener pattern**:
"{pattern}"
Example: "{example}"
Reason: {reason}
**Apply?** [y/n]

...etc for each recommendation
```

Use AskUserQuestion tool to gather approvals if multiple recommendations.

### Step 8: Update Voice Profile (Orchestrator)

If `--auto-approve` OR user approved changes:

Read current `config/voice-profile.yaml` and update:

For tone updates:
```yaml
tone:
  primary: "{new primary}"
  attributes:
    - "{existing}"
    - "{new attributes}"
```

For vocabulary updates:
```yaml
vocabulary:
  preferred:
    - use: "{new term}"
      instead_of: "{alternative}"
  include_often:
    - "{existing}"
    - "{new terms}"
  avoid:
    - "{existing}"
    - "{new terms}"
```

For pattern updates:
```yaml
patterns:
  openers:
    - type: "{pattern type}"
      example: "{example}"
```

Update status and metadata:
```yaml
status: "calibrated"
last_calibrated: "{ISO date}"
calibration_confidence: "{high|medium|low}"
sample_count: {n}
```

### Step 9: Generate Calibration Report (Orchestrator)

Write to: `outputs/analysis/{YYYY-MM-DD}-voice-calibration.md`

```markdown
# Voice Calibration Report

**Generated**: {timestamp}
**Samples Analyzed**: {count} ({linkedin_count} LinkedIn, {newsletter_count} Newsletter)
**Confidence**: {level} ({score}/100)

## Sample Summary

| Platform | Count | Date Range |
|----------|-------|------------|
| LinkedIn | {n} | {earliest} - {latest} |
| Newsletter | {n} | {earliest} - {latest} |

## Analysis Findings

### Sentence Structure

- **Average length**: {n} words
- **Distribution**: {short%}% short, {medium%}% medium, {long%}% long
- **Complexity**: {simple|moderate|complex}

### Vocabulary Patterns

**Frequently Used Terms** (>20% of samples):
{For each term:}
- **{term}** ({count} times, {percentage}%) - {contexts}

**Unique Expressions**:
{For each:}
- "{expression}"

**Notably Avoided**:
{For each:}
- {term}

### Rhetorical Patterns

**Hook Types**:
{For each:}
| Pattern | Frequency | Example |
|---------|-----------|---------|
| {pattern} | {n}% | "{example}" |

**Closing Types**:
{For each:}
- **{pattern}** ({n}%) - "{example}"

### Tone Assessment

**Detected Primary Tone**: {tone}
**Attributes**: {attributes joined}
**Consistency**: {high|medium|low}

## Changes Applied

### Tone Updates
- Primary: {old} → {new}
- Added attributes: {list}
- Removed attributes: {list}

### Vocabulary Updates
- Added to preferred: {list}
- Added to include_often: {list}
- Added to avoid: {list}

### Pattern Updates
- Added openers: {list}
- Added closers: {list}

## Confidence Factors

- **Sample Size**: {assessment} - {recommendation}
- **Consistency**: {assessment} - {notes}
- **Platform Coverage**: {assessment} - {missing}

## Next Steps

{If confidence < high:}
1. Add more samples to improve calibration accuracy
2. Include samples from different time periods
3. Add samples from missing platforms: {list}

{If confidence high:}
1. Voice profile is well-calibrated
2. Run `/content-repurpose` to test new settings
3. Re-calibrate quarterly or after voice evolution
```

### Step 10: Write Agent Log (Orchestrator)

Write to: `outputs/logs/{YYYY-MM-DD}-voice-calibration-agent.json`

Include: input summary, output, timestamp, changes applied

### Step 11: Update Metadata (Orchestrator)

Update `inputs/samples/.metadata.yaml`:

```yaml
last_calibration: "{ISO date}"
calibration_count: {increment by 1}

calibration_history:
  - date: "{ISO date}"
    samples_analyzed: {n}
    confidence: "{level}"
    changes_made:
      - "{description of change 1}"
      - "{description of change 2}"
```

### Step 12: Update STATUS.md (Orchestrator)

1. Set **Last Command** to `/voice-calibrate`
2. Set **Last Output** to the calibration report path
3. Add entry to **Activity Log**
4. Update **Voice Profile** status in Config Summary

## Agent Reference

- **Voice Calibration Agent**: `.claude/agents/voice-calibration-agent.md`

## Confidence Levels

| Level | Score | Samples | Reliability |
|-------|-------|---------|-------------|
| Low | 0-40 | 1-4 | Basic vocabulary patterns only |
| Medium | 41-70 | 5-10 | Vocabulary + structure patterns |
| High | 71-100 | 10+ | Full voice fingerprint |

## What Gets Analyzed

- **Sentence structure**: Length, complexity, patterns
- **Vocabulary**: Frequently used terms, unique expressions, avoided terms
- **Rhetorical patterns**: Hook types, transitions, closing patterns
- **Tone**: Overall tone, attributes, consistency
- **Platform patterns**: Platform-specific formatting and length preferences

## When to Re-calibrate

- After adding 5+ new samples
- Quarterly (voice evolves over time)
- After receiving feedback that content doesn't "sound like you"
- Before major content campaigns

## Example Output Location

```
outputs/analysis/2026-01-08-voice-calibration.md
```

## Performance Target

- Analysis: < 2 minutes
- Full process with approval: < 5 minutes

## Handling Edge Cases

### No Samples Found

```markdown
## No Samples Found

The sample directories are empty:
- `inputs/samples/linkedin-posts/`
- `inputs/samples/newsletter-samples/`

**To add samples**:
1. Copy LinkedIn posts to `inputs/samples/linkedin-posts/`
2. Copy newsletter content to `inputs/samples/newsletter-samples/`
3. Run `/voice-calibrate` again

See README.md files in each directory for formatting instructions.
```

### Single Platform Only

If only one platform has samples, proceed but note in confidence:
- Platform coverage: "partial"
- Recommend adding samples from other platforms
- Calibration still valid for the available platform

### Low Engagement Data

If engagement data not provided in metadata:
- Proceed without weighting by performance
- Note in report that high-performer analysis unavailable
- Recommend adding engagement data for better calibration
