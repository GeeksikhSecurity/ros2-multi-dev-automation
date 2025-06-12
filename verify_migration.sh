#!/bin/bash

# Git Repository Verification Script
# Run this after the migration to verify all repositories are intact

BASE_DIR="/Volumes/DATA/Git"
cd "$BASE_DIR"

echo "Verifying Git repositories after migration..."
echo "Current directory: $(pwd)"
echo ""

# Function to check Git repository health
check_git_repo() {
    local repo_path="$1"
    echo "Checking: $repo_path"
    
    if [ -d "$repo_path/.git" ]; then
        cd "$repo_path"
        
        # Check if Git is working
        if git status &>/dev/null; then
            echo "  ✓ Git status: OK"
            
            # Check remotes
            remotes=$(git remote)
            if [ -n "$remotes" ]; then
                echo "  ✓ Remotes: $remotes"
                git remote -v | sed 's/^/    /'
            else
                echo "  ℹ No remotes configured"
            fi
            
            # Check current branch
            branch=$(git branch --show-current 2>/dev/null || echo "detached")
            echo "  ✓ Current branch: $branch"
            
            # Check if working directory is clean
            if git diff-index --quiet HEAD --; then
                echo "  ✓ Working directory: clean"
            else
                echo "  ⚠ Working directory: has uncommitted changes"
            fi
            
        else
            echo "  ✗ Git repository appears corrupted"
        fi
        
        cd "$BASE_DIR"
    else
        echo "  ℹ Not a Git repository"
    fi
    echo ""
}

# Find and check all Git repositories
echo "Scanning for Git repositories..."
find . -name '.git' -type d | while read git_dir; do
    repo_dir=$(dirname "$git_dir")
    check_git_repo "$repo_dir"
done

echo "Repository verification completed!"
echo ""
echo "Summary of new structure:"
echo "========================="
tree -d -L 2 2>/dev/null || find . -type d -not -path '*/.*' | head -20
