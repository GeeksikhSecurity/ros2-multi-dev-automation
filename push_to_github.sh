#!/bin/bash
# =============================================================================
# Push ROS2 Multi-Developer Automation to GitHub
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

main() {
    print_header "🚀 Pushing ROS2 Multi-Developer Automation to GitHub"
    print_header "===================================================="
    echo ""
    
    # Check if we're in the right directory
    if [[ ! "$(basename $(pwd))" == "ros2-multi-dev-automation" ]]; then
        print_error "Please run this script from the ros2-multi-dev-automation directory"
        exit 1
    fi
    
    print_status "Current directory: $(pwd)"
    
    # Check git status
    print_status "Checking git status..."
    git status --porcelain
    echo ""
    
    # Show current branches
    print_status "Current branches:"
    git branch -a
    echo ""
    
    print_header "🌲 Pushing branches to GitHub..."
    
    # Push main branch
    print_status "Switching to main branch..."
    git checkout main
    print_success "Switched to main branch"
    
    print_status "Pushing main branch..."
    git push -u origin main
    print_success "Main branch pushed successfully"
    
    # Push develop branch
    print_status "Switching to develop branch..."
    git checkout develop
    print_success "Switched to develop branch"
    
    print_status "Pushing develop branch..."
    git push origin develop
    print_success "Develop branch pushed successfully"
    
    # Push staging branch
    print_status "Switching to staging branch..."
    git checkout staging
    print_success "Switched to staging branch"
    
    print_status "Pushing staging branch..."
    git push origin staging
    print_success "Staging branch pushed successfully"
    
    # Create and push tag
    print_status "Creating release tag..."
    
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
    
    # Success message
    print_header "🎉 SUCCESS!"
    print_header "==========="
    echo ""
    print_success "Repository successfully pushed to GitHub!"
    echo ""
    echo -e "${GREEN}🌐 Repository URL:${NC} https://github.com/GeeksikhSecurity/ros2-multi-dev-automation"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo "1. Go to the repository and add topics: ros2, robotics, automation, development-tools"
    echo "2. Create a release from the v1.0.0 tag"
    echo "3. Enable Issues and Discussions"
    echo "4. Share with the ROS2 community!"
    echo ""
    echo -e "${PURPLE}🤖 Your ROS2 automation suite is now live!${NC}"
}

# Run main function
main "$@"
