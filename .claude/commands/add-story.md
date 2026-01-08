---
description: Add personal stories and experiences to your context (project)
---

# /add-story

Add a personal story, experience, or influence to your context for authentic content generation.

## Usage

```
/add-story [description]
```

## Parameters (Optional)

- `description`: Brief description of what you want to add (will prompt for details if not provided)

## Execution Steps

### 1. Determine Type

Ask user or infer from description:

| Type | Description |
|------|-------------|
| `story` | A reusable anecdote or personal experience |
| `book` | A formative book or influence |
| `experience` | A career experience or lesson learned |
| `career` | A career milestone or phase |

### 2. Collect Details

**For Stories:**
- `id`: Short identifier (auto-generated from title)
- `short`: One-liner version for quick use
- `full`: (Optional) Extended narrative
- `themes`: Tags for matching to content topics
- `use_when`: When to reference this story

**For Books/Influences:**
- `title`: Book or resource title
- `author`: Author name
- `discovered`: When/how you discovered it
- `insight`: Key insight or lesson
- `current_application`: How you apply it now

**For Career:**
- `period`: Time period (e.g., "2015-2020", "Present")
- `phase`: Phase name
- `note`: Brief description

### 3. Save to Local Config

Append to appropriate section in `config/personal-context.yaml`:
- Stories → `stories` array
- Books → `influences` array
- Career/Experience → `career` array

Update `last_updated` timestamp.

### 4. Sync to Notion

If personal_context database exists:
1. Create new entry in "POS: Personal Context" database
2. Set `Synced` = true (already in local)
3. Map fields to Notion properties

### 5. Confirm

Display summary:

```
## Story Added

**Type**: story
**ID**: crossing-the-chasm
**Short**: "15 years ago I read Crossing the Chasm as a young entrepreneur"
**Themes**: adoption, transformation, change-management

Saved to: config/personal-context.yaml
Synced to: Notion (POS: Personal Context)
```

## Example

```
> /add-story I want to add a story about learning to fail fast from my startup days

What type of content is this?
> story

Give me the one-liner version:
> "My first startup taught me that failing fast isn't about giving up—it's about learning faster than your competitors"

What themes does this relate to? (comma-separated)
> startup, failure, learning, entrepreneurship

When should I use this story?
> When discussing iteration, experimentation, or startup mindset in enterprise contexts

## Story Added

**Type**: story
**ID**: fail-fast-startup
**Short**: "My first startup taught me that failing fast isn't about giving up—it's about learning faster than your competitors"
**Themes**: startup, failure, learning, entrepreneurship

Saved to: config/personal-context.yaml
Synced to: Notion (POS: Personal Context)
```

## Interactive Flow

The command is interactive by default:

1. Ask for type (if not clear from input)
2. Ask for short version
3. Ask for themes
4. Ask for use_when
5. Optionally ask for full version
6. Save and confirm

## Notes

- Stories are automatically available to `/content-repurpose`
- Use `/sync-brain-dumps` to pull stories added via Notion mobile
- Review `config/personal-context.yaml` to see all stored context
