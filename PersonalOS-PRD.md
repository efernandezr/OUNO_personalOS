# Product Requirements Document (PRD)
# PersonalOS: AI-Powered Personal Branding Operating System

---

## Document Information

| Field | Value |
|-------|-------|
| **Project Name** | PersonalOS |
| **Version** | 1.0 |
| **Author** | Enrique (AI Marketing Transformation Manager) |
| **Created** | January 6, 2026 |
| **Status** | Draft |
| **Target Completion** | MVP in 4 weeks |

---

## Quick Setup Checklist

Before diving into the details, here's what you'll need to do:

### Prerequisites
- [ ] Claude Code installed and working in Cursor
- [ ] Notion MCP connected to Claude Code
- [ ] Firecrawl API key (free tier: 500 pages/month) - [Get here](https://firecrawl.dev)

### Notion Setup (Do First)
- [ ] Create parent page "🤖 PersonalOS" in Notion
- [ ] Create database: **POS: Market Intelligence**
- [ ] Create database: **POS: Content Calendar**
- [ ] Create database: **POS: Brain Dumps**
- [ ] Create database: **POS: Competitive Analysis**
- [ ] Create database: **POS: Weekly Reviews**
- [ ] Create database: **POS: Daily Briefs**
- [ ] Copy all database IDs to `config/notion-mapping.yaml`

### Local Setup
- [ ] Create PersonalOS folder (anywhere you want)
- [ ] Initialize with file structure (see Section 9)
- [ ] Configure `config/topics.yaml` with your topics
- [ ] Configure `config/sources.yaml` with your sources
- [ ] Add 10+ content samples to `1-capture/voice-samples/` for voice calibration
- [ ] Run `/voice-calibrate` to build your voice profile

### Test
- [ ] Run `claude` in the PersonalOS folder
- [ ] Test: `/add-source` to verify config writing works
- [ ] Test: `/market-intelligence` to verify web scraping works
- [ ] Test: Notion sync by checking if entries appear

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Vision & Objectives](#2-vision--objectives)
3. [User Context & Personas](#3-user-context--personas)
4. [System Architecture](#4-system-architecture)
5. [Core Features & Slash Commands](#5-core-features--slash-commands)
6. [Sub-Agent Specifications](#6-sub-agent-specifications)
7. [Data Architecture](#7-data-architecture)
8. [Integration Requirements](#8-integration-requirements)
9. [File Structure](#9-file-structure)
10. [CLAUDE.md Configuration](#10-claudemd-configuration)
11. [Implementation Phases](#11-implementation-phases)
12. [Technical Specifications](#12-technical-specifications)
13. [Success Metrics](#13-success-metrics)
14. [Risk Assessment](#14-risk-assessment)
15. [Appendices](#15-appendices)

---

## 1. Executive Summary

### 1.1 What is PersonalOS?

PersonalOS is a local, markdown-based AI operating system powered by Claude Code that automates and enhances personal branding, thought leadership content creation, and market intelligence gathering. It transforms Claude Code from a coding assistant into a full-fledged "AI employee" that handles research, content drafting, competitive analysis, and workflow automation.

### 1.2 Core Philosophy

> **"The AI Employee"** - PersonalOS should not just answer questions but perform end-to-end workflows: researching, analyzing, drafting, and organizing—all while preserving your authentic voice and thought leadership positioning.

### 1.3 Key Differentiators

- **Hybrid System**: Serves both professional thought leadership and personal productivity
- **Voice Preservation**: Learns and maintains your unique writing style across all outputs
- **Scalable Intelligence**: Configurable topic monitoring and source management
- **Dual Output**: Syncs between local markdown files and Notion databases
- **Event-Driven + Scheduled**: Supports manual triggers, cron automation, and Notion-triggered workflows

### 1.4 Target Domains

1. **AI for Marketing** - Transformation strategies, use cases, ROI frameworks
2. **Claude Code for Marketing** - Practical applications, workflows, tutorials
3. **AI Agents for Marketing** - Agent architectures, automation patterns, implementation guides
4. **Building Agents** - Technical tutorials, best practices, tool reviews
5. **Digital Marketing Maturity** - Frameworks, assessments, evolution paths

---

## 2. Vision & Objectives

### 2.1 Vision Statement

*To create an AI-powered personal operating system that amplifies thought leadership output by 10x while maintaining authentic voice, enabling consistent high-quality content creation across multiple platforms without sacrificing depth or originality.*

### 2.2 Primary Objectives

| Objective | Description | Success Metric |
|-----------|-------------|----------------|
| **Automate Research** | Eliminate manual scanning of 20+ sources daily | <15 min/day on research |
| **Accelerate Content** | Reduce draft creation time by 70% | 2 LinkedIn posts/day capacity |
| **Maintain Voice** | All outputs indistinguishable from manual writing | 90% first-draft usability |
| **Track Landscape** | Real-time awareness of AI marketing developments | Zero missed major announcements |
| **Build Knowledge Base** | Accumulate structured insights over time | 500+ indexed insights in 6 months |

### 2.3 Non-Objectives (Out of Scope)

- Full social media automation (posting, scheduling)
- Email marketing integration
- CRM or sales pipeline management
- Video content creation
- dMAX or Syngenta work-related automation

---

## 3. User Context & Personas

### 3.1 Primary User Profile

```yaml
Name: Enrique
Role: AI Marketing Transformation Manager (Syngenta) + Thought Leader
Experience: 
  - Leading AI transformation across 90+ countries
  - Building dMAX platform with 5 AI agents
  - Managing 50-person digital marketing team
  
Content Focus:
  - AI for Marketing transformation
  - Claude Code practical applications
  - AI Agents architecture and implementation
  - Digital Marketing maturity frameworks
  
Platforms:
  - LinkedIn (primary)
  - Personal blog/newsletter (secondary)
  
Current Pain Points:
  - Time-constrained due to dMAX launch responsibilities
  - Information overload from AI news sources
  - Inconsistent content publishing cadence
  - Manual research consuming 2+ hours daily
  - Ideas scattered across multiple systems
```

### 3.2 User Workflows (Current State)

```
Morning Routine (Current):
├── Manual scan of 10+ AI news sites (45 min)
├── Check competitor LinkedIn posts (20 min)
├── Browse Twitter/X for trends (30 min)
├── Capture ideas in scattered notes (ongoing)
└── Write content when time permits (inconsistent)

Content Creation (Current):
├── Research topic manually (60-90 min)
├── Draft in Google Docs or Notion (45-60 min)
├── Edit and refine (30 min)
├── Adapt for different platforms (20 min)
└── Total: 2.5-4 hours per piece
```

### 3.3 User Workflows (Target State with PersonalOS)

```
Morning Routine (Target):
├── Run `/daily-brief` (auto-generated overnight)
├── Review AI-curated insights (10 min)
├── Flag items for deep-dive (2 min)
└── Total: 15 minutes

Content Creation (Target):
├── Run `/content-repurpose` or `/brain-dump-analysis`
├── Review AI draft with voice-matched content (10 min)
├── Light editing and personal touches (15 min)
├── Run `/adapt-platform` for variations (5 min)
└── Total: 30-45 minutes per piece
```

---

## 4. System Architecture

### 4.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PersonalOS                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │   INPUTS     │    │  PROCESSING  │    │   OUTPUTS    │          │
│  ├──────────────┤    ├──────────────┤    ├──────────────┤          │
│  │ • Web Sources│───▶│ Claude Code  │───▶│ • Local MD   │          │
│  │ • Brain Dumps│    │ (Main Agent) │    │ • Notion DB  │          │
│  │ • PDFs       │    │      │       │    │ • Dashboards │          │
│  │ • Notion     │    │      ▼       │    │ • Drafts     │          │
│  │ • Voice Notes│    │ Sub-Agents   │    │ • Reports    │          │
│  └──────────────┘    └──────────────┘    └──────────────┘          │
│                             │                                        │
│                             ▼                                        │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    SLASH COMMANDS                              │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │ /market-intelligence  │ /competitive-analysis │ /daily-brief │  │
│  │ /brain-dump-analysis  │ /content-repurpose    │ /weekly-dash │  │
│  │ /meeting-prep         │ /voice-calibrate      │ /add-source  │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      EXTERNAL INTEGRATIONS                           │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │
│  │  Notion MCP │  │ Web Scraper │  │  Firecrawl  │  │   Cron     │ │
│  │  (Database) │  │   (News)    │  │  (Content)  │  │ (Schedule) │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Component Overview

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Claude Code** | Main orchestration agent | Anthropic CLI in Cursor |
| **Sub-Agents** | Specialized task execution | Claude Code spawned agents |
| **Notion MCP** | Database sync & triggers | Model Context Protocol |
| **Firecrawl MCP** | Web content extraction | Firecrawl API |
| **Local Storage** | Markdown knowledge base | File system |
| **Cron Scheduler** | Automated daily runs | System cron or launchd |

### 4.3 Data Flow Diagram

```
                    ┌─────────────────┐
                    │  Trigger Event  │
                    │  (Manual/Cron/  │
                    │   Notion)       │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   CLAUDE.md     │
                    │   (Context)     │
                    └────────┬────────┘
                             │
                             ▼
              ┌──────────────────────────┐
              │    Slash Command Router   │
              └──────────────┬───────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
           ▼                 ▼                 ▼
    ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
    │ Research    │   │ Analysis    │   │ Content     │
    │ Sub-Agent   │   │ Sub-Agent   │   │ Sub-Agent   │
    └──────┬──────┘   └──────┬──────┘   └──────┬──────┘
           │                 │                 │
           └─────────────────┼─────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  Output Router  │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
       ┌─────────────┐              ┌─────────────┐
       │  Local MD   │              │   Notion    │
       │   Files     │              │  Databases  │
       └─────────────┘              └─────────────┘
```

---

## 5. Core Features & Slash Commands

### 5.1 Command Priority Matrix

| Command | Priority | Complexity | Dependencies | Est. Dev Time |
|---------|----------|------------|--------------|---------------|
| `/market-intelligence` | 🔴 HIGH | High | Web scraping, Firecrawl | 8 hours |
| `/competitive-analysis` | 🔴 HIGH | High | Web scraping, Notion | 6 hours |
| `/content-repurpose` | 🔴 HIGH | Medium | Voice model, Notion | 6 hours |
| `/brain-dump-analysis` | 🔴 HIGH | Medium | Local files, Notion | 4 hours |
| `/daily-brief` | 🔴 HIGH | Medium | Market-intel sub-agent | 4 hours |
| `/weekly-dashboard` | 🟡 MEDIUM | Medium | Notion, metrics | 4 hours |
| `/meeting-prep` | 🟢 LOW | Low | Notion, templates | 2 hours |
| `/add-source` | 🔴 HIGH | Low | Config files | 1 hour |
| `/voice-calibrate` | 🔴 HIGH | Medium | Content samples | 3 hours |

### 5.2 Command Specifications

---

#### 5.2.1 `/market-intelligence`

**Purpose**: Scan configurable sources for AI marketing insights, trends, and developments.

**Trigger**: Manual or scheduled (daily at 6:00 AM)

**Input Parameters**:
```yaml
topics: [list]           # Optional: Override default topics
sources: [list]          # Optional: Override default sources  
timeframe: string        # "24h" | "48h" | "week" (default: "24h")
depth: string            # "quick" | "standard" | "deep" (default: "standard")
output_format: string    # "brief" | "detailed" | "actionable" (default: "actionable")
```

**Default Topics** (configurable in `config/topics.yaml`):
```yaml
topics:
  primary:
    - AI for Marketing
    - Marketing Automation
    - AI Agents
    - Claude/Anthropic
    - LLM Applications
  secondary:
    - Martech Stack
    - Digital Transformation
    - Marketing Analytics
    - Customer Data Platforms
  emerging:
    - Agentic Workflows
    - MCP Protocol
    - AI Copilots
```

**Default Sources** (configurable in `config/sources.yaml`):
```yaml
sources:
  blogs:
    - url: "https://www.anthropic.com/news"
      name: "Anthropic Blog"
      priority: high
    - url: "https://openai.com/blog"
      name: "OpenAI Blog"
      priority: high
    - url: "https://ai.google/discover/latest-news"
      name: "Google AI"
      priority: high
    - url: "https://marketingaiinstitute.com/blog"
      name: "Marketing AI Institute"
      priority: high
      
  newsletters:
    - url: "https://www.aimaker.substack.com"
      name: "AI Maker"
      priority: medium
    - url: "https://bensbites.beehiiv.com"
      name: "Ben's Bites"
      priority: medium
      
  news:
    - url: "https://techcrunch.com/category/artificial-intelligence/"
      name: "TechCrunch AI"
      priority: medium
    - url: "https://venturebeat.com/category/ai/"
      name: "VentureBeat AI"
      priority: medium
```

**Output Structure**:
```markdown
# Market Intelligence Brief
**Generated**: {timestamp}
**Timeframe**: {timeframe}
**Sources Scanned**: {count}

## 🔥 Priority Updates
{High-impact news requiring immediate attention}

## 📊 Trend Analysis
{Emerging patterns across sources}

## 💡 Content Opportunities
{Topics with high engagement potential for your audience}

## 🎯 Actionable Insights
{Specific recommendations for content or positioning}

## 📚 Source Log
{Links to all referenced materials}
```

**Output Destinations**:
- Local: `2-research/market-briefs/{date}-market-brief.md`
- Notion: "Market Intelligence" database

**Sub-Agent Used**: `intelligence-researcher`

---

#### 5.2.2 `/competitive-analysis`

**Purpose**: Track and analyze competitor content creators in the AI marketing space.

**Trigger**: Manual or scheduled (weekly on Mondays)

**Input Parameters**:
```yaml
competitors: [list]      # Optional: Override default list
platform: string         # "linkedin" | "twitter" | "blog" | "all" (default: "all")
timeframe: string        # "week" | "month" (default: "week")
focus: string            # "content" | "engagement" | "positioning" | "all"
```

**Default Competitors** (configurable in `config/competitors.yaml`):
```yaml
competitors:
  tier_1:  # Direct competitors in AI + Marketing space
    - name: "Paul Roetzer"
      linkedin: "https://linkedin.com/in/paulroetzer"
      twitter: "https://twitter.com/paulroetzer"
      blog: "https://marketingaiinstitute.com"
      focus: ["AI Marketing", "Enterprise AI"]
      
    - name: "Christopher Penn"
      linkedin: "https://linkedin.com/in/christopherspenn"
      twitter: "https://twitter.com/cspenn"
      blog: "https://christopherspenn.com"
      focus: ["Analytics", "AI Strategy"]
      
  tier_2:  # Adjacent thought leaders
    - name: "Liza Adams"
      linkedin: "https://linkedin.com/in/lizaadams"
      focus: ["AI Transformation", "Digital Strategy"]
      
  tier_3:  # Emerging voices to watch
    - name: "TBD"
      notes: "Add emerging voices as discovered"
```

**Output Structure**:
```markdown
# Competitive Analysis Report
**Period**: {timeframe}
**Competitors Analyzed**: {count}

## 📈 Content Performance Summary
| Competitor | Posts | Avg Engagement | Top Topic |
|------------|-------|----------------|-----------|
| {name}     | {n}   | {rate}         | {topic}   |

## 🎯 Positioning Analysis
{How each competitor is positioning themselves}

## 🔥 Viral Content Breakdown
{Analysis of top-performing content}

## 💡 Gap Opportunities
{Topics/angles competitors aren't covering}

## 📊 Engagement Patterns
{What types of content drive engagement}

## 🚀 Recommendations
{Specific actions to differentiate}
```

**Output Destinations**:
- Local: `2-research/competitive/{date}-analysis.md`
- Notion: "Competitive Intelligence" database

**Sub-Agent Used**: `competitive-analyst`

---

#### 5.2.3 `/content-repurpose`

**Purpose**: Transform existing content into platform-optimized formats while preserving voice.

**Trigger**: Manual

**Input Parameters**:
```yaml
source: string           # Path to source content or Notion page ID
target_platforms: [list] # ["linkedin", "twitter", "newsletter", "blog"]
variations: int          # Number of variations per platform (default: 2)
tone: string             # "educational" | "provocative" | "storytelling" (default: auto-detect)
include_hooks: bool      # Generate attention hooks (default: true)
```

**Output Structure** (per platform):
```markdown
# Content Repurpose: {source_title}
**Original**: {source_link}
**Generated**: {timestamp}

## LinkedIn Variations

### Version 1 (Educational)
**Hook**: {attention-grabbing first line}
**Body**: {main content}
**CTA**: {call to action}
**Hashtags**: {relevant hashtags}

### Version 2 (Provocative)
{...}

## Twitter/X Thread

### Thread (8 tweets)
1/ {hook tweet}
2/ {context}
...
8/ {CTA with link}

## Newsletter Snippet
{2-paragraph summary for newsletter inclusion}
```

**Output Destinations**:
- Local: `3-content/{date}-{source-slug}/`
- Notion: "Content Calendar" database (as draft entries)

**Sub-Agent Used**: `content-creator`

---

#### 5.2.4 `/brain-dump-analysis`

**Purpose**: Analyze accumulated notes, ideas, and brain dumps to identify patterns and content opportunities.

**Trigger**: Manual or scheduled (weekly)

**Input Parameters**:
```yaml
timeframe: string        # "week" | "month" | "quarter" | "all" (default: "month")
source_folders: [list]   # Override default brain dump locations
focus: string            # "patterns" | "pillars" | "gaps" | "all" (default: "all")
min_mentions: int        # Minimum times a theme must appear (default: 2)
```

**Brain Dump Sources**:
```yaml
sources:
  local:
    - path: "brain-dumps/"
    - path: "notes/daily/"
    - path: "notes/ideas/"
  notion:
    - database: "Brain Dumps"
    - database: "Quick Captures"
```

**Output Structure**:
```markdown
# Brain Dump Analysis
**Period**: {timeframe}
**Notes Analyzed**: {count}
**Unique Themes**: {count}

## 🎯 Content Pillars Identified
{Core themes that appear repeatedly}

### Pillar 1: {theme}
- Frequency: {count} mentions
- Related ideas: {list}
- Content potential: {high/medium/low}
- Suggested angles: {list}

## 📈 Theme Evolution
{How your thinking has evolved over time}

## 💡 Underexplored Ideas
{Interesting ideas mentioned once but worth developing}

## 🔗 Connection Map
{How different ideas connect to each other}

## 📝 Content Queue Recommendations
{Prioritized list of content to create}
```

**Output Destinations**:
- Local: `2-research/analysis/{date}-brain-analysis.md`
- Notion: "Content Ideas" database (creates entries for each pillar)

**Sub-Agent Used**: `pattern-analyst`

---

#### 5.2.5 `/daily-brief`

**Purpose**: Generate a personalized daily briefing combining market intelligence with calendar and priorities.

**Trigger**: Scheduled (daily at 6:00 AM) or manual

**Input Parameters**:
```yaml
include_calendar: bool   # Pull from calendar (default: false, future feature)
include_todos: bool      # Include pending tasks from Notion (default: true)
brief_length: string     # "quick" | "standard" | "comprehensive" (default: "standard")
```

**Output Structure**:
```markdown
# Daily Brief: {date}
**Generated**: {timestamp}

## ☀️ Good Morning, Enrique

### 🔥 Must-Know Today
{3-5 critical updates from overnight}

### 📊 Your Metrics Snapshot
- LinkedIn followers: {count} ({change})
- Newsletter subscribers: {count} ({change})
- Content published this week: {count}

### 📋 Priority Tasks
{Pulled from Notion Tasks in "Inbox" status}

### 💡 Content Opportunity of the Day
{Single high-potential topic based on trends}

### 📚 Recommended Reading
{2-3 articles worth your time}

### 🎯 Focus Suggestion
{AI recommendation for today's priority}
```

**Output Destinations**:
- Local: `2-research/daily-briefs/{date}-brief.md`
- Notion: "Daily Briefs" database

**Sub-Agent Used**: `intelligence-researcher` (reuses market-intel)

---

#### 5.2.6 `/weekly-dashboard`

**Purpose**: Interactive metric tracking and progress visualization.

**Trigger**: Manual (with guided prompts) or scheduled (Sundays)

**Input Parameters**:
```yaml
mode: string             # "guided" | "auto" (default: "guided")
metrics_source: string   # "manual" | "notion" | "both" (default: "both")
```

**Guided Mode Questions**:
```yaml
questions:
  professional:
    - "LinkedIn followers this week?"
    - "Newsletter subscribers?"
    - "Content pieces published?"
    - "Engagement highlights?"
  personal:
    - "Energy level (1-10)?"
    - "Key wins this week?"
    - "Challenges faced?"
    - "Learning highlights?"
  goals:
    - "Progress on Q1 goals?"
    - "Blockers to address?"
```

**Output Structure**:
```markdown
# Weekly Dashboard: Week {number}, {year}
**Period**: {start_date} - {end_date}

## 📊 Metrics Overview

### Audience Growth
| Platform | Current | Change | Target | Status |
|----------|---------|--------|--------|--------|
| LinkedIn | {n}     | +{n}   | {n}    | 🟢/🟡/🔴 |
| Newsletter| {n}    | +{n}   | {n}    | 🟢/🟡/🔴 |

### Content Output
- Posts published: {n}
- Engagement rate: {%}
- Top performer: {link}

## 🏆 Wins
{Bulleted list of achievements}

## 🎯 Goal Progress
{Visual progress bars or percentages}

## 📈 Trends
{Week-over-week analysis}

## 🚀 Next Week Focus
{AI-recommended priorities}
```

**Output Destinations**:
- Local: `2-research/dashboards/{year}-W{week}.md`
- Notion: "Weekly Reviews" database

**Sub-Agent Used**: `metrics-analyst`

---

#### 5.2.7 `/meeting-prep` (LOW PRIORITY)

**Purpose**: Generate meeting briefs and talking points.

**Trigger**: Manual

**Input Parameters**:
```yaml
meeting_type: string     # "podcast" | "presentation" | "interview" | "general"
topic: string            # Meeting topic or agenda
audience: string         # Description of audience
duration: int            # Minutes
include_research: bool   # Pull relevant market intel (default: true)
```

**Output**: Meeting brief with talking points, relevant data, and suggested questions.

---

#### 5.2.8 `/add-source`

**Purpose**: Add new sources to monitoring configuration.

**Trigger**: Manual

**Input Parameters**:
```yaml
type: string             # "blog" | "newsletter" | "news" | "competitor"
url: string              # Source URL
name: string             # Display name
priority: string         # "high" | "medium" | "low"
topics: [list]           # Associated topics
```

**Action**: Updates `config/sources.yaml` or `config/competitors.yaml`

---

#### 5.2.9 `/voice-calibrate`

**Purpose**: Analyze existing content to build/update voice profile.

**Trigger**: Manual (recommended monthly)

**Input Parameters**:
```yaml
sources: [list]          # Paths to sample content
platforms: [list]        # Which platform voices to calibrate
```

**Output**: Updates `config/voice-profile.yaml` with:
- Tone characteristics
- Vocabulary patterns
- Structural preferences
- Platform-specific adaptations

---

## 6. Sub-Agent Specifications

### 6.1 Sub-Agent Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    MAIN AGENT                           │
│                   (Claude Code)                         │
│                                                         │
│  Responsibilities:                                      │
│  • Command routing                                      │
│  • Context management                                   │
│  • Sub-agent orchestration                             │
│  • Output formatting                                    │
│  • Notion sync                                          │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ Intelligence  │ │  Competitive  │ │   Content     │
│  Researcher   │ │   Analyst     │ │   Creator     │
├───────────────┤ ├───────────────┤ ├───────────────┤
│ • Web scraping│ │ • Profile     │ │ • Voice match │
│ • Trend ID    │ │   analysis    │ │ • Platform    │
│ • Filtering   │ │ • Content     │ │   adaptation  │
│ • Synthesis   │ │   tracking    │ │ • Hook gen    │
└───────────────┘ └───────────────┘ └───────────────┘
        │             │             │
        ▼             ▼             ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│   Pattern     │ │   Metrics     │ │   Voice       │
│   Analyst     │ │   Analyst     │ │  Calibrator   │
├───────────────┤ ├───────────────┤ ├───────────────┤
│ • Theme       │ │ • Data pull   │ │ • Style       │
│   extraction  │ │ • Trend calc  │ │   analysis    │
│ • Connection  │ │ • Goal track  │ │ • Pattern     │
│   mapping     │ │ • Visualize   │ │   extraction  │
└───────────────┘ └───────────────┘ └───────────────┘
```

### 6.2 Sub-Agent Definitions

#### 6.2.1 Intelligence Researcher

```yaml
name: intelligence-researcher
purpose: "Scan, filter, and synthesize market intelligence from configured sources"

capabilities:
  - Web scraping via Firecrawl MCP
  - RSS feed parsing
  - Content relevance scoring
  - Trend identification
  - Summary generation

system_prompt: |
  You are an expert market intelligence analyst specializing in AI and marketing technology.
  
  Your role is to:
  1. Scan provided sources for relevant content
  2. Filter for topics matching the configured list
  3. Score content by relevance and impact
  4. Identify emerging trends and patterns
  5. Generate actionable summaries
  
  Always prioritize:
  - Practical applications over theoretical discussions
  - Enterprise/B2B marketing relevance
  - Emerging tools and platforms
  - Strategic implications
  
  Output format: Structured markdown with clear sections

tools_allowed:
  - firecrawl_scrape
  - web_search
  - file_read
  - file_write

output_location: "2-research/market-briefs/"
```

#### 6.2.2 Competitive Analyst

```yaml
name: competitive-analyst
purpose: "Track and analyze competitor content and positioning"

capabilities:
  - LinkedIn profile/post scraping
  - Content performance analysis
  - Positioning extraction
  - Gap identification
  - Trend comparison

system_prompt: |
  You are an expert competitive intelligence analyst focusing on thought leadership in the AI marketing space.
  
  Your role is to:
  1. Monitor competitor content across platforms
  2. Analyze engagement patterns and top performers
  3. Extract positioning and messaging strategies
  4. Identify content gaps and opportunities
  5. Provide differentiation recommendations
  
  Analysis framework:
  - Content themes and frequency
  - Engagement rates and patterns
  - Unique angles and perspectives
  - Audience response signals
  
  Output format: Comparative analysis with actionable insights

tools_allowed:
  - firecrawl_scrape
  - web_search
  - notion_read
  - file_write

output_location: "2-research/competitive/"
```

#### 6.2.3 Content Creator

```yaml
name: content-creator
purpose: "Generate platform-optimized content while preserving authentic voice"

capabilities:
  - Voice matching from profile
  - Platform-specific adaptation
  - Hook generation
  - Hashtag optimization
  - Multi-variation creation

system_prompt: |
  You are an expert content strategist and ghostwriter specializing in thought leadership content.
  
  Your role is to:
  1. Analyze source content for key messages
  2. Match the voice profile in config/voice-profile.yaml
  3. Adapt content for specific platforms
  4. Generate attention-grabbing hooks
  5. Create multiple variations
  
  Voice characteristics to maintain:
  - Professional but approachable
  - Data-informed perspectives
  - Practical, actionable insights
  - Global/enterprise context
  - Authentic personal experiences
  
  Platform guidelines:
  - LinkedIn: 1200-1500 characters, business professional
  - Twitter: Threaded narrative, punchy statements
  - Newsletter: Deeper analysis, personal voice
  
  Output format: Ready-to-post content with minimal editing needed

tools_allowed:
  - file_read
  - notion_read
  - file_write

output_location: "3-content/"
```

#### 6.2.4 Pattern Analyst

```yaml
name: pattern-analyst
purpose: "Analyze notes and ideas to identify themes and content opportunities"

capabilities:
  - Theme extraction
  - Frequency analysis
  - Connection mapping
  - Evolution tracking
  - Priority scoring

system_prompt: |
  You are an expert knowledge analyst specializing in identifying patterns in unstructured notes.
  
  Your role is to:
  1. Scan all brain dumps and notes in scope
  2. Extract recurring themes and topics
  3. Map connections between ideas
  4. Track how thinking evolves over time
  5. Recommend content priorities
  
  Analysis approach:
  - Look for explicit topic mentions
  - Identify implicit themes
  - Note emotional emphasis
  - Track question patterns
  - Find unexpected connections
  
  Output format: Structured analysis with content recommendations

tools_allowed:
  - file_read
  - notion_read
  - file_write

output_location: "2-research/analysis/"
```

#### 6.2.5 Metrics Analyst

```yaml
name: metrics-analyst
purpose: "Track, analyze, and visualize personal and professional metrics"

capabilities:
  - Data aggregation
  - Trend calculation
  - Goal tracking
  - Progress visualization
  - Recommendation generation

system_prompt: |
  You are a personal analytics expert helping track thought leadership growth.
  
  Your role is to:
  1. Collect metrics from various sources
  2. Calculate week-over-week and month-over-month changes
  3. Track progress against defined goals
  4. Generate visual dashboards
  5. Recommend focus areas
  
  Metrics to track:
  - Audience size (LinkedIn, newsletter)
  - Engagement rates
  - Content output
  - Personal energy/wellbeing
  - Goal progress
  
  Output format: Dashboard with trends and recommendations

tools_allowed:
  - notion_read
  - notion_write
  - file_read
  - file_write

output_location: "2-research/dashboards/"
```

---

## 7. Data Architecture

### 7.1 Data Flow Model

```
┌─────────────────────────────────────────────────────────────────┐
│                        INPUT SOURCES                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Web/RSS    │  │ Local Files  │  │    Notion    │          │
│  │              │  │              │  │              │          │
│  │ • News sites │  │ • Brain dumps│  │ • Brain Dumps│          │
│  │ • Blogs      │  │ • Notes      │  │ • Tasks      │          │
│  │ • LinkedIn   │  │ • PDFs       │  │ • Content    │          │
│  │ • Twitter    │  │ • Voice notes│  │   Calendar   │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                 │                 │                    │
│         └─────────────────┼─────────────────┘                   │
│                           │                                      │
│                           ▼                                      │
│                  ┌─────────────────┐                            │
│                  │   PROCESSING    │                            │
│                  │   (Claude Code) │                            │
│                  └────────┬────────┘                            │
│                           │                                      │
└───────────────────────────┼──────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                       OUTPUT LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│     LOCAL STORAGE                    NOTION DATABASES           │
│     ─────────────                    ────────────────           │
│                                                                  │
│  outputs/                            Market Intelligence DB      │
│  ├── intelligence/                   Competitive Analysis DB     │
│  ├── competitive/                    Content Calendar DB         │
│  ├── content/                        Weekly Reviews DB           │
│  ├── analysis/                       Daily Briefs DB             │
│  ├── dashboards/                     Content Ideas DB            │
│  └── daily/                                                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Notion Database Setup

**⚠️ IMPORTANT: You need to create these 6 databases in Notion before using PersonalOS.**

All databases are **new and dedicated** to PersonalOS (separate from your existing Personal Log and Tasks databases).

#### Required Notion Databases

| # | Database Name | Purpose | Create In |
|---|---------------|---------|-----------|
| 1 | **POS: Market Intelligence** | Curated insights from scanning | New Notion page |
| 2 | **POS: Competitive Analysis** | Competitor tracking | New Notion page |
| 3 | **POS: Content Calendar** | Draft content for publishing | New Notion page |
| 4 | **POS: Brain Dumps** | Idea capture (mobile-friendly) | New Notion page |
| 5 | **POS: Weekly Reviews** | Dashboard history | New Notion page |
| 6 | **POS: Daily Briefs** | Morning brief archive | New Notion page |

> **Naming Convention**: Prefix with "POS:" (PersonalOS) to keep databases organized and easily identifiable in Notion.

#### Database Schemas

#### 1. POS: Market Intelligence
```yaml
database: "POS: Market Intelligence"
properties:
  - name: "Title"
    type: title
  - name: "Date"
    type: date
  - name: "Priority"
    type: select
    options: ["🔴 High", "🟡 Medium", "🟢 Low"]
  - name: "Topics"
    type: multi_select
  - name: "Source"
    type: url
  - name: "Summary"
    type: rich_text
  - name: "Content Potential"
    type: select
    options: ["High", "Medium", "Low"]
  - name: "Status"
    type: select
    options: ["New", "Reviewed", "Used", "Archived"]
```

#### 2. POS: Content Calendar
```yaml
database: "POS: Content Calendar"
properties:
  - name: "Title"
    type: title
  - name: "Platform"
    type: select
    options: ["LinkedIn", "Newsletter", "Twitter", "Blog"]
  - name: "Status"
    type: select
    options: ["Idea", "Draft", "Review", "Scheduled", "Published"]
  - name: "Publish Date"
    type: date
  - name: "Content"
    type: rich_text
  - name: "Hook"
    type: rich_text
  - name: "Source"
    type: relation
    relation_to: "POS: Market Intelligence"
  - name: "Engagement"
    type: number
```

#### 3. POS: Brain Dumps
```yaml
database: "POS: Brain Dumps"
properties:
  - name: "Title"
    type: title
  - name: "Date"
    type: date
  - name: "Tags"
    type: multi_select
  - name: "Content"
    type: rich_text
  - name: "Processed"
    type: checkbox
  - name: "Related Content"
    type: relation
    relation_to: "POS: Content Calendar"
```

#### 4. POS: Competitive Analysis
```yaml
database: "POS: Competitive Analysis"
properties:
  - name: "Title"
    type: title
  - name: "Competitor"
    type: select
  - name: "Date"
    type: date
  - name: "Platform"
    type: select
    options: ["LinkedIn", "Twitter", "Newsletter", "Blog"]
  - name: "Content Type"
    type: select
  - name: "Engagement"
    type: number
  - name: "Key Insights"
    type: rich_text
  - name: "Opportunity"
    type: rich_text
```

#### 5. POS: Weekly Reviews
```yaml
database: "POS: Weekly Reviews"
properties:
  - name: "Week"
    type: title
  - name: "Date Range"
    type: date
  - name: "LinkedIn Followers"
    type: number
  - name: "Newsletter Subscribers"
    type: number
  - name: "Content Published"
    type: number
  - name: "Key Wins"
    type: rich_text
  - name: "Challenges"
    type: rich_text
  - name: "Next Week Focus"
    type: rich_text
```

#### 6. POS: Daily Briefs
```yaml
database: "POS: Daily Briefs"
properties:
  - name: "Date"
    type: title
  - name: "Generated"
    type: date
  - name: "Priority Updates"
    type: rich_text
  - name: "Content Opportunity"
    type: rich_text
  - name: "Full Brief"
    type: rich_text
  - name: "Status"
    type: select
    options: ["Generated", "Reviewed"]
```

### 7.3 Data Retention Policy

```yaml
retention:
  intelligence:
    duration: 90_days
    archive_to: "archive/intelligence/"
    
  competitive:
    duration: 180_days
    archive_to: "archive/competitive/"
    
  brain_dumps:
    duration: forever
    archive_to: null
    
  dashboards:
    duration: forever
    archive_to: null
    
  content_drafts:
    duration: 30_days
    archive_to: "archive/content/"
```

---

## 8. Integration Requirements

### 8.1 Required MCP Servers

| MCP Server | Purpose | Status | Configuration |
|------------|---------|--------|---------------|
| **Notion MCP** | Database sync | ✅ Connected | Existing setup |
| **Firecrawl MCP** | Web scraping | 🔲 Required | API key needed |
| **Perplexity MCP** | Web search | 🔲 Optional | Enhances research |

### 8.2 Firecrawl MCP Setup

```json
{
  "mcpServers": {
    "firecrawl": {
      "command": "npx",
      "args": ["-y", "firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "${FIRECRAWL_API_KEY}"
      }
    }
  }
}
```

### 8.3 Notion MCP Configuration

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_API_KEY": "${NOTION_API_KEY}"
      }
    }
  }
}
```

### 8.4 API Keys Required

| Service | Purpose | Free Tier | Estimated Usage |
|---------|---------|-----------|-----------------|
| Firecrawl | Web scraping | 500 pages/month | ~300 pages/month |
| Perplexity | Web search | Limited | ~100 queries/month |
| Notion | Database | Unlimited | N/A (existing) |

---

## 9. File Structure

### 9.1 Portable Design Principle

**PersonalOS is designed to be portable and location-agnostic.** 

- All paths are **relative** to wherever Claude Code is initialized
- You can clone/copy the folder anywhere and it will work
- Initialize Claude Code in the root folder: `cd /your/path/PersonalOS && claude`
- The system detects its own location automatically

```
# Works from ANY location:
cd ~/Documents/PersonalOS && claude    # ✅ Works
cd ~/Projects/PersonalOS && claude     # ✅ Works  
cd /Users/enrique/PersonalOS && claude # ✅ Works
```

### 9.2 Complete Directory Structure

```
./                                 # Root folder (wherever you initialize Claude Code)
├── CLAUDE.md                      # Main context file (Claude reads this first)
├── README.md                      # Project documentation
│
├── config/                        # Configuration files
│   ├── topics.yaml               # Monitored topics (scalable list)
│   ├── sources.yaml              # News/blog sources (user-extensible)
│   ├── competitors.yaml          # Competitor profiles
│   ├── voice-profile.yaml        # Writing voice config
│   ├── goals.yaml                # Tracking goals
│   └── notion-mapping.yaml       # Notion database IDs (configure once)
│
├── .claude/                       # Claude Code custom commands
│   └── commands/                  # Slash command definitions
│       ├── market-intelligence.md
│       ├── competitive-analysis.md
│       ├── content-repurpose.md
│       ├── brain-dump-analysis.md
│       ├── daily-brief.md
│       ├── weekly-dashboard.md
│       ├── meeting-prep.md
│       ├── add-source.md
│       └── voice-calibrate.md
│
├── sub-agents/                    # Sub-agent definitions
│   ├── intelligence-researcher.md
│   ├── competitive-analyst.md
│   ├── content-creator.md
│   ├── pattern-analyst.md
│   └── metrics-analyst.md
│
├── brain-dumps/                   # Raw ideas and notes (YOUR INPUT)
│   ├── 2026-01/
│   │   ├── 2026-01-06-ideas.md
│   │   └── ...
│   └── ...
│
├── inputs/                        # Input files for processing
│   ├── samples/                   # Voice calibration samples
│   │   ├── linkedin-posts/
│   │   └── newsletter-samples/
│   └── pdfs/                      # PDFs for analysis
│
├── outputs/                       # Generated content (AI OUTPUT)
│   ├── intelligence/             # Market intelligence briefs
│   ├── competitive/              # Competitive analysis
│   ├── content/                  # Repurposed content
│   │   └── {date}-{slug}/
│   ├── analysis/                 # Brain dump analysis
│   ├── dashboards/               # Weekly dashboards
│   └── daily/                    # Daily briefs
│
├── archive/                       # Archived outputs (auto-rotated)
│   ├── intelligence/
│   ├── competitive/
│   └── content/
│
├── scripts/                       # Automation scripts
│   ├── cron/
│   │   ├── daily-brief.sh
│   │   └── weekly-dashboard.sh
│   └── notion-sync.sh
│
└── logs/                          # Execution logs
    └── {date}-{command}.log
```

### 9.3 Path References in Code

All commands and sub-agents use **relative paths**:

```yaml
# ✅ CORRECT - Relative paths
input_path: "./brain-dumps/"
output_path: "./2-research/market-briefs/"
config_path: "./config/topics.yaml"

# ❌ WRONG - Absolute paths (not portable)
input_path: "/Users/enrique/PersonalOS/brain-dumps/"
```

### 9.2 Key File Templates

#### config/topics.yaml
```yaml
# PersonalOS Topic Configuration
# Add/modify topics to customize monitoring

version: 1.0
last_updated: 2026-01-06

topics:
  # Primary focus areas - always monitor
  primary:
    - name: "AI for Marketing"
      keywords: ["marketing AI", "AI marketing", "generative AI marketing"]
      priority: high
      
    - name: "AI Agents"
      keywords: ["AI agents", "agentic AI", "autonomous agents", "agent swarms"]
      priority: high
      
    - name: "Claude/Anthropic"
      keywords: ["Claude", "Anthropic", "Claude Code", "MCP protocol"]
      priority: high
      
    - name: "Marketing Automation"
      keywords: ["marketing automation", "martech", "marketing ops"]
      priority: high

  # Secondary focus - monitor when relevant
  secondary:
    - name: "Digital Transformation"
      keywords: ["digital transformation", "DX", "digital maturity"]
      priority: medium
      
    - name: "Enterprise AI"
      keywords: ["enterprise AI", "AI at scale", "AI governance"]
      priority: medium

  # Emerging - occasional deep dives
  emerging:
    - name: "Agentic Workflows"
      keywords: ["agentic", "agent workflows", "multi-agent"]
      priority: low
      
    - name: "MCP Ecosystem"
      keywords: ["MCP", "model context protocol", "MCP servers"]
      priority: low
```

#### config/voice-profile.yaml
```yaml
# PersonalOS Voice Profile
# Generated by /voice-calibrate command

version: 1.0
last_calibrated: 2026-01-06

identity:
  name: "Enrique"
  role: "AI Marketing Transformation Leader"
  context: "Leading AI transformation across 90+ countries at Syngenta"

tone:
  primary: "Professional yet approachable"
  attributes:
    - "Data-informed but not dry"
    - "Globally-minded perspective"
    - "Practical over theoretical"
    - "Confident but humble"
    - "Future-focused with grounded experience"

structure:
  linkedin:
    opening: "Hook with insight or question"
    body: "3-5 short paragraphs"
    closing: "Clear CTA or reflection question"
    length: "1200-1500 characters"
    
  newsletter:
    opening: "Personal anecdote or observation"
    body: "Structured with headers, deeper analysis"
    closing: "Actionable takeaways"
    length: "800-1200 words"
    
  twitter:
    style: "Punchy, threaded narratives"
    length: "6-10 tweets per thread"

vocabulary:
  preferred:
    - "transformation" over "change"
    - "practical" over "theoretical"
    - "global" context references
    - "AI agents" terminology
    
  avoid:
    - Excessive jargon without explanation
    - Overly casual language
    - Generic AI hype terms
    
patterns:
  - "Start with a contrarian take or surprising data"
  - "Include real examples from enterprise context"
  - "End with a forward-looking question"
  - "Use numbered lists for actionable items"
```

---

## 10. CLAUDE.md Configuration

### 10.1 Complete CLAUDE.md Template

```markdown
# PersonalOS - Claude Code Context

## System Identity

You are the orchestration agent for **PersonalOS**, an AI-powered personal branding and thought leadership operating system for Enrique.

### Your Core Responsibilities
1. Execute slash commands with precision and consistency
2. Manage and coordinate sub-agents for complex tasks
3. Maintain voice consistency across all generated content
4. Sync outputs to both local storage and Notion
5. Learn and improve from feedback over time

### Operating Principles
- **Quality over speed**: Take time to produce excellent outputs
- **Voice preservation**: Always match the voice profile
- **Transparency**: Explain your reasoning and sources
- **Proactive intelligence**: Surface insights even when not asked
- **Structured outputs**: Maintain consistent formatting

---

## User Context

### About Enrique
- **Role**: AI Marketing Transformation Manager at Syngenta
- **Scope**: Leading AI transformation across 90+ countries
- **Current Focus**: Building dMAX platform, thought leadership content
- **Platforms**: LinkedIn (primary), Newsletter (secondary)

### Content Pillars
1. AI for Marketing - Enterprise transformation strategies
2. Claude Code for Marketing - Practical applications and workflows
3. AI Agents for Marketing - Building and implementing agents
4. Building Agents - Technical tutorials and best practices
5. Digital Marketing Maturity - Frameworks and assessments

### Voice Characteristics
- Professional but approachable
- Data-informed perspectives
- Practical, actionable insights
- Global/enterprise context
- Authentic personal experiences

See `config/voice-profile.yaml` for detailed voice specifications.

---

## Available Commands

### High Priority
- `/market-intelligence` - Scan sources for AI marketing insights
- `/competitive-analysis` - Track competitor content and positioning
- `/content-repurpose` - Transform content for different platforms
- `/brain-dump-analysis` - Analyze notes for patterns and opportunities
- `/daily-brief` - Generate morning intelligence brief

### Medium Priority
- `/weekly-dashboard` - Track and visualize metrics

### Low Priority
- `/meeting-prep` - Generate meeting briefs

### Utility Commands
- `/add-source` - Add new sources to monitoring
- `/voice-calibrate` - Update voice profile from samples

---

## Sub-Agents

You have access to these specialized sub-agents:

1. **intelligence-researcher** - Web scraping and trend analysis
2. **competitive-analyst** - Competitor monitoring and analysis
3. **content-creator** - Voice-matched content generation
4. **pattern-analyst** - Theme extraction and connection mapping
5. **metrics-analyst** - Data tracking and visualization

See `sub-agents/` directory for detailed specifications.

---

## File Conventions

### Input Locations
- Brain dumps: `brain-dumps/YYYY-MM/`
- Voice samples: `1-capture/voice-samples/`
- PDFs: `inputs/pdfs/`

### Output Locations
- Intelligence: `2-research/market-briefs/`
- Competitive: `2-research/competitive/`
- Content: `3-content/{date}-{slug}/`
- Analysis: `2-research/analysis/`
- Dashboards: `2-research/dashboards/`
- Daily: `2-research/daily-briefs/`

### Naming Conventions
- Files: `YYYY-MM-DD-{descriptor}.md`
- Folders: `YYYY-MM-DD-{slug}/`
- Logs: `YYYY-MM-DD-{command}.log`

---

## Notion Integration

### Connected Databases (POS = PersonalOS)

After creating databases in Notion, add their IDs to `config/notion-mapping.yaml`:

```yaml
# config/notion-mapping.yaml
databases:
  market_intelligence: "{paste_database_id_here}"
  competitive_analysis: "{paste_database_id_here}"
  content_calendar: "{paste_database_id_here}"
  brain_dumps: "{paste_database_id_here}"
  weekly_reviews: "{paste_database_id_here}"
  daily_briefs: "{paste_database_id_here}"
```

**How to get Database ID**: Open database in Notion → Copy URL → Extract ID from URL:
`https://notion.so/{workspace}/{database_id}?v=...`

### Sync Rules
- All outputs sync to corresponding Notion database
- Local files are source of truth
- Notion is for accessibility and mobile access
- Never delete from Notion without explicit request

---

## Quality Standards

### Content Quality
- [ ] Matches voice profile
- [ ] Properly sourced and attributed
- [ ] Actionable insights included
- [ ] Appropriate length for platform
- [ ] Proofread for clarity

### Output Quality
- [ ] Correct file location
- [ ] Proper naming convention
- [ ] Notion sync completed
- [ ] Metadata included (date, sources, etc.)

---

## Error Handling

### On Web Scraping Failure
1. Log the error
2. Try alternative source if available
3. Proceed with available data
4. Note limitation in output

### On Notion Sync Failure
1. Save locally (always)
2. Retry sync 3 times
3. Log failure for manual review
4. Continue with command

### On Sub-Agent Failure
1. Capture partial results
2. Attempt simpler fallback
3. Provide partial output with notes
4. Suggest manual completion

---

## Learning & Improvement

### Feedback Incorporation
- Track which outputs receive edits
- Note common correction patterns
- Update voice profile quarterly
- Refine prompts based on usage

### Performance Tracking
- Log execution times
- Track source reliability
- Monitor Notion sync success
- Measure output quality scores

---

## Security Notes

- Never expose API keys in outputs
- Don't process sensitive corporate data
- Keep personal metrics private
- Archive, don't delete historical data

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-06 | Initial PersonalOS setup |
```

---

## 11. Implementation Phases

### 11.1 Phase Overview

```
Phase 1 (Week 1)     Phase 2 (Week 2)     Phase 3 (Week 3)     Phase 4 (Week 4)
─────────────────    ─────────────────    ─────────────────    ─────────────────
Foundation           Core Commands        Advanced Features    Polish & Automate
                                         
• File structure     • /market-intel      • /content-repurpose • Cron automation
• CLAUDE.md          • /competitive       • /brain-dump        • Voice refinement
• Config files       • /daily-brief       • Sub-agent tuning   • Performance opt
• Notion setup       • /add-source        • /weekly-dashboard  • Documentation
• Firecrawl MCP      • Basic sub-agents   • Notion sync        • Testing
```

### 11.2 Phase 1: Foundation (Week 1)

**Objective**: Set up complete file structure and configurations

**Tasks**:
- [ ] Create directory structure
- [ ] Write CLAUDE.md
- [ ] Configure topics.yaml with initial topics
- [ ] Configure sources.yaml with 20+ sources
- [ ] Configure competitors.yaml with 5-10 competitors
- [ ] Set up Notion databases (if not existing)
- [ ] Install and configure Firecrawl MCP
- [ ] Test MCP connections
- [ ] Create initial voice-profile.yaml (manual)
- [ ] Gather 10+ content samples for voice calibration

**Deliverables**:
- Complete file structure
- All configuration files populated
- MCP servers connected and tested
- Initial voice profile documented

**Success Criteria**:
- Claude Code can read all config files
- Notion MCP can read/write to databases
- Firecrawl can scrape test URLs

---

### 11.3 Phase 2: Core Commands (Week 2)

**Objective**: Implement high-priority slash commands

**Tasks**:
- [ ] Implement `/market-intelligence` command
- [ ] Implement `/competitive-analysis` command
- [ ] Implement `/daily-brief` command
- [ ] Implement `/add-source` utility command
- [ ] Create intelligence-researcher sub-agent
- [ ] Create competitive-analyst sub-agent
- [ ] Test all commands with real data
- [ ] Validate Notion sync for each command
- [ ] Document command usage

**Deliverables**:
- 4 working slash commands
- 2 sub-agents operational
- Command documentation
- Sample outputs for each command

**Success Criteria**:
- `/market-intelligence` produces actionable brief
- `/competitive-analysis` tracks configured competitors
- `/daily-brief` generates in <2 minutes
- All outputs sync to Notion

---

### 11.4 Phase 3: Advanced Features (Week 3)

**Objective**: Complete all commands and refine sub-agents

**Tasks**:
- [ ] Implement `/content-repurpose` command
- [ ] Implement `/brain-dump-analysis` command
- [ ] Implement `/weekly-dashboard` command
- [ ] Implement `/voice-calibrate` command
- [ ] Create content-creator sub-agent
- [ ] Create pattern-analyst sub-agent
- [ ] Create metrics-analyst sub-agent
- [ ] Tune voice matching quality
- [ ] Test cross-platform content generation
- [ ] Validate brain dump analysis accuracy

**Deliverables**:
- All 8 slash commands operational
- All 5 sub-agents defined and tested
- Voice calibration completed
- Full Notion integration

**Success Criteria**:
- Content repurpose maintains voice
- Brain dump analysis identifies real patterns
- Weekly dashboard pulls metrics correctly
- Sub-agents produce consistent quality

---

### 11.5 Phase 4: Polish & Automate (Week 4)

**Objective**: Automation, optimization, and documentation

**Tasks**:
- [ ] Set up cron job for daily brief (6 AM)
- [ ] Set up cron job for weekly dashboard (Sunday)
- [ ] Optimize execution times
- [ ] Add error handling and logging
- [ ] Create user documentation
- [ ] Run voice calibration with full sample set
- [ ] Test full weekly workflow
- [ ] Performance testing and optimization
- [ ] Create backup/restore scripts
- [ ] Final testing of all features

**Deliverables**:
- Automated daily/weekly runs
- Complete documentation
- Optimized performance
- Backup procedures

**Success Criteria**:
- Daily brief arrives by 6:30 AM
- Weekly dashboard auto-generates Sundays
- <5% error rate on automated runs
- Full documentation for maintenance

---

## 12. Technical Specifications

### 12.1 Environment Requirements

```yaml
runtime:
  node: ">=18.0.0"
  python: ">=3.9"  # For any Python scripts
  
claude_code:
  version: "latest"
  subscription: "Pro or Max recommended"
  
cursor:
  version: "latest"
  extensions:
    - "Markdown Preview Enhanced"
    - "YAML"
```

### 12.2 MCP Configuration

```json
// ~/.config/claude/claude_desktop_config.json (or equivalent)
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_API_KEY": "${NOTION_API_KEY}"
      }
    },
    "firecrawl": {
      "command": "npx", 
      "args": ["-y", "firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "${FIRECRAWL_API_KEY}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-filesystem"],
      "env": {
        "ALLOWED_PATHS": "/path/to/PersonalOS"
      }
    }
  }
}
```

### 12.3 Cron Schedule Configuration

```bash
# PersonalOS Cron Jobs
# Add to crontab with: crontab -e

# Daily brief at 6:00 AM
0 6 * * * cd /path/to/PersonalOS && ./scripts/cron/daily-brief.sh >> logs/cron.log 2>&1

# Weekly dashboard on Sunday at 8:00 PM
0 20 * * 0 cd /path/to/PersonalOS && ./scripts/cron/weekly-dashboard.sh >> logs/cron.log 2>&1

# Market intelligence refresh at noon
0 12 * * * cd /path/to/PersonalOS && ./scripts/cron/market-refresh.sh >> logs/cron.log 2>&1
```

### 12.4 Cron Script Example

```bash
#!/bin/bash
# scripts/cron/daily-brief.sh

# Load environment
source ~/.bashrc
export PATH="/usr/local/bin:$PATH"

# Set working directory
cd /path/to/PersonalOS

# Run Claude Code with daily-brief command
echo "$(date): Starting daily brief generation" >> logs/cron.log
claude --command "/daily-brief" 2>&1 | tee -a logs/$(date +%Y-%m-%d)-daily-brief.log

echo "$(date): Daily brief completed" >> logs/cron.log
```

### 12.5 Performance Targets

| Command | Target Time | Max Sources | Output Size |
|---------|-------------|-------------|-------------|
| `/market-intelligence` | <3 min | 30 sources | 2-4 KB |
| `/competitive-analysis` | <5 min | 10 competitors | 3-5 KB |
| `/daily-brief` | <2 min | 20 sources | 1-2 KB |
| `/content-repurpose` | <2 min | 1 source | 2-3 KB |
| `/brain-dump-analysis` | <3 min | 100 notes | 2-4 KB |
| `/weekly-dashboard` | <1 min | N/A | 1-2 KB |

---

## 13. Success Metrics

### 13.1 Quantitative Metrics

| Metric | Baseline | Target (30 days) | Target (90 days) |
|--------|----------|------------------|------------------|
| Daily research time | 120 min | 15 min | 10 min |
| Content drafting time | 90 min | 30 min | 20 min |
| LinkedIn posts/week | 2-3 | 5-7 | 7-10 |
| Newsletter issues/month | 2 | 4 | 4 |
| Ideas captured | Scattered | 100% in system | 100% + analyzed |
| Competitor awareness | Manual | Auto-tracked | Insights automated |

### 13.2 Qualitative Metrics

| Metric | Assessment Method | Target |
|--------|-------------------|--------|
| Voice match quality | Manual review | 90% first-draft usable |
| Intelligence relevance | Review accuracy | 80% actionable insights |
| Content engagement | LinkedIn analytics | Above personal average |
| System reliability | Error logs | <5% failure rate |
| User satisfaction | Self-assessment | High daily usage |

### 13.3 Tracking Dashboard

Create a simple tracking mechanism in Notion:

```yaml
PersonalOS Metrics:
  properties:
    - Date
    - Research Time (min)
    - Content Created (#)
    - Commands Run (#)
    - Errors (#)
    - Notes
```

---

## 14. Risk Assessment

### 14.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| MCP server instability | Medium | High | Local fallback, retry logic |
| Web scraping blocks | Medium | Medium | Rotate sources, use APIs |
| Claude rate limits | Low | Medium | Efficient prompting, caching |
| Notion sync failures | Low | Medium | Local-first storage |
| Voice drift over time | Medium | Low | Monthly calibration |

### 14.2 Operational Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Over-reliance on AI | Medium | Medium | Human review requirements |
| Content becomes generic | Medium | High | Strict voice enforcement |
| Information overload | Low | Medium | Progressive disclosure |
| Time investment ROI | Low | Medium | Phased implementation |

### 14.3 Contingency Plans

**If Firecrawl unavailable**:
- Fall back to Perplexity MCP for search
- Use RSS feeds where available
- Manual source checking for critical updates

**If Notion sync fails**:
- All outputs are local-first
- Batch sync when connection restores
- Manual copy for urgent items

**If voice quality degrades**:
- Increase sample corpus
- Add explicit voice rules
- Manual editing feedback loop

---

## 15. Appendices

### Appendix A: Sample Sources List

```yaml
# Initial sources for /market-intelligence

blogs:
  - name: "Anthropic Blog"
    url: "https://www.anthropic.com/news"
    type: "blog"
    priority: high
    topics: ["Claude", "AI Agents"]
    
  - name: "Marketing AI Institute"
    url: "https://www.marketingaiinstitute.com/blog"
    type: "blog"
    priority: high
    topics: ["AI for Marketing"]
    
  - name: "AI Maker (Wyndo)"
    url: "https://aimaker.substack.com"
    type: "newsletter"
    priority: high
    topics: ["Claude Code", "AI Agents"]
    
  - name: "McKay Wrigley"
    url: "https://mckaywrigley.substack.com"
    type: "newsletter"
    priority: high
    topics: ["Claude Code", "AI Agents"]
    
  - name: "The Neuron"
    url: "https://www.theneuron.ai"
    type: "newsletter"
    priority: medium
    topics: ["AI News"]
    
  - name: "Ben's Bites"
    url: "https://bensbites.beehiiv.com"
    type: "newsletter"
    priority: medium
    topics: ["AI News"]
    
  - name: "Lenny's Newsletter"
    url: "https://www.lennysnewsletter.com"
    type: "newsletter"
    priority: medium
    topics: ["Product", "Growth"]

news:
  - name: "TechCrunch AI"
    url: "https://techcrunch.com/category/artificial-intelligence/"
    type: "news"
    priority: medium
    
  - name: "VentureBeat AI"
    url: "https://venturebeat.com/category/ai/"
    type: "news"
    priority: medium
    
  - name: "The Verge AI"
    url: "https://www.theverge.com/ai-artificial-intelligence"
    type: "news"
    priority: low
```

### Appendix B: Competitor Profiles Template

```yaml
# Template for competitor tracking

competitor:
  name: "Example Thought Leader"
  
  platforms:
    linkedin:
      url: "https://linkedin.com/in/example"
      followers: 50000
      posting_frequency: "daily"
      
    twitter:
      url: "https://twitter.com/example"
      followers: 25000
      posting_frequency: "multiple_daily"
      
    newsletter:
      url: "https://example.substack.com"
      estimated_subscribers: 10000
      frequency: "weekly"
      
  focus_areas:
    - "AI Strategy"
    - "Marketing Technology"
    - "Enterprise AI"
    
  positioning: "Enterprise AI transformation expert"
  
  unique_angles:
    - "Heavy emphasis on ROI metrics"
    - "Case study focused approach"
    
  content_themes:
    - "Tool reviews"
    - "Implementation guides"
    - "Industry analysis"
    
  engagement_patterns:
    best_performing: "Controversial takes on AI hype"
    posting_times: "Early morning EST"
    
  notes: "Strong in enterprise context, weak on technical depth"
```

### Appendix C: Voice Profile Calibration Process

```markdown
## Voice Calibration Procedure

### Step 1: Gather Samples
Collect 10+ pieces of your best content:
- 5+ LinkedIn posts (high engagement)
- 3+ Newsletter articles
- 2+ Long-form content pieces

### Step 2: Run Calibration
```
/voice-calibrate --sources 1-capture/voice-samples/ --platforms linkedin,newsletter
```

### Step 3: Review Output
Check config/voice-profile.yaml for:
- Tone accuracy
- Vocabulary patterns
- Structural preferences
- Platform adaptations

### Step 4: Manual Refinement
Add/modify:
- Specific phrases to use/avoid
- Formatting preferences
- Topic-specific adjustments

### Step 5: Test Generation
Run /content-repurpose on a test piece and evaluate:
- Does it sound like you?
- Would you post it with minimal edits?
- Does it capture your unique perspective?

### Step 6: Iterate
Refine voice profile based on testing until 90%+ satisfaction.
```

### Appendix D: Notion Database Setup Guide (Step-by-Step)

```markdown
## Creating Required Notion Databases

### Before You Start
1. Decide where to create databases (dedicated "PersonalOS" page recommended)
2. Have Notion open in browser
3. Have `config/notion-mapping.yaml` ready to paste IDs

### Step 1: Create Parent Page
1. In Notion sidebar, click "+ Add a page"
2. Name it "🤖 PersonalOS"
3. This will contain all your databases

### Step 2: Create Each Database

#### 2.1 POS: Market Intelligence
1. Inside PersonalOS page, type `/database` → Select "Database - Full page"
2. Name: "POS: Market Intelligence"
3. Add properties:
   - Title (default) → Keep as "Title"
   - Add: Date (date)
   - Add: Priority (select) → Options: 🔴 High, 🟡 Medium, 🟢 Low
   - Add: Topics (multi_select)
   - Add: Source (url)
   - Add: Summary (text)
   - Add: Content Potential (select) → Options: High, Medium, Low
   - Add: Status (select) → Options: New, Reviewed, Used, Archived
4. Copy database ID from URL, paste into notion-mapping.yaml

#### 2.2 POS: Content Calendar
1. Create new database: "POS: Content Calendar"
2. Properties:
   - Title (default)
   - Platform (select) → LinkedIn, Newsletter, Twitter, Blog
   - Status (select) → Idea, Draft, Review, Scheduled, Published
   - Publish Date (date)
   - Content (text)
   - Hook (text)
   - Source (relation → POS: Market Intelligence)
   - Engagement (number)
3. Copy database ID

#### 2.3 POS: Brain Dumps
1. Create: "POS: Brain Dumps"
2. Properties:
   - Title (default)
   - Date (date)
   - Tags (multi_select)
   - Content (text)
   - Processed (checkbox)
   - Related Content (relation → POS: Content Calendar)
3. Copy database ID

#### 2.4 POS: Competitive Analysis
1. Create: "POS: Competitive Analysis"
2. Properties:
   - Title (default)
   - Competitor (select) → Add competitors as you go
   - Date (date)
   - Platform (select) → LinkedIn, Twitter, Newsletter, Blog
   - Content Type (select)
   - Engagement (number)
   - Key Insights (text)
   - Opportunity (text)
3. Copy database ID

#### 2.5 POS: Weekly Reviews
1. Create: "POS: Weekly Reviews"
2. Properties:
   - Week (title)
   - Date Range (date)
   - LinkedIn Followers (number)
   - Newsletter Subscribers (number)
   - Content Published (number)
   - Key Wins (text)
   - Challenges (text)
   - Next Week Focus (text)
3. Copy database ID

#### 2.6 POS: Daily Briefs
1. Create: "POS: Daily Briefs"
2. Properties:
   - Date (title)
   - Generated (date)
   - Priority Updates (text)
   - Content Opportunity (text)
   - Full Brief (text)
   - Status (select) → Generated, Reviewed
3. Copy database ID

### Step 3: Update notion-mapping.yaml
```yaml
# config/notion-mapping.yaml
databases:
  market_intelligence: "abc123..."  # Paste your ID
  competitive_analysis: "def456..."
  content_calendar: "ghi789..."
  brain_dumps: "jkl012..."
  weekly_reviews: "mno345..."
  daily_briefs: "pqr678..."
```

### Step 4: Verify Connection
Run this in Claude Code to test:
```
Check if Notion MCP can access the database: POS: Market Intelligence
```
```

### Appendix E: Troubleshooting Guide

```markdown
## Common Issues and Solutions

### Issue: Firecrawl returns empty results
**Cause**: Site may block scraping or require authentication
**Solution**: 
1. Check if site is accessible manually
2. Try alternative source for same information
3. Add to blocklist and find replacement source

### Issue: Notion sync fails
**Cause**: API rate limit or connection issue
**Solution**:
1. Check Notion API status
2. Verify database permissions
3. Retry with exponential backoff
4. Manual sync if urgent

### Issue: Voice doesn't match expected style
**Cause**: Insufficient calibration samples or drift
**Solution**:
1. Add more recent content samples
2. Run /voice-calibrate with fresh samples
3. Add explicit rules to voice-profile.yaml
4. Review and edit generated content for patterns

### Issue: Commands timing out
**Cause**: Too many sources or slow connections
**Solution**:
1. Reduce source count
2. Set shorter timeouts
3. Run during off-peak hours
4. Check network connectivity

### Issue: Duplicate content in Notion
**Cause**: Sync retry created duplicates
**Solution**:
1. Add deduplication logic based on date + title
2. Clean up manually
3. Check sync logs for errors
```

---

## Document Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| **Author** | Enrique | 2026-01-06 | _____________ |
| **Reviewer** | Claude Code | 2026-01-06 | ✅ Validated |

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-06 | Enrique | Initial PRD creation |

---

*This PRD is designed to be used directly with Claude Code for implementation. Copy this document to your PersonalOS project folder and reference it during development.*
