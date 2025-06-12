#!/bin/bash

# Git Repository Reorganization Script
# This script safely moves repositories while preserving Git history

set -e  # Exit on any error

BASE_DIR="/Volumes/DATA/Git"
cd "$BASE_DIR"

echo "Starting Git repository reorganization..."
echo "Current directory: $(pwd)"

# Create backup of current structure
echo "Creating backup list of current structure..."
find . -maxdepth 1 -type d -name ".git" -o -name "*" | sort > migration_backup_$(date +%Y%m%d_%H%M%S).txt

# Function to safely move and verify Git repos
move_git_repo() {
    local source="$1"
    local destination="$2"
    
    if [ -d "$source" ]; then
        echo "Moving $source to $destination..."
        
        # Create destination directory if it doesn't exist
        mkdir -p "$(dirname "$destination")"
        
        # Move the repository
        mv "$source" "$destination"
        
        # Verify Git integrity
        if [ -d "$destination/.git" ]; then
            cd "$destination"
            if git status &>/dev/null; then
                echo "✓ Git repository $destination is intact"
            else
                echo "✗ WARNING: Git repository $destination may be corrupted"
            fi
            cd "$BASE_DIR"
        else
            echo "ℹ Note: $destination is not a Git repository"
        fi
    else
        echo "⚠ Warning: $source does not exist, skipping..."
    fi
}

# Step 1: Create new category directories
echo "Creating category directories..."
mkdir -p AI-Security-Research
mkdir -p Traditional-Security
mkdir -p Web-Development
mkdir -p Content-Management
mkdir -p Research-Projects
mkdir -p Scripts

# Step 2: Move AI Security repositories
echo "Moving AI Security repositories..."
move_git_repo "PyRIT" "AI-Security-Research/PyRIT"
move_git_repo "dspy-redteam" "AI-Security-Research/dspy-redteam"
move_git_repo "llm-adaptive-attacks" "AI-Security-Research/llm-adaptive-attacks"
move_git_repo "agentic_security" "AI-Security-Research/agentic_security"

# Handle LLM_Projects specially
if [ -d "LLM_Projects/promptfoo-testLLMs" ]; then
    move_git_repo "LLM_Projects/promptfoo-testLLMs" "AI-Security-Research/promptfoo-testLLMs"
    # Remove LLM_Projects if empty
    if [ -z "$(ls -A LLM_Projects 2>/dev/null)" ]; then
        rmdir LLM_Projects
        echo "Removed empty LLM_Projects directory"
    fi
fi

# Step 3: Move Traditional Security tools
echo "Moving Traditional Security repositories..."
move_git_repo "vulnhuntr" "Traditional-Security/vulnhuntr"
move_git_repo "Adversarial-AI---Attacks-Mitigations-and-Defense-Strategies" "Traditional-Security/Adversarial-AI---Attacks-Mitigations-and-Defense-Strategies"
move_git_repo "Bash-Shell-Scripting-for-Pentesters" "Traditional-Security/Bash-Shell-Scripting-for-Pentesters"
move_git_repo "Offensive-Security-Using-Python" "Traditional-Security/Offensive-Security-Using-Python"
move_git_repo "Security_Research" "Traditional-Security/Security_Research"
move_git_repo "Pentesting" "Traditional-Security/Pentesting"
move_git_repo "codeql" "Traditional-Security/codeql"
move_git_repo "cartography-master" "Traditional-Security/cartography-master"

# Step 4: Move Web Development projects
echo "Moving Web Development repositories..."
move_git_repo "youtube-summarizer" "Web-Development/youtube-summarizer"
move_git_repo "youtube-summarizer-enhanced" "Web-Development/youtube-summarizer-enhanced"
move_git_repo "craftflow-pro" "Web-Development/craftflow-pro"
move_git_repo "flowboost" "Web-Development/flowboost"
move_git_repo "aws-q-micromanager" "Web-Development/aws-q-micromanager"
move_git_repo "stackblitz-migration" "Web-Development/stackblitz-migration"

# Step 5: Move Content Management projects
echo "Moving Content Management repositories..."
move_git_repo "businessenabler-ai-blog" "Content-Management/businessenabler-ai-blog"
move_git_repo "businessenabler-blog" "Content-Management/businessenabler-blog"
move_git_repo "securityleaderai-blog" "Content-Management/securityleaderai-blog"
move_git_repo "singhskaurs-blog" "Content-Management/singhskaurs-blog"
move_git_repo "ai-product-notes" "Content-Management/ai-product-notes"

# Step 6: Move Research Projects
echo "Moving Research Projects..."
move_git_repo "bijection-learning" "Research-Projects/bijection-learning"
move_git_repo "mindweave" "Research-Projects/mindweave"
move_git_repo "DeVAIC" "Research-Projects/DeVAIC"

# Step 7: Move standalone files to Scripts
echo "Moving standalone files to Scripts..."
for file in *.sh *.js migration_log_*.txt *.zip *.png; do
    if [ -f "$file" ] && [ "$file" != "migrate_repositories.sh" ]; then
        mv "$file" Scripts/
        echo "Moved $file to Scripts/"
    fi
done

# Step 8: Create category README files
echo "Creating category README files..."

cat > AI-Security-Research/README.md << 'EOF'
# AI Security Research

This directory contains tools and frameworks specifically designed for AI/LLM security research, red teaming, and testing.

## Projects:
- **PyRIT**: Python Risk Identification Tool for AI systems
- **dspy-redteam**: DSPy-based red teaming framework
- **llm-adaptive-attacks**: Research on adaptive attacks against LLMs
- **promptfoo-testLLMs**: LLM testing and evaluation framework
- **agentic_security**: Security testing for agentic AI systems
EOF

cat > Traditional-Security/README.md << 'EOF'
# Traditional Security & Penetration Testing

This directory contains traditional cybersecurity tools, penetration testing frameworks, and security research projects.

## Projects:
- **vulnhuntr**: Vulnerability hunting and discovery tool
- **Pentesting**: General penetration testing resources and tools
- **codeql**: Static code analysis for security
- **cartography-master**: Network security mapping and visualization
- Additional security research and educational materials
EOF

cat > Web-Development/README.md << 'EOF'
# Web Development Projects

This directory contains web applications, services, and development tools.

## Projects:
- **youtube-summarizer**: AI-powered YouTube video summarization service
- **craftflow-pro**: Professional workflow management application
- **flowboost**: Productivity and workflow optimization tools
- **aws-q-micromanager**: AWS-based microservice management tool
EOF

cat > Content-Management/README.md << 'EOF'
# Content Management & Blogs

This directory contains blog platforms, content management systems, and publishing tools.

## Projects:
- Various blog platforms and content management systems
- AI-focused and security-focused publication tools
EOF

cat > Research-Projects/README.md << 'EOF'
# Research Projects

This directory contains experimental research projects and academic work.

## Projects:
- **bijection-learning**: Mathematical learning research
- **mindweave**: Cognitive computing research
- **DeVAIC**: Development and AI integration research
EOF

echo "✅ Migration completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review the new directory structure"
echo "2. Test Git functionality in moved repositories"
echo "3. Update any build scripts or CI/CD that reference old paths"
echo "4. Update IDE/editor workspace configurations"
echo ""
echo "To verify Git repositories:"
echo "find . -name '.git' -type d | sort"
