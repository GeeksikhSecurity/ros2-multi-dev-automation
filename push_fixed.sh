#!/bin/bash
# =============================================================================
# Push ROS2 Multi-Developer Automation to GitHub (Fixed)
# =============================================================================

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

main() {
    print_header "🚀 Pushing ROS2 Multi-Developer Automation to GitHub (Fixed)"
    print_header "============================================================="
    echo ""
    
    # Add the push script to git first
    print_status "Adding push script to git..."
    git add push_to_github.sh push_fixed.sh
    git commit -m "add: push scripts for repository management"
    
    print_status "Current directory: $(pwd)"
    print_status "Current branch: $(git branch --show-current)"
    
    # Pull and merge remote changes first
    print_status "Pulling remote changes to avoid conflicts..."
    git pull origin main --allow-unrelated-histories
    print_success "Remote changes merged successfully"
    
    # Now push main branch
    print_status "Pushing main branch..."
    git push -u origin main
    print_success "Main branch pushed successfully"
    
    # Switch to develop and push
    print_status "Switching to develop branch..."
    git checkout develop
    
    # Merge main into develop to sync
    print_status "Syncing develop with main..."
    git merge main --no-edit
    
    print_status "Pushing develop branch...")
    git push origin develop
    print_success "Develop branch pushed successfully"
    
    # Switch to staging and push
    print_status "Switching to staging branch..."
    git checkout staging
    
    # Merge main into staging to sync
    print_status "Syncing staging with main..."
    git merge main --no-edit
    
    print_status "Pushing staging branch..."
    git push origin staging
    print_success "Staging branch pushed successfully"
    
    # Go back to main for tagging
    git checkout main
    
    # Create and push tag
    print_status "Creating release tag v1.0.0..."
    
    git tag -a v1.0.0 -m "Release v1.0.0: ROS2 Multi-Developer Automation Suite

🤖 Comprehensive automation system for ROS2 development teams

✨ Features:
- Branch management with automated workflows
- Multi-language testing support (Python/C++)
- Real-time monitoring and dashboard
- Docker development environments
- Package template generator
- CI/CD pipeline with GitHub Actions
- Interactive setup wizard
- Comprehensive documentation

🎯 Perfect for robotics teams, autonomous vehicles, industrial automation.

Ready to transform ROS2 development workflows! 🚀"
    
    print_success "Release tag v1.0.0 created"
    
    print_status "Pushing release tag..."
    git push origin v1.0.0
    print_success "Release tag pushed successfully"
    
    # Verification
    print_header "📊 Final Status"
    print_status "Remote branches:"
    git branch -r
    
    print_status "Tags:"
    git tag -l
    
    # Success message
    print_header "🎉 SUCCESS!"
    print_header "==========="
    echo ""
    print_success "Repository successfully pushed to GitHub!"
    echo ""
    echo -e "${GREEN}🌐 Repository URL:${NC} https://github.com/GeeksikhSecurity/ros2-multi-dev-automation"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo "1. Go to GitHub and add repository topics:"
    echo "   ros2, robotics, automation, development-tools, ci-cd, python, cpp, docker"
    echo ""
    echo "2. Create a release:"
    echo "   - Go to Releases → Create new release"
    echo "   - Choose tag v1.0.0"
    echo "   - Add release description"
    echo ""
    echo "3. Enable repository features:"
    echo "   - Settings → Features → Enable Issues"
    echo "   - Settings → Features → Enable Discussions"
    echo ""
    echo "4. The other team can now test at:"
    echo "   https://github.com/GeeksikhSecurity/ros2-multi-dev-automation"
    echo ""
    echo -e "${PURPLE}🤖 Your ROS2 automation suite is now live and ready for testing!${NC}"
}

# Run main function
main "$@"
