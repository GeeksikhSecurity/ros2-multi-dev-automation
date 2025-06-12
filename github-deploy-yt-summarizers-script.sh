#!/bin/bash

# GitHub Repository Deployment Script
# This script will deploy local repositories to GitHub and set them as private

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_USER=""
GITHUB_ORG=""
USE_ORG=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if required commands are installed
check_requirements() {
    print_status "Checking requirements..."
    
    if ! command -v git &> /dev/null; then
        print_error "git is not installed. Please install git first."
        exit 1
    fi
    
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Please install it first:"
        echo "  - macOS: brew install gh"
        echo "  - Linux: see https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
        exit 1
    fi
    
    print_success "All requirements are installed"
}

# Function to check GitHub CLI authentication
check_gh_auth() {
    print_status "Checking GitHub CLI authentication..."
    
    if ! gh auth status &> /dev/null; then
        print_warning "You are not logged in to GitHub CLI"
        print_status "Starting GitHub authentication..."
        gh auth login
    else
        print_success "GitHub CLI is authenticated"
        GITHUB_USER=$(gh api user -q .login)
        print_status "Logged in as: $GITHUB_USER"
    fi
}

# Function to prompt for organization usage
prompt_org_usage() {
    echo ""
    read -p "Do you want to create repositories under an organization? (y/n): " use_org
    
    if [[ $use_org =~ ^[Yy]$ ]]; then
        USE_ORG=true
        read -p "Enter the organization name: " GITHUB_ORG
        
        # Verify organization access
        if ! gh api "orgs/$GITHUB_ORG" &> /dev/null; then
            print_error "Cannot access organization: $GITHUB_ORG"
            print_warning "Make sure you have the necessary permissions"
            exit 1
        fi
        
        print_success "Organization verified: $GITHUB_ORG"
    fi
}

# Function to create or update GitHub repository
deploy_repository() {
    local repo_path="$1"
    local repo_name="$2"
    local repo_description="$3"
    
    print_status "Processing repository: $repo_name"
    
    cd "$repo_path"
    
    # Check if it's a git repository
    if [ ! -d ".git" ]; then
        print_status "Initializing git repository..."
        git init
        git add .
        git commit -m "Initial commit" || {
            print_warning "No files to commit. Adding README.md..."
            echo "# $repo_name" > README.md
            git add README.md
            git commit -m "Initial commit"
        }
    fi
    
    # Check if remote origin exists
    if git remote get-url origin &> /dev/null; then
        print_warning "Remote 'origin' already exists"
        local current_remote=$(git remote get-url origin)
        echo "Current remote: $current_remote"
        
        # Extract owner and repo name from URL
        if [[ $current_remote =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
            local current_owner="${BASH_REMATCH[1]}"
            local current_repo="${BASH_REMATCH[2]%.git}"
            
            # Check if repository exists and update visibility
            if gh repo view "$current_owner/$current_repo" &> /dev/null; then
                print_status "Repository exists. Updating visibility to private..."
                gh repo edit "$current_owner/$current_repo" --visibility private
                print_success "Repository $current_owner/$current_repo is now private"
                return
            fi
        fi
        
        # If we can't update the existing repo, remove the remote
        print_warning "Removing existing remote to create new repository..."
        git remote remove origin
    fi
    
    # Create GitHub repository
    local create_cmd="gh repo create"
    
    if [ "$USE_ORG" = true ]; then
        create_cmd="$create_cmd $GITHUB_ORG/$repo_name"
    else
        create_cmd="$create_cmd $repo_name"
    fi
    
    create_cmd="$create_cmd --private --source=. --description=\"$repo_description\""
    
    print_status "Creating private repository on GitHub..."
    
    if eval "$create_cmd --push"; then
        print_success "Repository created and pushed successfully!"
    else
        print_error "Failed to create repository. It might already exist."
        
        # Try to add remote manually
        if [ "$USE_ORG" = true ]; then
            git remote add origin "git@github.com:$GITHUB_ORG/$repo_name.git"
        else
            git remote add origin "git@github.com:$GITHUB_USER/$repo_name.git"
        fi
        
        # Try to push
        if git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null; then
            print_success "Repository pushed successfully!"
        else
            print_error "Failed to push repository"
            return 1
        fi
    fi
    
    # Verify repository is private
    local repo_owner=$( [ "$USE_ORG" = true ] && echo "$GITHUB_ORG" || echo "$GITHUB_USER" )
    
    if gh repo view "$repo_owner/$repo_name" --json isPrivate -q .isPrivate | grep -q "true"; then
        print_success "Confirmed: Repository $repo_owner/$repo_name is private"
    else
        print_warning "Repository might not be private. Setting it to private..."
        gh repo edit "$repo_owner/$repo_name" --visibility private
    fi
}

# Main script
main() {
    echo "========================================"
    echo "GitHub Repository Deployment Script"
    echo "========================================"
    echo ""
    
    # Check requirements
    check_requirements
    
    # Check GitHub authentication
    check_gh_auth
    
    # Ask about organization
    prompt_org_usage
    
    # Repository 1: youtube-summarizer
    echo ""
    echo "========================================"
    echo "Repository 1: youtube-summarizer"
    echo "========================================"
    
    if [ -d "/Volumes/DATA/Git/youtube-summarizer" ]; then
        deploy_repository \
            "/Volumes/DATA/Git/youtube-summarizer" \
            "youtube-summarizer" \
            "YouTube video summarization service using Google Cloud Functions and Gemini AI"
    else
        print_error "Directory not found: /Volumes/DATA/Git/youtube-summarizer"
    fi
    
    # Repository 2: youtube-summarizer-enhanced
    echo ""
    echo "========================================"
    echo "Repository 2: youtube-summarizer-enhanced"
    echo "========================================"
    
    if [ -d "/Volumes/DATA/Git/youtube-summarizer-enhanced" ]; then
        # This repo already has a remote, so it will be updated
        deploy_repository \
            "/Volumes/DATA/Git/youtube-summarizer-enhanced" \
            "youtube-summarizer-enhanced" \
            "Enhanced YouTube summarizer with additional features"
    else
        print_error "Directory not found: /Volumes/DATA/Git/youtube-summarizer-enhanced"
    fi
    
    echo ""
    echo "========================================"
    echo "Deployment Summary"
    echo "========================================"
    
    local repo_owner=$( [ "$USE_ORG" = true ] && echo "$GITHUB_ORG" || echo "$GITHUB_USER" )
    
    echo ""
    print_status "Your repositories:"
    echo "  1. https://github.com/$repo_owner/youtube-summarizer (private)"
    
    # For the enhanced repo, check if it's under GeeksikhSecurity or the new location
    if [ -d "/Volumes/DATA/Git/youtube-summarizer-enhanced/.git" ]; then
        cd "/Volumes/DATA/Git/youtube-summarizer-enhanced"
        local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
        if [[ $remote_url =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
            echo "  2. https://github.com/${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git} (private)"
        else
            echo "  2. https://github.com/$repo_owner/youtube-summarizer-enhanced (private)"
        fi
    fi
    
    echo ""
    print_success "Script completed!"
    echo ""
    echo "Next steps:"
    echo "  - Verify repositories at https://github.com/$repo_owner"
    echo "  - Update any CI/CD configurations"
    echo "  - Update any documentation with new repository URLs"
    echo "  - Invite collaborators if needed"
}

# Run main function
main