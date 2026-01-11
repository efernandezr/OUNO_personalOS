# PersonalOS

An AI-powered content operating system built on Claude Code. Transform research and ideas into authentic, voice-matched content with automated workflows, intelligent source monitoring, and seamless Notion integration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

PersonalOS is a collection of Claude Code slash commands and sub-agents designed to help content creators:

- **Monitor** trends and developments from curated sources in your field
- **Analyze** brain dumps and notes for content opportunities
- **Generate** platform-optimized content that matches your authentic voice
- **Track** industry movements and community developments
- **Automate** daily briefings and content workflows

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/code) installed
- Notion account with MCP integration configured
- Firecrawl API key (for web scraping)
- Perplexity API key (optional, for real-time intelligence) - [Get one here](https://www.perplexity.ai/settings/api)

### Installation

**Option A: Automated Setup (Recommended)**

```bash
# Clone the repository
git clone git@github.com:efernandezr/OUNO_personalOS.git
cd PersonalOS

# Run the setup script
./scripts/setup.sh
```

The setup script will:
- Copy template configs to `config/`
- Create necessary directories
- Guide you through next steps

**Option B: Manual Setup**

1. Clone or copy the PersonalOS directory
2. Copy template configs: `cp config/templates/*.template.yaml config/` (rename without `.template`)
3. Configure MCP servers in your Claude Code settings:

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp"
    },
    "firecrawl": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

3. Restart Claude Code to load the MCP servers
4. Run your first command: `/daily-brief`

### Enable Real-Time Intelligence (Optional)

PersonalOS can use Perplexity API to enhance intelligence gathering with:
- **Breaking news detection** (last 48 hours)
- **Trend discovery** beyond configured sources
- **Automatic source discovery**
- **Deep research** - Comprehensive topic analysis

To enable:

```bash
# Run the setup script
./scripts/enable-perplexity.sh
```

This will:
- Configure the Perplexity MCP server
- Create `config/research.yaml` with budget settings
- Set up caching to manage API costs

**Budget**: Two-tier system:
- Regular queries: $25/month (alert at 80%)
- Deep research: $20/month separate cap (confirmation required at 50%)

**Check usage**: Run `/perplexity-budget` to see current spending.

**Skip for now?** Commands work without Perplexity - you'll just miss real-time intelligence. Enable it anytime later.

## Commands

### `/market-intelligence`

Scan configured sources for insights, trends, and developments in your field. Includes real-time breaking news and trend discovery when Perplexity is enabled.

```bash
# Standard scan (last 24 hours, all high/medium priority sources)
/market-intelligence

# Quick scan (top 5 sources only)
/market-intelligence --depth quick

# Deep scan (all sources including low priority)
/market-intelligence --depth deep

# Extended timeframe
/market-intelligence --timeframe week

# Skip real-time intelligence (faster, no Perplexity budget)
/market-intelligence --no-real-time

# Force fresh Perplexity data (ignores cache)
/market-intelligence --force-fresh

# Add deep research (comprehensive topic analysis)
/market-intelligence --deep                    # Smart topic selection from scan
/market-intelligence --deep "AI Agents"        # Specific topic
```

**Output:** `2-research/market-briefs/{date}-market-brief.md`

**Notion Sync:** Creates entries in "POS: Market Intelligence" database

**Real-Time Features** (requires Perplexity):
- Breaking news from the last 48 hours
- Trend signals across your topics
- New sources discovered and auto-added

**Deep Research** (requires Perplexity, `--deep` flag):
- Comprehensive analysis of a specific topic
- Market landscape, key players, emerging patterns
- Strategic implications and recommended actions
- Uses separate budget pool (~$3-5 per report)

---

### `/daily-brief`

Generate a personalized morning briefing combining intelligence from your sources with priorities. Includes "What's Breaking" section when Perplexity is enabled.

```bash
# Standard brief (10 min read)
/daily-brief

# Quick brief (5 min read)
/daily-brief --length quick

# Include pending tasks from Notion
/daily-brief --include-todos

# Skip real-time intelligence (faster)
/daily-brief --no-real-time
```

