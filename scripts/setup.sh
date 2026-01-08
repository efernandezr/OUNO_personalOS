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
echo "║     AI-Powered Personal Branding Operating System         ║"
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

echo ""
echo -e "${YELLOW}Step 2: Creating directory structure...${NC}"

# Create necessary directories
dirs=("brain-dumps" "outputs/intelligence" "outputs/content" "outputs/analysis" "outputs/daily" "outputs/competitive" "outputs/dashboards" "inputs/samples/linkedin-posts" "inputs/samples/newsletter-samples" "inputs/pdfs" "logs" "archive")

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
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. ${BLUE}Configure your settings:${NC}"
echo "   Edit the files in config/ with your personal information:"
echo "   - config/voice-profile.yaml  → Your writing voice"
echo "   - config/sources.yaml        → Sources to monitor"
echo "   - config/topics.yaml         → Topics to track"
echo "   - config/goals.yaml          → Your goals"
echo "   - config/competitors.yaml    → Competitors to watch"
echo ""
echo "2. ${BLUE}Set up Notion integration:${NC}"
echo "   - Create databases in Notion using schemas in config/notion-mapping.template.yaml"
echo "   - Copy database IDs to config/notion-mapping.yaml"
echo "   - Configure Notion MCP in Claude Code settings"
echo ""
echo "3. ${BLUE}Configure MCP servers:${NC}"
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
echo "4. ${BLUE}Test your setup:${NC}"
echo "   cd $PROJECT_DIR"
echo "   claude"
echo "   /daily-brief"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "For more info, see ${GREEN}README.md${NC}"
echo ""
