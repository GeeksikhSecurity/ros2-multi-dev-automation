#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Pushing ROS2 Multi-Dev Automation to GitHub${NC}"
echo ""

# Repository details
REPO_NAME="ros2-multi-dev-automation"
GITHUB_USER="GeeksikhSecurity"
GITHUB_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo -e "${RED}❌ Not in a git repository. Initializing...${NC}"
    git init
fi

# Check current remote
CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${YELLOW}Current remote: ${CURRENT_REMOTE}${NC}"
    if [ "$CURRENT_REMOTE" != "$GITHUB_URL" ]; then
        echo -e "${YELLOW}Updating remote to: ${GITHUB_URL}${NC}"
        git remote set-url origin "$GITHUB_URL"
    fi
else
    echo -e "${YELLOW}Adding remote: ${GITHUB_URL}${NC}"
    git remote add origin "$GITHUB_URL"
fi

# Stage all files
echo -e "${GREEN}📁 Staging all files...${NC}"
git add -A

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo -e "${YELLOW}No changes to commit${NC}"
else
    echo -e "${GREEN}💾 Committing changes...${NC}"
    git commit -m "Initial commit: ROS2 Multi-Dev Automation Suite v1.0.0

Features:
- Complete ROS2 development environment automation
- Multi-workspace support
- Docker integration
- Comprehensive testing framework
- Automated package creation
- Branch management tools
- Documentation generation
- Real-time monitoring"
fi

# Push to GitHub
echo -e "${GREEN}📤 Pushing to GitHub...${NC}"
git push -u origin main --force

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ SUCCESS! Repository pushed to GitHub${NC}"
    echo -e "${GREEN}🌐 URL: https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Add repository topics: ros2, robotics, automation, development-tools"
    echo "2. Create a release from v1.0.0 tag"
    echo "3. Enable Issues and Discussions"
    echo "4. Share with the team for testing"
    echo ""
    echo -e "${GREEN}🤖 Your ROS2 automation suite is now live!${NC}"
else
    echo -e "${RED}❌ Push failed. Please check your GitHub credentials and try again.${NC}"
    echo "You may need to:"
    echo "1. Set up GitHub CLI: gh auth login"
    echo "2. Or use personal access token"
    echo "3. Or check if the repository exists on GitHub"
fi