**Output:** `2-research/daily-briefs/{date}-brief.md`

**Notion Sync:** Creates entry in "POS: Daily Briefs" database

**Real-Time Features** (requires Perplexity):
- "What's Breaking" section with latest news
- Max 2 Perplexity queries (lighter than /market-intelligence)

---

### `/brain-dump-analysis`

Analyze accumulated notes and ideas to identify patterns and content opportunities.

```bash
# Analyze last 30 days
/brain-dump-analysis

# Analyze last week
/brain-dump-analysis --timeframe week

# Focus on content pillar alignment
/brain-dump-analysis --focus pillars

# Analyze all available notes
/brain-dump-analysis --timeframe all
```

**Input:** Reads from **both** sources automatically:
- Local files: `1-capture/brain-dumps/` folder
- Notion: "POS: Brain Dumps" database

**Output:** `2-research/analysis/{date}-brain-analysis.md`

---

### `/sync-brain-dumps`

Pull brain dumps from Notion to local storage. Useful for backing up mobile captures.

```bash
# Sync unprocessed brain dumps only (default)
/sync-brain-dumps

# Sync all brain dumps
/sync-brain-dumps --all

# Sync from a specific date
/sync-brain-dumps --since 2026-01-01

# Preview without saving
/sync-brain-dumps --dry-run
```

**Input:** Notion "POS: Brain Dumps" database

**Output:** Files saved to `1-capture/brain-dumps/YYYY-MM/`

**Note:** This is optional - `/brain-dump-analysis` reads from Notion directly. Use this for local backup.

---

### `/content-repurpose`

Transform existing content into platform-optimized formats while preserving authentic voice.

```bash
# Repurpose from local file
/content-repurpose 2-research/market-briefs/2026-01-06-market-brief.md

# Repurpose from Notion page
/content-repurpose https://notion.so/your-page-url

# Target specific platforms
/content-repurpose source.md --platforms linkedin,twitter

# Generate more variations
/content-repurpose source.md --variations 3

# Set specific tone
/content-repurpose source.md --tone provocative
```

**Output:** Platform-specific folders in `3-content/`:
- `3-content/linkedin/{date}-{slug}/post-v1.md`, `post-v2.md`
- `3-content/twitter/{date}-{slug}/thread.md`
- `3-content/newsletter/{date}-{slug}/snippet.md`

**Notion Sync:** Creates draft entries in "POS: Content Calendar"

---

### `/add-source`

Add new sources to your monitoring configuration.

```bash
# Add a news source
/add-source

# Add a competitor
/add-source --type competitor
```

**Updates:** `config/sources.yaml` or `config/competitors.yaml`

---

### `/voice-calibrate`

Analyze your writing samples to calibrate the voice profile for authentic content generation.

```bash
# Run calibration with all available samples
/voice-calibrate

# Require minimum 10 samples for higher confidence
/voice-calibrate --min-samples 10

# Calibrate from LinkedIn posts only
/voice-calibrate --platform linkedin

# Auto-approve recommendations (skip review)
/voice-calibrate --auto-approve

# Focus on specific voice aspects
/voice-calibrate --focus hooks,vocabulary
```

**Input:** Samples from `1-capture/voice-samples/linkedin-posts/` and `1-capture/voice-samples/newsletter-samples/`

**Output:**
- Calibration report: `2-research/analysis/{date}-voice-calibration.md`
- Updated: `config/voice-profile.yaml` (with your approval)

**Confidence Levels:**
| Samples | Confidence | Analysis Depth |
|---------|------------|----------------|
| 1-4 | Low | Basic patterns only |
| 5-10 | Medium | Vocabulary + structure |
| 10+ | High | Full voice fingerprint |

---

### `/add-story`

Add personal stories and experiences to your context for authentic content generation.

```bash
# Interactive story capture
/add-story

# Add with description
/add-story I want to add a story about failing fast from my startup days

# Specify type directly
/add-story --type transformation

# Capture extended narrative
/add-story --full
```

**Story Templates:** The command offers structured templates for:
- **Transformation stories**: Career pivots, mindset shifts, skill development
- **Failure/Learning stories**: Mistakes, setbacks, hard lessons
- **Milestone stories**: Achievements, wins, proof points

