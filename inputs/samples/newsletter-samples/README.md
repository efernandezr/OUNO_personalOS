# Newsletter Samples

This directory contains newsletter issues for voice calibration. Newsletters provide deeper voice patterns than social posts.

## How to Add Samples

1. Copy your newsletter content into a markdown file
2. Name the file descriptively: `YYYY-MM-DD-newsletter-title.md`
3. Add frontmatter with metadata (optional but helpful)
4. Update `../.metadata.yaml` with engagement data (optional)

## File Format

```markdown
---
date: 2024-12-20
subject: "Your Newsletter Subject Line"
engagement:
  opens: 450
  clicks: 89
  unsubscribes: 2
topics:
  - AI transformation
  - year in review
---

Your full newsletter content goes here.

Include:
- Introduction
- Main content
- Takeaways/conclusion
- Any recurring sections you have
```

## What to Include

**Best samples for calibration**:
- Newsletters that got high open rates
- Issues you're particularly proud of
- A mix of different topics
- Both shorter and longer issues

**Newsletter-specific patterns detected**:
- Introduction style (how you open)
- Section structure
- Personal anecdote usage
- Takeaway formatting
- Word count preferences
- Conversational tone markers

## Why Newsletters Matter

Newsletters show voice patterns that don't appear in social:
- Longer-form writing style
- How you transition between topics
- Personal openings and closings
- Deeper thought development
- Typical section structure

## Minimum Recommendations

| Samples | What's Detected |
|---------|-----------------|
| 1-2 | Basic structure |
| 3-5 | Section patterns + tone |
| 5+ | Full newsletter voice |

## Export Methods

**From Substack**:
1. Go to Dashboard > Posts
2. Click on a published post
3. Copy the content

**From Beehiiv**:
1. Go to your newsletter
2. Open a sent issue
3. Copy the content

**From email client**:
1. Find the sent newsletter
2. Copy the body content

The calibration command will automatically scan this directory.
