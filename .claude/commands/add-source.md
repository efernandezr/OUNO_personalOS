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

You will be asked to provide:

1. **Type**: What kind of source?
   - `blog` - Company or personal blog
   - `newsletter` - Email newsletter/Substack
   - `news` - News publication
   - `competitor` - Competitor profile for tracking

2. **URL**: Full URL of the source

3. **Name**: Display name for the source

4. **Priority**: Monitoring priority
   - `high` - Always scan
   - `medium` - Scan regularly
   - `low` - Occasional scans

5. **Topics** (optional): Associated topics from config/topics.yaml

## Execution Steps

1. Ask user for source type
2. Ask user for URL
3. Ask user for display name
4. Ask user for priority level
5. Ask user for associated topics
6. Read the appropriate config file:
   - For `blog`, `newsletter`, `news`: Read `config/sources.yaml`
   - For `competitor`: Read `config/competitors.yaml`
7. Append the new source to the appropriate section
8. Write the updated config file
9. Confirm the addition to user

## Example Interaction

```
User: /add-source

Claude: I'll help you add a new source. What type of source is this?
- blog
- newsletter
- news
- competitor

User: newsletter

Claude: What's the URL?

User: https://aimaker.substack.com

Claude: What name should I use for this source?

User: AI Maker Newsletter

Claude: What priority level? (high/medium/low)

User: high

Claude: Which topics does this source cover? (comma-separated, or "skip")
Available: AI for Marketing, AI Agents, Claude/Anthropic, Marketing Automation, Enterprise AI

User: AI Agents, Claude/Anthropic

Claude: Added "AI Maker Newsletter" to sources.yaml:
- Type: newsletter
- URL: https://aimaker.substack.com
- Priority: high
- Topics: AI Agents, Claude/Anthropic

The source will be included in your next /market-intelligence scan.
```

## Config File Formats

### sources.yaml format
```yaml
newsletters:
  - name: "AI Maker Newsletter"
    url: "https://aimaker.substack.com"
    type: newsletter
    priority: high
    topics:
      - "AI Agents"
      - "Claude/Anthropic"
```

### competitors.yaml format
```yaml
competitors:
  tier_2:
    - name: "New Competitor"
      description: "Description here"
      platforms:
        linkedin:
          url: "https://linkedin.com/in/..."
      focus_areas:
        - "Topic 1"
```

## Notes

- Always validate the URL format before adding
- Check for duplicates before adding
- Update the `last_updated` field in the config file
- For competitors, default to tier_2 unless specified

