---
description: Analyze writing samples to calibrate voice profile with optional inspiration blending
---

# /voice-calibrate

Analyze your writing samples to extract voice characteristics and update the voice profile. Optionally blend in techniques from admired writers via inspiration samples.

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

- `--no-inspiration`: Skip inspiration samples even if they exist (default: false)
  - Use this to calibrate only from your own writing

- `--inspiration-weight`: Override total inspiration influence (default: calculated from samples)
  - Range: 0.1 to 0.3 (inspiration capped at 30% to preserve core voice)
  - Example: `--inspiration-weight 0.15` for subtle inspiration influence

## Orchestration Pattern

This command uses **Task tool delegation** to the `voice-calibration-agent`.

```
Orchestrator (this command)     →     Agents
─────────────────────────────────────────────────────────
1. Parse parameters
2. Scan core sample directories (your writing)
3. Scan inspiration directories (admired writers)
4. Load all sample content with metadata
5. Load current voice-profile.yaml
6. Construct calibration input (samples + inspiration_samples)
                                 →    7. voice-calibration-agent (analysis + blending)
                                 →    8. Return analysis + blended recommendations
9. Receive JSON output           ←
10. Present recommendations with attribution
11. If approved: Update voice-profile.yaml with blend info
12. Generate calibration report (with inspiration section)
13. Update .metadata.yaml with history
```

## Execution Steps

### Step 1: Scan Core Sample Directories (Orchestrator)

Scan these directories for YOUR writing samples:
- `1-capture/voice-samples/linkedin-posts/*.md`
- `1-capture/voice-samples/newsletter-samples/*.md`

Read `1-capture/voice-samples/.metadata.yaml` for engagement data if available.

### Step 1b: Scan Inspiration Directories (Orchestrator)

Unless `--no-inspiration` is set, scan for inspiration samples:
- `1-capture/voice-samples/inspiration/linkedin/**/*.md`
- `1-capture/voice-samples/inspiration/newsletter/**/*.md`

Skip README.md files (they contain instructions, not samples).

### Step 2: Load Core Sample Content (Orchestrator)

For each core sample file found:
1. Read the markdown file
2. Parse frontmatter (if present) for date, engagement, topics
3. Extract the content body
4. Build samples array for agent input

If no core samples found:
- Display warning message
- Point user to sample directories
- Show instructions for adding samples
- Exit without error

Core sample structure:
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

### Step 2b: Load Inspiration Sample Content (Orchestrator)

For each inspiration sample file found:
1. Read the markdown file
2. Parse YAML frontmatter (REQUIRED fields: author, source_url, date, style_traits, why_admired)
3. Extract `influence_weight` (default: 0.2 if not specified)
4. Extract the content body
5. Determine platform from folder path (`inspiration/linkedin/` or `inspiration/newsletter/`)
6. Build inspiration_samples array for agent input

If inspiration sample missing required frontmatter:
- Log warning with filename
- Skip the sample
- Continue with others

Inspiration sample structure:
```json
{
  "id": "filename without extension",
  "type": "linkedin" | "newsletter",
  "content": "full sample text",
  "date": "from frontmatter",
  "author": "from frontmatter (REQUIRED)",
  "source_url": "from frontmatter (REQUIRED)",
  "style_traits": ["from frontmatter (REQUIRED)"],
  "why_admired": "from frontmatter (REQUIRED)",
  "influence_weight": 0.2
}
```

### Step 2c: Calculate Total Inspiration Weight (Orchestrator)

```
total_weight = sum(sample.influence_weight for sample in inspiration_samples)
capped_weight = min(total_weight, 0.30)  # Cap at 30%

if --inspiration-weight provided:
    capped_weight = min(inspiration_weight_param, 0.30)
```

