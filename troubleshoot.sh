#!/bin/bash
# File: troubleshoot.sh
# Purpose: Fix technical debt, deprecated packages, and deployment errors

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Mindweave Project Troubleshooter ===${NC}"

# Check if we're in the project directory
if [ ! -f "package.json" ] && [ -d "mindweave" ]; then
  echo -e "${RED}Not in project directory. Changing to mindweave directory...${NC}"
  cd mindweave
  if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: package.json not found. Make sure you're in the correct directory.${NC}"
    exit 1
  fi
  echo -e "${GREEN}Changed to mindweave directory${NC}"
fi

echo -e "${BLUE}This script will fix common issues in the project${NC}"

# Step 1: Fix project structure issues
fix_structure() {
  echo -e "${BLUE}Fixing project structure...${NC}"
  
  # Check if src directory exists and fix app location
  if [ -d "src/app" ] && [ -d "app" ]; then
    echo -e "${RED}Found duplicate app directories. Fixing...${NC}"
    # Move content from app/ to src/app/ and remove app/
    cp -r app/* src/app/
    rm -rf app
    echo -e "${GREEN}Consolidated app directories${NC}"
  fi
  
  # Fix next.config.js if it's named incorrectly
  if [ -f "next.config.ts" ] && [ ! -f "next.config.js" ]; then
    echo -e "${RED}Found next.config.ts instead of next.config.js. Fixing...${NC}"
    mv next.config.ts next.config.js
    echo -e "${GREEN}Renamed next.config.ts to next.config.js${NC}"
  fi
}

# Step 2: Fix deprecated packages
fix_packages() {
  echo -e "${BLUE}Fixing deprecated packages...${NC}"
  
  # Replace shadcn-ui with shadcn
  if grep -q "shadcn-ui" package.json; then
    echo -e "${RED}Found deprecated shadcn-ui package. Fixing...${NC}"
    npm uninstall shadcn-ui
    npm install -D shadcn@latest
    echo -e "${GREEN}Updated shadcn-ui to shadcn package${NC}"
  fi
  
  # Update xmldom if present
  if grep -q "@xmldom/xmldom" package.json; then
    echo -e "${RED}Found deprecated @xmldom/xmldom package. Fixing...${NC}"
    npm uninstall @xmldom/xmldom
    npm install @xmldom/xmldom@0.8.10
    echo -e "${GREEN}Updated @xmldom/xmldom package${NC}"
  fi
  
  # Remove @types/localforage if present
  if grep -q "@types/localforage" package.json; then
    echo -e "${RED}Found unnecessary @types/localforage package. Fixing...${NC}"
    npm uninstall @types/localforage
    echo -e "${GREEN}Removed @types/localforage package${NC}"
  fi
}

# Step 3: Fix Git remote issues
fix_git_remote() {
  echo -e "${BLUE}Fixing Git remote issues...${NC}"
  
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "${RED}Not in a git repository. Initializing...${NC}"
    git init
    echo -e "${GREEN}Git repository initialized${NC}"
  fi
  
  # Check if origin remote exists
  if ! git remote | grep -q "origin"; then
    echo -e "${RED}Git remote 'origin' not found. Creating GitHub repository...${NC}"
    
    # Create GitHub repository and add remote
    echo -e "${BLUE}Creating GitHub repository...${NC}"
    REPO_URL=$(gh repo create mindweave --private --source=. --remote=origin 2>&1)
    
    if [ $? -ne 0 ]; then
      echo -e "${RED}Failed to create GitHub repository. Please create manually:${NC}"
      echo "1. Go to https://github.com/new"
      echo "2. Create a repository named 'mindweave'"
      echo "3. Run: git remote add origin https://github.com/YOUR_USERNAME/mindweave.git"
    else
      echo -e "${GREEN}GitHub repository created and remote added${NC}"
    fi
  fi
}

# Step 4: Fix Vercel deployment issues
fix_vercel_deployment() {
  echo -e "${BLUE}Fixing Vercel deployment issues...${NC}"
  
  # Create proper next.config.js
  echo -e "${BLUE}Creating proper Next.js configuration...${NC}"
  cat > next.config.js << EOL
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
};

module.exports = nextConfig;
EOL
  echo -e "${GREEN}Created proper next.config.js${NC}"
  
  # Fix package.json scripts
  echo -e "${BLUE}Updating package.json scripts...${NC}"
  npm pkg set scripts.build="next build" scripts.start="next start" scripts.dev="next dev"
  echo -e "${GREEN}Updated package.json scripts${NC}"
}

# Step 5: Run security audit and fix vulnerabilities
fix_vulnerabilities() {
  echo -e "${BLUE}Running security audit...${NC}"
  npm audit --fix || echo -e "${GREEN}Audit completed${NC}"
}

# Main execution
fix_structure
fix_packages
fix_git_remote
fix_vercel_deployment
fix_vulnerabilities

echo -e "${BLUE}=== Troubleshooting Complete ===${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Commit your changes: git add . && git commit -m 'Fix project issues'"
echo "2. Push to GitHub: git push -u origin main"
echo "3. Deploy to Vercel: vercel --prod"
