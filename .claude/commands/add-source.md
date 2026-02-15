---
description: Add a new blog, newsletter, or news source to monitor
---

# /add-source

Add a new source to the PersonalOS monitoring configuration.

## Usage

```
/add-source
```

The command will prompt you interactively for source details.

## Parameters (Interactive)

1. **Type**: `blog`, `newsletter`, `news`, `competitor`
2. **URL**: Full URL of the source
3. **Name**: Display name
4. **Priority**: `high` (always scan), `medium` (regular), `low` (occasional)
5. **Topics** (optional): Associated topics from config/topics.yaml

## Execution Steps

1. Ask for type, URL, name, priority, topics
2. Read the appropriate config file:
   - `blog`/`newsletter`/`news`: `config/sources.yaml`
   - `competitor`: `config/competitors.yaml`
3. Check for duplicate URLs
4. Append new source entry
5. Write updated config file
6. Confirm addition

## Config Formats

**sources.yaml**:
```yaml
- name: "Source Name"
  url: "https://..."
  type: newsletter
  priority: high
  topics: ["AI Agents", "Claude/Anthropic"]
```

**competitors.yaml**:
```yaml
competitors:
  tier_2:
    - name: "Competitor"
      description: "Description"
      platforms:
        linkedin: { url: "https://..." }
      focus_areas: ["Topic 1"]
```

## Notes

- Validate URL format before adding
- Check for duplicates
- Update `last_updated` field
- For competitors, default to tier_2
- Source will be included in next `/market-intelligence` scan
