#!/bin/bash
# Enable Perplexity Integration for PersonalOS
# Adds real-time intelligence features (breaking news, trend discovery)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         PersonalOS - Enable Real-Time Intelligence         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "This will configure Perplexity API for:"
echo -e "  ${GREEN}•${NC} Breaking news detection (last 48h)"
echo -e "  ${GREEN}•${NC} Trend discovery beyond configured sources"
echo -e "  ${GREEN}•${NC} Automatic source discovery"
echo ""
echo -e "You need a Perplexity API key. Get one at:"
echo -e "  ${BLUE}https://www.perplexity.ai/settings/api${NC}"
echo ""

# Check if already configured
SETTINGS_FILE=".claude/settings.local.json"
if [[ -f "$SETTINGS_FILE" ]] && grep -q "perplexity" "$SETTINGS_FILE" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Perplexity appears to be already configured.${NC}"
    read -p "Reconfigure? [y/N]: " reconfigure
    if [[ ! "$reconfigure" =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

# Prompt for API key
read -p "Enter your Perplexity API key (or 'q' to quit): " api_key

if [[ "$api_key" == "q" || -z "$api_key" ]]; then
    echo "Setup cancelled."
    exit 0
fi

# Validate key format (basic check)
if [[ ! "$api_key" =~ ^pplx- ]]; then
    echo -e "${YELLOW}⚠️  Warning: Key doesn't start with 'pplx-'. Continuing anyway...${NC}"
fi

echo ""
echo -e "${YELLOW}Configuring Perplexity...${NC}"

# Create .claude directory if needed
mkdir -p .claude

# Create/update .claude/settings.local.json
if [[ -f "$SETTINGS_FILE" ]]; then
    # Check if jq is available for merging
    if command -v jq &> /dev/null; then
        # Merge with existing settings, add MCP server and enable it
        jq --arg key "$api_key" '
            .mcpServers.perplexity = {
                "command": "npx",
                "args": ["-y", "perplexity-mcp"],
                "env": {"PERPLEXITY_API_KEY": $key}
            } |
            .enabledMcpjsonServers = ((.enabledMcpjsonServers // []) + ["perplexity"] | unique)
        ' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
        echo -e "${GREEN}  ✓ Updated $SETTINGS_FILE (merged with existing)${NC}"
    else
        echo -e "${YELLOW}  ⚠️  jq not found. Creating new settings file (backup saved).${NC}"
        cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup"
        cat > "$SETTINGS_FILE" << EOF
{
  "enabledMcpjsonServers": ["perplexity"],
  "mcpServers": {
    "perplexity": {
      "command": "npx",
      "args": ["-y", "perplexity-mcp"],
      "env": {
        "PERPLEXITY_API_KEY": "$api_key"
      }
    }
  }
}
EOF
        echo -e "${GREEN}  ✓ Created $SETTINGS_FILE (backup at ${SETTINGS_FILE}.backup)${NC}"
    fi
else
    cat > "$SETTINGS_FILE" << EOF
{
  "enabledMcpjsonServers": ["perplexity"],
  "mcpServers": {
    "perplexity": {
      "command": "npx",
      "args": ["-y", "perplexity-mcp"],
      "env": {
        "PERPLEXITY_API_KEY": "$api_key"
      }
    }
  }
}
EOF
    echo -e "${GREEN}  ✓ Created $SETTINGS_FILE${NC}"
fi

# Create research.yaml from template if it doesn't exist
if [[ ! -f "config/research.yaml" ]]; then
    if [[ -f "config/templates/research.template.yaml" ]]; then
        cp "config/templates/research.template.yaml" "config/research.yaml"
        echo -e "${GREEN}  ✓ Created config/research.yaml from template${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Template not found. You may need to create config/research.yaml manually.${NC}"
    fi
fi

# Enable perplexity in research.yaml if it exists
if [[ -f "config/research.yaml" ]]; then
    if command -v sed &> /dev/null; then
        # macOS and Linux compatible sed
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/enabled: false/enabled: true/' "config/research.yaml" 2>/dev/null || true
        else
            sed -i 's/enabled: false/enabled: true/' "config/research.yaml" 2>/dev/null || true
        fi
        echo -e "${GREEN}  ✓ Enabled Perplexity in config/research.yaml${NC}"
    fi
fi

# Create cache directory structure
mkdir -p outputs/cache/perplexity/queries
mkdir -p outputs/cache/perplexity/sources
echo -e "${GREEN}  ✓ Created cache directories${NC}"

# Create initial usage tracker
if [[ ! -f "outputs/cache/perplexity/usage.yaml" ]]; then
    cat > "outputs/cache/perplexity/usage.yaml" << EOF
# Perplexity API Usage Tracking
# Auto-updated by intelligence-agent

current_month: "$(date +%Y-%m)"
queries_count: 0
estimated_cost_usd: 0.00
last_updated: null
budget_exceeded: false
EOF
    echo -e "${GREEN}  ✓ Created usage tracker${NC}"
fi

echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           ✓ Perplexity Configured Successfully!            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Real-time intelligence is now enabled for:"
echo -e "  ${GREEN}•${NC} /market-intelligence"
echo -e "  ${GREEN}•${NC} /daily-brief"
echo ""
echo -e "${YELLOW}Important:${NC} Restart Claude Code to load the new MCP server."
echo ""
echo "Useful commands:"
echo -e "  ${BLUE}--no-real-time${NC}  Disable Perplexity for a single run"
echo -e "  ${BLUE}config/research.yaml${NC}  Adjust budget and settings"
echo ""
