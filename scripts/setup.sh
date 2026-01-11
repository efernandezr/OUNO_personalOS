#!/bin/bash
# PersonalOS Setup Script
# Copies template configs and guides initial setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                   PersonalOS Setup                        ║"
echo "║        AI-Powered Content Operating System                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo -e "${YELLOW}Step 1: Creating config files from templates...${NC}"

# Check if config files already exist
if [ -f "config/sources.yaml" ]; then
    echo -e "${YELLOW}  Config files already exist. Skipping to avoid overwriting.${NC}"
    echo -e "${YELLOW}  Delete config/*.yaml files first if you want to reset.${NC}"
else
    # Copy templates to config
    for template in config/templates/*.template.yaml; do
        filename=$(basename "$template" .template.yaml)
        cp "$template" "config/${filename}.yaml"
        echo -e "${GREEN}  ✓ Created config/${filename}.yaml${NC}"
    done
fi

# Create CLAUDE.md from template if it doesn't exist
if [ -f "CLAUDE.md" ]; then
    echo -e "${BLUE}  ○ CLAUDE.md already exists${NC}"
else
    if [ -f "CLAUDE.template.md" ]; then
        cp "CLAUDE.template.md" "CLAUDE.md"
        echo -e "${GREEN}  ✓ Created CLAUDE.md from template${NC}"
        echo -e "${YELLOW}    → Edit CLAUDE.md to customize your user context${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}Step 2: Creating directory structure...${NC}"

# Create necessary directories
dirs=("1-capture/brain-dumps" "1-capture/voice-samples/linkedin-posts" "1-capture/voice-samples/newsletter-samples" "1-capture/documents" "2-research/market-briefs" "2-research/daily-briefs" "2-research/analysis" "2-research/competitive" "2-research/dashboards" "3-content/linkedin" "3-content/twitter" "3-content/newsletter" "4-archive" "system/logs" "system/cache" "system/specs" "system/planning")

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${GREEN}  ✓ Created $dir/${NC}"
    else
        echo -e "${BLUE}  ○ $dir/ already exists${NC}"
    fi
done

echo ""
echo -e "${YELLOW}Step 3: Checking prerequisites...${NC}"

# Check for Claude Code
if command -v claude &> /dev/null; then
    echo -e "${GREEN}  ✓ Claude Code is installed${NC}"
else
    echo -e "${RED}  ✗ Claude Code not found${NC}"
    echo -e "    Install from: https://claude.ai/code"
fi

# Check for gh CLI (optional, for GitHub integration)
if command -v gh &> /dev/null; then
    echo -e "${GREEN}  ✓ GitHub CLI is installed${NC}"
else
    echo -e "${YELLOW}  ○ GitHub CLI not found (optional)${NC}"
    echo -e "    Install from: https://cli.github.com"
fi

echo ""
echo -e "${YELLOW}Step 4: Optional Features...${NC}"
echo ""
echo -e "┌─────────────────────────────────────────────────────────────┐"
echo -e "│ ${BLUE}Optional: Real-Time Intelligence (Perplexity)${NC}               │"
echo -e "└─────────────────────────────────────────────────────────────┘"
echo ""
echo "PersonalOS can use Perplexity API for:"
echo -e "  ${GREEN}•${NC} Breaking news detection (last 48h)"
echo -e "  ${GREEN}•${NC} Trend discovery beyond configured sources"
echo -e "  ${GREEN}•${NC} Automatic source discovery"
echo ""
echo "This requires a Perplexity API key (free tier available)."
echo -e "You can enable this later by running: ${BLUE}./scripts/enable-perplexity.sh${NC}"
echo ""

read -p "Enable real-time intelligence now? [y/N]: " enable_perplexity

if [[ "$enable_perplexity" =~ ^[Yy]$ ]]; then
    ./scripts/enable-perplexity.sh
else
    echo ""
    echo -e "${YELLOW}  ℹ️  Skipped. Run ./scripts/enable-perplexity.sh anytime to enable.${NC}"

    # Still create research.yaml with perplexity disabled if template exists
    if [[ ! -f "config/research.yaml" ]] && [[ -f "config/templates/research.template.yaml" ]]; then
        cp "config/templates/research.template.yaml" "config/research.yaml"
        # Disable perplexity by default
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/enabled: true/enabled: false/' "config/research.yaml" 2>/dev/null || true
        else
            sed -i 's/enabled: true/enabled: false/' "config/research.yaml" 2>/dev/null || true
        fi
        echo -e "${GREEN}  ✓ Created config/research.yaml (Perplexity disabled)${NC}"
    fi
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. ${BLUE}Customize your context:${NC}"
echo "   Edit CLAUDE.md with your personal information:"
echo "   - Your role and focus area"
echo "   - Content pillars (3-5 topics you create content around)"
echo "   - Voice characteristics"
echo ""
echo "2. ${BLUE}Configure your settings:${NC}"
echo "   Edit the files in config/ with your preferences:"
echo "   - config/voice-profile.yaml  → Your writing voice"
echo "   - config/sources.yaml        → Sources to monitor"
echo "   - config/topics.yaml         → Topics to track"
echo "   - config/goals.yaml          → Your goals"
echo "   - config/competitors.yaml    → People/orgs to watch"
echo ""
echo "3. ${BLUE}Set up Notion integration:${NC}"
echo "   - Create databases in Notion using schemas in config/notion-mapping.template.yaml"
echo "   - Copy database IDs to config/notion-mapping.yaml"
echo "   - Configure Notion MCP in Claude Code settings"
echo ""
echo "4. ${BLUE}Configure MCP servers:${NC}"
echo "   Add to your Claude Code settings:"
echo '   {
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
           "FIRECRAWL_API_KEY": "your-api-key"
         }
       }
     }
   }'
echo ""
echo "5. ${BLUE}Test your setup:${NC}"
echo "   cd $PROJECT_DIR"
echo "   claude"
echo "   /daily-brief"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "For more info, see ${GREEN}README.md${NC}"
echo ""