**Updates:** `config/personal-context.yaml`

**Notion Sync:** Creates entry in "POS: Personal Context" database

---

### `/create-spec`

Create a feature specification from a planning conversation.

```bash
# After a planning conversation
/create-spec my-new-feature

# Creates system/specs/my-new-feature/ with:
# - requirements.md
# - implementation-plan.md
# - action-required.md
```

**Output:** `system/specs/{feature-name}/`

**Note:** Specs are gitignored (personal to each user's improvements).

---

### `/checkpoint`

Create a git checkpoint commit with all current framework changes.

```bash
# Create checkpoint with auto-generated commit message
/checkpoint

# Create checkpoint and push to remote
/checkpoint --push
```

**What it does:**
- Stages all framework changes (commands, agents, docs, scripts)
- Generates a descriptive commit message following conventions
- Creates the commit
- With `--push`: pushes to remote (auto-sets upstream if needed)

**Note:** Only framework files are committed. Personal configs and outputs are gitignored.

---

### `/deep-research`

On-demand comprehensive deep research on a specific topic using Perplexity's sonar-deep-research model.

```bash
# Interactive topic picker (shows topics from topics.yaml)
/deep-research

# Specific topic
/deep-research "AI Agents in Marketing"

# Filter topics shown in picker
/deep-research --topics primary     # Show only primary topics
/deep-research --topics secondary   # Show only secondary topics

# Control research depth vs cost
/deep-research --effort low         # Faster, lower cost (~$2-3)
/deep-research --effort medium      # Balanced (default, ~$3-5)
/deep-research --effort high        # Most thorough (~$5-8)
```

**Output:** `2-research/market-briefs/{date}-{time}-deep-research-{slug}.md`

**Notion Sync:** Creates entry in "POS: Market Intelligence" with "Deep Research" tag

**Report includes:**
- Executive summary
- Market landscape analysis
- Key players and recent developments
- Emerging patterns and signals
- Competitive dynamics
- Strategic implications and recommended actions
- All sources cited with URLs

**Budget:** Uses separate deep research budget ($20/month default). Confirmation required when above 50% usage.

---

### `/perplexity-budget`

View Perplexity API budget status and usage history.

```bash
/perplexity-budget
```

**Shows:**
- Current month spending vs limits
- Regular queries vs deep research breakdown
- Usage history with cost per report
- Budget projections and remaining capacity
- Quick reference for command costs

**Note:** This is a read-only diagnostic command - no files are created.

---

### `/sync-status`

Rebuild STATUS.md from project state. Use after `/clear` or if status seems stale.

```bash
/sync-status
```

**What it does:**
- Scans output directories for recent files
- Reads config file summaries
- Rebuilds STATUS.md with accurate state
- Generates suggested next actions

## Output Format

All PersonalOS reports follow a unified structure with consistent source citations.

### Report Structure

Every report includes:

1. **Report Metadata** - Generation date, type, status, source count
2. **Primary Content** - Varies by report type
3. **Sources** - All referenced URLs with clickable links

### Source Citations

Reports include inline source links and a consolidated Sources section:

```markdown
### Finding Title

Key insight from the source content.

**Source**: [Article Name](https://example.com/article)

---

## Sources

All sources referenced in this report:

| Source | URL | Type |
|--------|-----|------|
| Article Name | [link](https://example.com) | firecrawl |
```

This ensures all claims are traceable and verifiable. See `.claude/docs/report-template.md` for complete template documentation.

### Source Types

| Type | Description |
|------|-------------|
| `firecrawl` | Content extracted via Firecrawl MCP |
| `perplexity` | Real-time intelligence via Perplexity |
| `internal` | Internal notes (brain dumps) |

## Directory Structure

PersonalOS uses a **numbered pipeline structure** for clear content flow:

```
PersonalOS/
├── CLAUDE.md                    # Main context file for Claude
├── README.md                    # This file
│
├── 1-capture/                   # RAW INPUTS - where ideas enter
│   ├── brain-dumps/             # Notes synced from Notion
│   │   └── YYYY-MM/             # Organized by month
│   ├── voice-samples/           # Writing samples for calibration
│   │   ├── linkedin-posts/      # LinkedIn post samples (.md)
│   │   ├── newsletter-samples/  # Newsletter samples (.md)
│   │   └── .metadata.yaml       # Sample tracking metadata
│   └── documents/               # PDFs and reference materials
│
├── 2-research/                  # INTELLIGENCE - processed insights
│   ├── market-briefs/           # From /market-intelligence
│   ├── daily-briefs/            # From /daily-brief
│   ├── analysis/                # From /brain-dump-analysis
│   ├── competitive/             # Competitor tracking (future)
│   └── dashboards/              # Weekly dashboards (future)
│
├── 3-content/                   # GENERATED CONTENT - by platform
│   ├── linkedin/                # LinkedIn posts
│   │   └── {date}-{slug}/       # post-v1.md, post-v2.md, summary.md
│   ├── newsletter/              # Newsletter snippets
│   │   └── {date}-{slug}/       # snippet.md
│   └── twitter/                 # Twitter threads
│       └── {date}-{slug}/       # thread.md
│
├── 4-archive/                   # OLD CONTENT - rotated after 90 days
│   └── YYYY-MM/                 # Organized by month
│
├── config/                      # Configuration files
│   ├── topics.yaml              # Topics to monitor
│   ├── sources.yaml             # News sources and blogs
│   ├── competitors.yaml         # Competitor profiles
│   ├── voice-profile.yaml       # Your writing voice
│   ├── personal-context.yaml    # Personal stories & experiences
│   ├── goals.yaml               # Tracking goals
│   ├── notion-mapping.yaml      # Notion database IDs
│   └── research.yaml            # Perplexity settings (optional)
│
├── system/                      # INTERNAL - system files
│   ├── logs/                    # Agent execution logs
│   ├── cache/                   # Perplexity cache, query results
│   ├── specs/                   # Feature specifications
│   │   └── {feature-name}/      # requirements.md, implementation-plan.md
│   └── planning/                # Roadmap, planning docs
│
├── .claude/                     # Claude Code internals
│   ├── commands/                # Slash command definitions
│   ├── agents/                  # Operative agent definitions
│   ├── docs/                    # Framework documentation
│   └── utils/                   # Utility files (schemas.json)
│
└── scripts/                     # Automation scripts
```

## Configuration

### `config/topics.yaml`

Define what topics to monitor:

```yaml
primary_topics:
  - name: "Your Main Topic"
    keywords: ["keyword 1", "keyword 2"]

secondary_topics:
  - name: "Supporting Topic"
    keywords: ["related keyword"]

emerging_topics:
  - name: "Trend to Watch"
    keywords: ["emerging term", "new concept"]
```

### `config/sources.yaml`

Configure sources for intelligence gathering:

```yaml
sources:
  - name: "Industry Blog"
    url: "https://example.com/blog"
    type: "blog"
    priority: "high"

  - name: "Newsletter Source"
    url: "https://example.substack.com"
    type: "newsletter"
    priority: "high"
```

### `config/voice-profile.yaml`

Define your writing voice for content generation:

```yaml
tone:
  primary: "professional"
  secondary: "approachable"

vocabulary:
  preferred:
    - "transformation"
    - "practical"
  avoid:
    - "game-changer"
    - "synergy"

patterns:
  hooks: "Start with contrarian take or surprising data"
  closings: "End with forward-looking question"
```

## Notion Integration

PersonalOS syncs with 6 Notion databases:

| Database | Purpose |
|----------|---------|
| POS: Market Intelligence | Curated insights from source scanning |
| POS: Content Calendar | Draft content for publishing |
| POS: Brain Dumps | Idea capture and notes |
| POS: Competitive Analysis | Competitor tracking |
| POS: Weekly Reviews | Dashboard history |
| POS: Daily Briefs | Morning brief archive |

Database IDs are stored in `config/notion-mapping.yaml`.

## Operative Agents

PersonalOS uses **Task tool delegation** to specialized agents for complex tasks:

| Agent | Purpose | Model |
|-------|---------|-------|
| `intelligence-agent` | Web scraping, trend synthesis, source scanning | Sonnet |
| `pattern-agent` | Theme extraction, note analysis, content opportunities | Sonnet |
| `content-agent` | Voice-matched content generation for all platforms | Sonnet |
| `voice-calibration-agent` | Analyze samples, extract voice patterns | Sonnet |
| `sync-agent` | Notion read/write operations | Haiku |
| `sync-brain-dumps-agent` | Pull brain dumps from Notion | Haiku |

Agent definitions are in `.claude/agents/` and can be customized to improve output quality.

### JSON Schema Validation

Agent outputs are validated against schemas defined in `.claude/utils/schemas.json`. This ensures:
- Required source citations are always present
- Output structure is consistent across runs
- Invalid responses trigger automatic retries (max 2)

## Workflows

### Morning Routine

```bash
# 1. Get your daily briefing
/daily-brief

# 2. Review and mark insights worth exploring
# (In Notion, update status to "Flagged")
```

### Content Creation Flow

```bash
# 1. Capture ideas throughout the day
# (Add notes to Notion on mobile, or 1-capture/brain-dumps/ folder on desktop)

# 2. Optional: Sync Notion brain dumps to local storage
/sync-brain-dumps

# 3. Analyze for patterns weekly
/brain-dump-analysis --timeframe week

# 4. Pick a topic and generate content
/content-repurpose 2-research/analysis/2026-01-06-brain-analysis.md --platforms linkedin
```

### Weekly Intelligence Review

```bash
# Deep scan of all sources
/market-intelligence --depth deep --timeframe week
```

## Example: AI Marketing Use Case

Here's how one user configures PersonalOS for AI marketing thought leadership:

| Configuration | Example Values |
|---------------|----------------|
| **Topics** | AI for Marketing, Marketing Automation, AI Agents |
| **Sources** | Anthropic Blog, Marketing AI Institute, industry newsletters |
| **Voice** | Professional but approachable, data-informed, global enterprise context |
| **Platforms** | LinkedIn (primary), Newsletter (secondary) |
| **Content Pillars** | Enterprise transformation, practical applications, technical tutorials |

This demonstrates how to adapt the framework for any domain - writers, consultants, educators, coaches, or any content creator can follow the same pattern with their own topics and sources.

## Brain Dump Format

For best results, structure your brain dumps like this:

```markdown
# Brain Dump - 2026-01-06

## Ideas
- New angle on [your topic]
- Thought on [related concept]

## Questions
- What if we could automate X?
- How can [your audience] leverage Y?

## Observations
- Noticed trend in [your industry]
- Interesting pattern in [area of interest]

## Tags
#topic1 #topic2 #content-idea
```

## Performance Targets

| Command | Target Time |
|---------|-------------|
| `/market-intelligence --depth quick` | < 1 minute |
| `/market-intelligence` (standard) | < 3 minutes |
| `/market-intelligence --depth deep` | < 5 minutes |
| `/market-intelligence --deep` | < 5 minutes (incl. deep research) |
| `/daily-brief` | < 2 minutes |
| `/brain-dump-analysis` | < 3 minutes |
| `/content-repurpose` | < 2 minutes |
| `/sync-brain-dumps` | < 1 minute |
| `/deep-research` | < 3 minutes |
| `/perplexity-budget` | < 5 seconds |

## Troubleshooting

### Firecrawl not working

1. Verify API key in Claude Code settings
2. Restart Claude Code to reload MCP servers
3. Test with: `/market-intelligence --depth quick`

### Notion sync failing

1. Verify Notion MCP is connected
2. Check database IDs in `config/notion-mapping.yaml`
3. Ensure databases have correct properties

### Content not matching voice

1. Add more samples to `1-capture/voice-samples/linkedin-posts/` and `1-capture/voice-samples/newsletter-samples/`
2. Run `/voice-calibrate` to analyze and calibrate
3. Review the calibration report in `2-research/analysis/`
4. If needed, manually adjust `config/voice-profile.yaml`

## Voice Calibration Setup

Voice calibration ensures generated content matches your authentic writing style. Here's how to set it up:

### Step 1: Add Writing Samples

Add your best-performing content to the samples folders:

**LinkedIn Posts:**
```bash
# Create sample files in 1-capture/voice-samples/linkedin-posts/
# Use this format:

1-capture/voice-samples/linkedin-posts/post-001.md
```

```markdown
---
date: 2025-12-15
engagement: high
topics: [AI, marketing, transformation]
---

Your LinkedIn post content here...
```

**Newsletter Samples:**
```bash
1-capture/voice-samples/newsletter-samples/issue-001.md
```

```markdown
---
date: 2025-12-01
type: newsletter
topics: [AI agents, enterprise]
---

Your newsletter content here...
```

### Step 2: Run Calibration

```bash
# Once you have 5+ samples
/voice-calibrate
```

### Step 3: Review and Approve

The calibration will:
1. Analyze sentence patterns, vocabulary, and structure
2. Show you recommended updates to `voice-profile.yaml`
3. Ask for approval before making changes

### Tips for Better Calibration

- **More samples = better results**: 10+ samples recommended
- **Include variety**: Different tones, topics, lengths
- **Use high-performers**: Posts with good engagement are best
- **Update regularly**: Re-run after major content pivots

## Roadmap

### Coming Soon
- `/competitive-analysis` - Deep competitor monitoring
- `/weekly-dashboard` - Automated weekly metrics review
- `/meeting-prep` - Prepare for meetings with context

> **Detailed tracking**: See `system/planning/ROADMAP.md` for full feature roadmap, ideas backlog, and progress tracking (gitignored, local only).

## Project Structure

PersonalOS separates **framework** (tracked in git) from **personal data** (stays local):

```
PersonalOS/
├── Framework (tracked)
│   ├── CLAUDE.template.md, README.md  # Documentation templates
│   ├── .claude/commands/              # Slash commands
│   ├── .claude/agents/                # Agent definitions
│   ├── scripts/                       # Automation scripts
│   └── config/templates/              # Config templates
│
└── Personal Data (gitignored)
    ├── CLAUDE.md                  # Your personal context (copy from template)
    ├── config/*.yaml              # Your actual configs
    ├── 1-capture/                 # Your inputs (brain-dumps, samples)
    ├── 2-research/                # Generated research
    ├── 3-content/                 # Generated content
    ├── 4-archive/                 # Old content
    └── system/                    # Logs, cache, specs
```

When you clone, run `./scripts/setup.sh` to create your personal config files from templates. Then copy `CLAUDE.template.md` to `CLAUDE.md` and customize it with your information.

## Improving PersonalOS

Want to add features or improvements to PersonalOS? Use the spec workflow:

### 1. Plan the Feature

Enter planning mode and design your approach with Claude.

### 2. Create a Spec

```bash
/create-spec my-feature-name
```

This generates three files in `system/specs/my-feature-name/`:
- **requirements.md** - What and why, acceptance criteria
- **implementation-plan.md** - Phased tasks with checkboxes
- **action-required.md** - Manual steps (API keys, accounts, etc.)

### 3. Implement

Follow the task checklist in `system/specs/{feature}/implementation-plan.md`. Each task is designed to be implementable in a single session.

### 4. Share (Optional)

If your improvement is framework-level (commands, agents, docs), submit a PR!

## Contributing

Contributions are welcome! Here's how to help:

### Reporting Issues
- Use GitHub Issues for bugs and feature requests
- Include steps to reproduce for bugs
- Describe your use case for features

### Pull Requests
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test with your local configs
5. Submit a PR with clear description

### Development Guidelines
- Keep commands focused and single-purpose
- Document new commands in README
- Add templates for any new config files
- Test with both fresh setup and existing configs

### Areas for Contribution
- New slash commands
- Sub-agent improvements
- Documentation improvements
- Bug fixes
- Performance optimizations

## License

MIT License - See [LICENSE](LICENSE) for details.

This means you can:
- Use PersonalOS commercially or personally
- Modify and distribute
- Use privately

Just include the license notice in copies.
