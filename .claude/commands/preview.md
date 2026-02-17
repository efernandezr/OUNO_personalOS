---
description: Preview today's outputs as a styled HTML page in the browser
---

# /preview

Generate a styled HTML preview of PersonalOS outputs and open it in Chrome.

## Usage

```
/preview
/preview --date 2026-01-15
/preview --section brief
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--date YYYY-MM-DD` | today | Which day's outputs to show |
| `--section` | `all` | Filter: `brief`, `content`, `analysis`, `all` |
| `--open` | `true` | Auto-open in browser (`false` to skip) |

## Execution Steps

### 1. Parse Parameters

Extract `--date`, `--section`, and `--open` from `$ARGUMENTS`. Default date to today (`YYYY-MM-DD`).

### 2. Scan for Matching Files

Search for files matching the target date. Use Glob to find:

**Research files** (when section is `all`, `brief`, or `analysis`):
- `2-research/daily-briefs/{date}*.md`
- `2-research/market-briefs/{date}*.md`
- `2-research/analysis/{date}*.md`

**Content files** (when section is `all` or `content`):
- `3-content/linkedin/{date}*/**/*.md`
- `3-content/twitter/{date}*/**/*.md`
- `3-content/newsletter/{date}*/**/*.md`

### 3. Handle Empty Results

If no files found, write a minimal HTML page to `system/preview/index.html`:

```html
<html><body style="font-family:system-ui;padding:4rem;text-align:center;color:#666">
<h1>No outputs found</h1>
<p>No PersonalOS outputs for {date}.</p>
<p style="font-size:0.9em">Try a different date with <code>/preview --date YYYY-MM-DD</code></p>
</body></html>
```

Then open it (if `--open` is true) and stop.

### 4. Read All Matched Files

Read each matched file with the Read tool. Organize them into sections:

```json
[
  {
    "type": "daily-brief",
    "label": "Daily Brief",
    "category": "research",
    "path": "2-research/daily-briefs/2026-02-18-0800-brief.md",
    "content": "...file contents..."
  },
  {
    "type": "linkedin",
    "label": "LinkedIn Post",
    "category": "content",
    "path": "3-content/linkedin/2026-02-18-ai-agents/post.md",
    "content": "...file contents..."
  }
]
```

**Type mapping**:
| Glob source | type | label | category |
|-------------|------|-------|----------|
| daily-briefs | `daily-brief` | Daily Brief | research |
| market-briefs | `market-brief` | Market Brief | research |
| analysis | `analysis` | Analysis | research |
| linkedin | `linkedin` | LinkedIn Post | content |
| twitter | `twitter` | Twitter Thread | content |
| newsletter | `newsletter` | Newsletter | content |

### 5. Read the HTML Template

```
Read system/preview/template.html
```

### 6. Build the Final HTML

In the template, replace the placeholder:
- Replace `{{PREVIEW_DATE}}` with the formatted date (e.g., `Feb 18, 2026`)
- Replace `{{SECTIONS_DATA}}` with the JSON array of sections (properly escaped for embedding in a `<script>` tag)

### 7. Write Output

```
Write to system/preview/index.html
```

### 8. Open in Browser

If `--open` is not `false`:

```bash
open system/preview/index.html
```

## Output

Tell the user:
- How many files were found and rendered
- The file path: `system/preview/index.html`
- That the preview opened in their browser (if --open)

## Notes

- The template is self-contained (inline CSS/JS, only external dep is marked.js CDN)
- Previous previews are overwritten each time (single `index.html`)
- No Notion sync needed — this is a local-only viewing tool
- Works with any historical date that has outputs
