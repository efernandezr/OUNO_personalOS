# LinkedIn Post Samples

This directory contains LinkedIn posts for voice calibration. The more samples you add, the better the voice analysis.

## How to Add Samples

1. Copy your LinkedIn post text into a markdown file
2. Name the file descriptively: `YYYY-MM-DD-topic-slug.md`
3. Add frontmatter with metadata (optional but helpful)
4. Update `../.metadata.yaml` with engagement data (optional)

## File Format

```markdown
---
date: 2024-10-15
engagement:
  likes: 120
  comments: 15
  shares: 8
topics:
  - AI agents
  - marketing automation
---

Your LinkedIn post content goes here.

Include all text exactly as it appeared on LinkedIn.

#hashtags #included
```

## What to Include

**Best samples for calibration**:
- Posts with high engagement (lots of likes/comments)
- Posts that feel "authentically you"
- A mix of different topics you write about
- Posts from different time periods (shows voice consistency)

**Sample diversity helps**:
- Educational posts
- Storytelling posts
- Opinion/contrarian posts
- Data-driven posts

## Minimum Recommendations

| Samples | Confidence Level | What's Detected |
|---------|-----------------|-----------------|
| 1-4 | Low | Basic vocabulary only |
| 5-10 | Medium | Vocabulary + structure patterns |
| 10+ | High | Full voice fingerprint |

## Quick Copy Method

1. Go to your LinkedIn profile
2. Click on a post to open it
3. Select all text and copy
4. Paste into a new file here
5. Add frontmatter with date

The calibration command will automatically scan this directory.