Display inspiration summary:
```markdown
**Inspiration Sources Found**: {n} samples from {unique_authors} authors
**Total Inspiration Weight**: {capped_weight * 100}%
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
- Add more samples to `1-capture/voice-samples/`
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

      Analyze these writing samples to extract voice characteristics and blend with inspiration:

      ```json
      {
        "samples": [{core sample objects - user's own writing}],
        "inspiration_samples": [{inspiration sample objects - admired writers}],
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

**Note**: If no inspiration samples found, pass `"inspiration_samples": []` - the agent handles this gracefully and performs core-only calibration.

### Step 6: Process Agent Output (Orchestrator)

The voice-calibration-agent returns:
- `analysis` - Detailed findings (sentence structure, vocabulary, patterns, tone)
- `analysis.inspiration_analysis` - If inspiration samples provided: extracted traits, complementary/conflicting analysis
- `analysis.blended_voice_summary` - If inspiration samples provided: blend weights and adopted traits
- `recommendations` - Specific profile updates with reasons
- `recommendations.inspiration_adoptions` - If inspiration samples provided: patterns, vocabulary, techniques to adopt
- `calibration_blend` - Blend configuration for voice profile
- `confidence` - Overall confidence level and score

### Step 7: Present Recommendations (Orchestrator)

If NOT `--auto-approve`:

Display recommendations in readable format:

```markdown
# Voice Calibration Analysis

**Core Samples Analyzed**: {count} ({by platform breakdown})
**Inspiration Samples**: {count} from {authors}
**Voice Blend**: {core_weight}% core + {inspiration_weight}% inspiration
**Confidence**: {level} ({score}/100)

---

## From Your Writing (Core Voice)

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

---

## From Inspiration Sources

{If inspiration_samples provided:}

### Techniques to Adopt

**From {author}**:
Pattern: "{pattern}"
Their example: "{example_from_inspiration}"
How to adapt: {how_to_adapt}
Reason: {reason}
**Adopt this technique?** [y/n]

### Vocabulary from Inspiration

**From {author}**:
- "{term_or_phrase}" - {usage_context}
**Adopt?** [y/n]

---

## Blend Summary

{blend_summary from calibration_blend}

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

If inspiration samples were used, add calibration blend section:
```yaml
calibration:
  core_voice_weight: 0.75
  inspiration_blend: 0.25
  inspiration_sources:
    - author: "{author name}"
      traits_adopted:
        - "{trait 1}"
        - "{trait 2}"
    - author: "{another author}"
      traits_adopted:
        - "{trait}"
  blend_summary: "{human-readable summary of the voice blend}"
```

### Step 9: Generate Calibration Report (Orchestrator)

Write to: `2-research/analysis/{YYYY-MM-DD}-voice-calibration.md`

```markdown
# Voice Calibration Report

**Generated**: {timestamp}
**Core Samples Analyzed**: {count} ({linkedin_count} LinkedIn, {newsletter_count} Newsletter)
**Inspiration Samples**: {count} from {unique_authors} authors
**Voice Blend**: {core_weight}% core + {inspiration_weight}% inspiration
**Confidence**: {level} ({score}/100)

## Sample Summary

### Your Writing (Core Voice)

| Platform | Count | Date Range |
|----------|-------|------------|
| LinkedIn | {n} | {earliest} - {latest} |
| Newsletter | {n} | {earliest} - {latest} |

### Inspiration Sources

{If inspiration samples:}
| Author | Platform | Samples | Traits | Weight |
|--------|----------|---------|--------|--------|
| {author} | {platform} | {n} | {traits joined} | {weight}% |

{If no inspiration samples:}
*No inspiration samples configured. Add samples to `1-capture/voice-samples/inspiration/` to blend techniques from admired writers.*

## Core Voice Analysis

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

## Inspiration Analysis

{If inspiration samples provided:}

### Traits Extracted from Inspiration

{For each author:}
#### {Author Name}
- **Trait**: {trait} - {description}
- **Examples**: "{quoted example from their content}"
- **Weight**: {influence_weight}%

### Complementary Traits (Adopted)

| Trait | From | Complements | Adoption |
|-------|------|-------------|----------|
| {trait} | {author} | {why it complements} | {full/partial} |

### Conflicting Traits (Skipped or Adapted)

| Trait | From | Conflicts With | Resolution |
|-------|------|----------------|------------|
| {trait} | {author} | {what it conflicts with} | {skip/adapt} |

{If no inspiration samples:}
*Inspiration analysis not performed. Core voice calibration only.*

## Changes Applied

### From Core Voice Analysis

#### Tone Updates
- Primary: {old} → {new}
- Added attributes: {list}
- Removed attributes: {list}

#### Vocabulary Updates
- Added to preferred: {list}
- Added to include_often: {list}
- Added to avoid: {list}

#### Pattern Updates
- Added openers: {list}
- Added closers: {list}

### From Inspiration Blending

{If inspiration samples:}
#### Techniques Adopted
{For each:}
- **{pattern}** (from {author}) - {how_to_adapt}

#### Vocabulary Adopted
{For each:}
- "{term}" (from {author}) - {usage_context}

{If no inspiration samples:}
*No inspiration techniques adopted.*

## Voice Blend Summary

{If inspiration samples:}
**Core Voice ({core_weight}%)**: {dominant_traits_from_core joined}

**Inspiration Blend ({inspiration_weight}%)**:
{For each source:}
- **{author}**: {traits_adopted joined}

**Blend Rationale**: {blend_rationale}

{If no inspiration samples:}
**Pure Core Voice**: 100% based on your own writing samples.

## Confidence Factors

- **Sample Size**: {assessment} - {recommendation}
- **Consistency**: {assessment} - {notes}
- **Platform Coverage**: {assessment} - {missing}

## Next Steps

{If confidence < high:}
1. Add more samples to improve calibration accuracy
2. Include samples from different time periods
3. Add samples from missing platforms: {list}

{If no inspiration samples:}
4. Consider adding inspiration samples to `1-capture/voice-samples/inspiration/` for richer calibration

{If confidence high:}
1. Voice profile is well-calibrated
2. Run `/generate-content` to test new settings
3. Re-calibrate quarterly or after voice evolution
```

### Step 10: Write Agent Log (Orchestrator)

Write to: `system/logs/{YYYY-MM-DD}-voice-calibration-agent.json`

Include: input summary, output, timestamp, changes applied

### Step 11: Update Metadata (Orchestrator)

Update `1-capture/voice-samples/.metadata.yaml`:

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
2-research/analysis/2026-01-08-voice-calibration.md
```

## Performance Target

- Analysis: < 2 minutes
- Full process with approval: < 5 minutes

## Handling Edge Cases

### No Samples Found

```markdown
## No Samples Found

The sample directories are empty:
- `1-capture/voice-samples/linkedin-posts/`
- `1-capture/voice-samples/newsletter-samples/`

**To add samples**:
1. Copy LinkedIn posts to `1-capture/voice-samples/linkedin-posts/`
2. Copy newsletter content to `1-capture/voice-samples/newsletter-samples/`
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

### No Inspiration Samples

If `1-capture/voice-samples/inspiration/` is empty or doesn't exist:
- Proceed with core-only calibration (no blending)
- Pass `"inspiration_samples": []` to agent
- Note in report: "Consider adding inspiration samples for richer calibration"
- This is a valid mode - not an error

### Invalid Inspiration Sample Frontmatter

If an inspiration sample is missing required frontmatter fields:
```markdown
⚠️ Skipping invalid inspiration sample: {filename}
   Missing required fields: {list of missing fields}
   Required: author, source_url, date, style_traits, why_admired
```
- Skip the invalid sample
- Continue processing other samples
- Include warning in report

### High Inspiration Weight Requested

If `--inspiration-weight` parameter exceeds 0.30:
```markdown
⚠️ Inspiration weight capped at 30%
   Requested: {requested}%
   Applied: 30%

   Core voice must remain dominant to preserve authenticity.
```

### Conflicting Traits Detected

If agent detects traits from inspiration that conflict with core voice:
- Present conflicts clearly in recommendations
- Default to skipping conflicting traits
- Allow user to override with explicit approval
- Document resolution in calibration report
