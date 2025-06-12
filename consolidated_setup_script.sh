        # Recent commits
        local recent_commits=$(git log --author="$member" --oneline --since="7 days ago" 2>/dev/null | wc -l || echo "0")
        echo "  📝 Commits (7 days): $recent_commits"
        
        # Active branches
        local active_branches=$(git branch -a 2>/dev/null | grep -c "$member" || echo "0")
        echo "  🌲 Active branches: $active_branches"
        
        # Last activity
        local last_commit=$(git log --author="$member" --oneline -1 --since="30 days ago" 2>/dev/null)
        if [[ -n "$last_commit" ]]; then
            echo "  🕐 Last activity: ${last_commit:0:60}..."
        else
            echo "  🕐 Last activity: No recent activity"
        fi
        echo ""
    done
}

show_performance() {
    echo "⚡ Performance Metrics"
    echo "====================="
    echo ""
    
    # Development velocity
    echo "📈 Development Velocity (last 30 days):"
    local commits_month=$(git log --since="30 days ago" --oneline 2>/dev/null | wc -l || echo "0")
    local files_changed=$(git log --since="30 days ago" --name-only --pretty=format: 2>/dev/null | sort -u | wc -l || echo "0")
    echo "  Total commits: $commits_month"
    echo "  Files changed: $files_changed"
    echo "  Average commits/day: $((commits_month / 30))"
    echo ""
    
    # Build performance
    echo "🔨 Build Performance:"
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    if [[ -d "$expanded_workspace_dir/log" ]]; then
        echo "  Build logs available in workspace"
        local recent_builds=$(find "$expanded_workspace_dir/log" -name "*.log" -mtime -1 2>/dev/null | wc -l)
        echo "  Recent builds (24h): $recent_builds"
    else
        echo "  No build logs found"
    fi
}

# Main command dispatcher
case "$1" in
    "status")
        show_status
        ;;
    "logs")
        echo "📄 Recent logs feature - check your workspace log/ directory"
        local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
        if [[ -d "$expanded_workspace_dir/log" ]]; then
            echo "Build logs: $expanded_workspace_dir/log/"
            ls -la "$expanded_workspace_dir/log/" 2>/dev/null | head -10
        fi
        ;;
    "resources")
        echo "💻 System resource monitoring"
        df -h
        echo ""
        if command -v free &> /dev/null; then
            free -h
        elif command -v vm_stat &> /dev/null; then
            vm_stat
        fi
        ;;
    "performance")
        show_performance
        ;;
    "watch")
        watch_dashboard
        ;;
    "team")
        show_team_activity
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        show_help
        exit 1
        ;;
esac
EOF
    print_success "Created scripts/monitor.sh"
    
    # Create scripts/create_package.sh (abbreviated version)
    cat << 'EOF' > scripts/create_package.sh
#!/bin/bash
# =============================================================================
# ROS2 Package Creator - Template Generator
# =============================================================================

# Source configuration
if [[ -f "config/dev_config.sh" ]]; then
    source config/dev_config.sh
else
    echo "❌ Configuration file not found: config/dev_config.sh"
    exit 1
fi

show_help() {
    echo "📦 ROS2 Package Creator"
    echo "Usage: $0 <package_name> <language> [description]"
    echo ""
    echo "Languages: python, cpp"
    echo ""
    echo "Examples:"
    echo "  $0 my_navigation cpp 'Navigation package for autonomous robot'"
    echo "  $0 sensor_fusion python 'Sensor data fusion algorithms'"
}

create_python_package() {
    local pkg_name=$1
    local description=$2
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    
    echo "📦 Creating Python ROS2 package: $pkg_name"
    
    if [[ ! -d "$expanded_workspace_dir/src" ]]; then
        mkdir -p "$expanded_workspace_dir/src"
    fi
    
    cd "$expanded_workspace_dir/src"
    
    # Use ros2 pkg create if available
    if command -v ros2 &> /dev/null; then
        ros2 pkg create --build-type ament_python --dependencies rclpy std_msgs "$pkg_name" --description "$description"
        echo "✅ Python package created using ros2 pkg create"
    else
        # Manual creation
        mkdir -p "$pkg_name/$pkg_name"
        mkdir -p "$pkg_name/test"
        mkdir -p "$pkg_name/launch"
        
        # Create basic package.xml
        cat << PACKAGE_EOF > "$pkg_name/package.xml"
<?xml version="1.0"?>
<package format="3">
  <name>$pkg_name</name>
  <version>0.0.1</version>
  <description>$description</description>
  <maintainer email="developer@example.com">Developer</maintainer>
  <license>MIT</license>
  <depend>rclpy</depend>
  <depend>std_msgs</depend>
  <test_depend>python3-pytest</test_depend>
  <export><build_type>ament_python</build_type></export>
</package>
PACKAGE_EOF
        
        # Create basic setup.py
        cat << SETUP_EOF > "$pkg_name/setup.py"
from setuptools import setup
package_name = '$pkg_name'
setup(
    name=package_name,
    version='0.0.1',
    packages=[package_name],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='Developer',
    maintainer_email='developer@example.com',
    description='$description',
    license='MIT',
    entry_points={
        'console_scripts': [
            '${pkg_name}_node = ${pkg_name}.${pkg_name}_node:main',
        ],
    },
)
SETUP_EOF
        
        # Create basic node
        touch "$pkg_name/$pkg_name/__init__.py"
        cat << NODE_EOF > "$pkg_name/$pkg_name/${pkg_name}_node.py"
#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from std_msgs.msg import String

class ${pkg_name^}Node(Node):
    def __init__(self):
        super().__init__('${pkg_name}_node')
        self.publisher = self.create_publisher(String, '${pkg_name}/status', 10)
        self.timer = self.create_timer(1.0, self.timer_callback)
        self.get_logger().info('${pkg_name^}Node started')
    
    def timer_callback(self):
        msg = String()
        msg.data = f'${pkg_name} running'
        self.publisher.publish(msg)

def main(args=None):
    rclpy.init(args=args)
    node = ${pkg_name^}Node()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()
NODE_EOF
        
        echo "✅ Python package created manually"
    fi
    
    echo "💡 Next steps:"
    echo "  1. cd $expanded_workspace_dir"
    echo "  2. colcon build --packages-select $pkg_name"
    echo "  3. source install/setup.bash"
    echo "  4. ros2 run $pkg_name ${pkg_name}_node"
}

create_cpp_package() {
    local pkg_name=$1
    local description=$2
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    
    echo "📦 Creating C++ ROS2 package: $pkg_name"
    
    if [[ ! -d "$expanded_workspace_dir/src" ]]; then
        mkdir -p "$expanded_workspace_dir/src"
    fi
    
    cd "$expanded_workspace_dir/src"
    
    # Use ros2 pkg create if available
    if command -v ros2 &> /dev/null; then
        ros2 pkg create --build-type ament_cmake --dependencies rclcpp std_msgs "$pkg_name" --description "$description"
        echo "✅ C++ package created using ros2 pkg create"
    else
        # Manual creation
        mkdir -p "$pkg_name/src"
        mkdir -p "$pkg_name/include/$pkg_name"
        
        # Create basic package.xml
        cat << PACKAGE_EOF > "$pkg_name/package.xml"
<?xml version="1.0"?>
<package format="3">
  <name>$pkg_name</name>
  <version>0.0.1</version>
  <description>$description</description>
  <maintainer email="developer@example.com">Developer</maintainer>
  <license>MIT</license>
  <buildtool_depend>ament_cmake</buildtool_depend>
  <depend>rclcpp</depend>
  <depend>std_msgs</depend>
  <export><build_type>ament_cmake</build_type></export>
</package>
PACKAGE_EOF
        
        # Create basic CMakeLists.txt
        cat << CMAKE_EOF > "$pkg_name/CMakeLists.txt"
cmake_minimum_required(VERSION 3.8)
project($pkg_name)

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)

add_executable(${pkg_name}_node src/${pkg_name}_node.cpp)
ament_target_dependencies(${pkg_name}_node rclcpp std_msgs)

install(TARGETS ${pkg_name}_node DESTINATION lib/\${PROJECT_NAME})

ament_package()
CMAKE_EOF
        
        # Create basic node
        cat << NODE_EOF > "$pkg_name/src/${pkg_name}_node.cpp"
#include <rclcpp/rclcpp.hpp>
#include <std_msgs/msg/string.hpp>

class ${pkg_name^}Node : public rclcpp::Node {
public:
    ${pkg_name^}Node() : Node("${pkg_name}_node") {
        publisher_ = this->create_publisher<std_msgs::msg::String>("${pkg_name}/status", 10);
        timer_ = this->create_wall_timer(
            std::chrono::seconds(1),
            std::bind(&${pkg_name^}Node::timer_callback, this));
        RCLCPP_INFO(this->get_logger(), "${pkg_name^}Node started");
    }

private:
    void timer_callback() {
        auto message = std_msgs::msg::String();
        message.data = "${pkg_name} running";
        publisher_->publish(message);
    }
    rclcpp::Publisher<std_msgs::msg::String>::SharedPtr publisher_;
    rclcpp::TimerBase::SharedPtr timer_;
};

int main(int argc, char * argv[]) {
    rclcpp::init(argc, argv);
    rclcpp::spin(std::make_shared<${pkg_name^}Node>());
    rclcpp::shutdown();
    return 0;
}
NODE_EOF
        
        echo "✅ C++ package created manually"
    fi
    
    echo "💡 Next steps:"
    echo "  1. cd $expanded_workspace_dir"
    echo "  2. colcon build --packages-select $pkg_name"
    echo "  3. source install/setup.bash"
    echo "  4. ros2 run $pkg_name ${pkg_name}_node"
}

# Main script logic
if [[ $# -lt 2 ]]; then
    show_help
    exit 1
fi

package_name=$1
language=$2
description=${3:-"ROS2 package for $package_name"}

case "$language" in
    "python"|"py")
        create_python_package "$package_name" "$description"
        ;;
    "cpp"|"c++")
        create_cpp_package "$package_name" "$description"
        ;;
    *)
        echo "❌ Unknown language: $language"
        echo "Supported languages: python, cpp"
        exit 1
        ;;
esac

# Update configuration
echo ""
echo "📝 To add this package to your configuration:"
echo "Edit config/dev_config.sh and add:"
echo "    [\"$package_name\"]=\"$language\""
echo "to the PACKAGES array"
EOF
    print_success "Created scripts/create_package.sh"
}

# Create Docker files
create_docker_files() {
    print_status "Creating Docker configuration..."
    
    cat << 'EOF' > docker/Dockerfile.ros2
FROM ros:humble-desktop

# Install development tools
RUN apt-get update && apt-get install -y \
    python3-colcon-common-extensions \
    python3-pytest \
    python3-pytest-cov \
    libgtest-dev \
    cmake \
    git \
    vim \
    htop \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Setup workspace
WORKDIR /ros2_ws

# Copy source code
COPY . .

# Install package dependencies
RUN rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y || true

# Build workspace
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build" || echo "Build may fail without source code"

# Setup entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
EOF
    
    cat << 'EOF' > docker/entrypoint.sh
#!/bin/bash
set -e

# Source ROS2
source /opt/ros/humble/setup.bash

# Source workspace if built
if [ -f "/ros2_ws/install/setup.bash" ]; then
    source /ros2_ws/install/setup.bash
fi

# Print welcome message
echo "🤖 ROS2 Development Environment Ready!"
echo "======================================"
echo "ROS2 Distribution: $ROS_DISTRO"
echo "Workspace: /ros2_ws"
echo ""
echo "Available commands:"
echo "  ./ros2_dev.sh help     - Show all automation commands"
echo "  colcon build           - Build workspace"
echo "  ros2 pkg list          - List available packages"
echo ""

exec "$@"
EOF
    
    print_success "Created Docker configuration"
}

# Create GitHub workflows
create_github_workflows() {
    print_status "Creating GitHub Actions workflow..."
    
    cat << 'EOF' > .github/workflows/ros2_ci.yml
name: ROS2 CI/CD Pipeline

on:
  push:
    branches: [ main, develop, staging ]
  pull_request:
    branches: [ main, develop ]

env:
  ROS_DISTRO: humble

jobs:
  lint:
    name: Code Quality
    runs-on: ubuntu-22.04
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Check shell scripts
      run: |
        # Install shellcheck
        sudo apt-get update
        sudo apt-get install -y shellcheck
        
        # Check all shell scripts
        find . -name "*.sh" -exec shellcheck {} \; || echo "Shellcheck warnings found"

  build-and-test:
    name: Build and Test
    runs-on: ubuntu-22.04
    needs: lint
    strategy:
      matrix:
        package-type: [python, cpp, integration]
        
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup ROS2
      uses: ros-tooling/setup-ros@v0.7
      with:
        required-ros-distributions: ${{ env.ROS_DISTRO }}
        
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y \
          python3-colcon-common-extensions \
          python3-pytest \
          python3-pytest-cov \
          libgtest-dev \
          cmake
        
    - name: Create sample workspace
      run: |
        mkdir -p ~/ros2_ws/src
        echo "WORKSPACE_DIR=\"~/ros2_ws\"" > config/dev_config.sh
        echo "ROS_DISTRO=\"${{ env.ROS_DISTRO }}\"" >> config/dev_config.sh
        echo 'TEAM_MEMBERS=("ci")' >> config/dev_config.sh
        echo 'declare -A PACKAGES=()' >> config/dev_config.sh
        echo 'TEST_TIMEOUT=300' >> config/dev_config.sh
        echo 'MAX_PARALLEL_TESTS=2' >> config/dev_config.sh
        
    - name: Make scripts executable
      run: chmod +x *.sh scripts/*.sh
        
    - name: Validate setup
      run: ./setup_wizard.sh validate
        
    - name: Test automation scripts
      run: |
        source /opt/ros/${{ env.ROS_DISTRO }}/setup.bash
        
        # Test different components based on matrix
        case "${{ matrix.package-type }}" in
          "python")
            echo "Testing Python package creation"
            ./scripts/create_package.sh test_python_pkg python "Test Python package"
            ;;
          "cpp")
            echo "Testing C++ package creation"
            ./scripts/create_package.sh test_cpp_pkg cpp "Test C++ package"
            ;;
          "integration")
            echo "Testing integration workflows"
            ./scripts/branch_manager.sh help
            ./scripts/monitor.sh help
            ./scripts/ros2_tester.sh help
            ;;
        esac
        
    - name: Upload test results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: test-results-${{ matrix.package-type }}
        path: |
          reports/
          logs/

  docker-build:
    name: Docker Build Test
    runs-on: ubuntu-22.04
    needs: build-and-test
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Build Docker image
      run: |
        docker build -f docker/Dockerfile.ros2 -t ros2-automation-test .
        
    - name: Test Docker container
      run: |
        docker run --rm ros2-automation-test ros2 --version

  release:
    name: Create Release
    runs-on: ubuntu-22.04
    needs: [build-and-test, docker-build]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Generate release notes
      run: |
        echo "## 🚀 ROS2 Multi-Developer Automation" > release_notes.md
        echo "" >> release_notes.md
        echo "### Recent Changes" >> release_notes.md
        git log --oneline -10 >> release_notes.md
        
    - name: Create Release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: v${{ github.run_number }}
        release_name: Release v${{ github.run_number }}
        body_path: release_notes.md
        draft: false
        prerelease: false
EOF
    
    print_success "Created GitHub Actions workflow"
}

# Create documentation
create_documentation() {
    print_status "Creating documentation..."
    
    # Main README (already created, but add to docs)
    cat << 'EOF' > docs/CONTRIBUTING.md
# Contributing to ROS2 Multi-Developer Automation

Thank you for your interest in contributing! 🤖

## 🚀 Quick Start for Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test your changes: `./setup_wizard.sh validate`
5. Submit a pull request

## 🎯 Areas for Contribution

- **New ROS2 distributions** (Iron, Rolling, Jazzy)
- **Additional monitoring tools** and dashboards
- **IDE integrations** (VS Code, CLion, PyCharm)
- **Enhanced testing frameworks**
- **Documentation improvements**
- **Bug fixes and optimizations**
- **Platform support** (Windows, ARM architectures)

## 📝 Development Guidelines

- Follow existing code style and patterns
- Include tests for new functionality
- Update documentation for new features
- Test with multiple ROS2 distributions when possible
- Use descriptive commit messages
- Keep PRs focused and atomic

## 🧪 Testing Your Changes

```bash
# Validate your setup
./setup_wizard.sh validate

# Test core functionality
./ros2_dev.sh help
./scripts/branch_manager.sh help
./scripts/ros2_tester.sh help
./scripts/monitor.sh help

# Test package creation
./scripts/create_package.sh test_pkg python "Test package"
```

## 📋 Code Review Process

1. All PRs require review from maintainers
2. Automated tests must pass
3. Documentation must be updated
4. Breaking changes require discussion

## 🐛 Reporting Issues

- Use GitHub Issues for bug reports
- Include your ROS2 distribution and OS
- Provide minimal reproduction steps
- Include relevant log files
- Use issue templates when available

## 📖 Documentation

- Keep README.md updated
- Add examples for new features
- Update troubleshooting guide for common issues
- Include docstrings in scripts

## 🏆 Recognition

Contributors will be recognized in:
- README.md acknowledgments
- GitHub releases
- Project documentation

Thank you for making ROS2 development better for everyone! 🚀
EOF
    
    cat << 'EOF' > docs/TROUBLESHOOTING.md
# 🛠️ Troubleshooting Guide

Common issues and solutions for the ROS2 Multi-Developer Automation suite.

## 🔧 Installation Issues

### Permission Denied Errors
```bash
# Make all scripts executable
chmod +x *.sh scripts/*.sh docker/entrypoint.sh

# Or use the setup script
./consolidated_setup.sh
```

### ROS2 Not Found
```bash
# Source ROS2 environment
source /opt/ros/humble/setup.bash

# Add to shell profile for persistence
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# Verify ROS2 installation
ros2 --version
```

### Configuration Issues
```bash
# Reset configuration
./setup_wizard.sh reset

# Run interactive setup
./setup_wizard.sh setup

# Validate setup
./setup_wizard.sh validate
```

## 🚫 Runtime Issues

### Build Failures
```bash
# Clean workspace
cd ~/ros2_ws
rm -rf build/ install/ log/

# Rebuild with verbose output
colcon build --event-handlers console_direct+

# Check specific package
colcon build --packages-select package_name
```

### Test Failures
```bash
# Generate detailed test report
./scripts/ros2_tester.sh generate-report

# Test specific package
./scripts/ros2_tester.sh test-package package_name

# Setup test environment
./scripts/ros2_tester.sh setup-test-env
```

### Docker Issues
```bash
# Ensure Docker is running
docker --version
docker ps

# Rebuild Docker image
./ros2_dev.sh docker-build

# Check Docker permissions
sudo usermod -aG docker $USER
# Then logout and login again
```

## 📊 Monitoring Issues

### Dashboard Not Working
```bash
# Check if required tools are installed
which top
which git
which ros2

# Test monitoring components
./scripts/monitor.sh status
./scripts/monitor.sh resources
```

### Branch Manager Problems
```bash
# Check git configuration
git config --list
git remote -v

# Sync with develop
./scripts/branch_manager.sh sync-develop

# List all branches
./scripts/branch_manager.sh list-branches
```

## 🔍 Debugging Steps

### General Debugging
1. **Check logs**: Look in `logs/` directory
2. **Validate setup**: Run `./setup_wizard.sh validate`
3. **Check configuration**: Review `config/dev_config.sh`
4. **Test components**: Run individual scripts with `help`
5. **Check permissions**: Ensure scripts are executable

### Environment Issues
```bash
# Check ROS2 environment
echo $ROS_DISTRO
echo $AMENT_PREFIX_PATH

# Check workspace
ls -la ~/ros2_ws/

# Source everything
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash
```

### Performance Issues
```bash
# Check system resources
./scripts/monitor.sh resources

# Monitor real-time
./scripts/monitor.sh watch

# Check build performance
./scripts/monitor.sh performance
```

## 📋 System Requirements

### Minimum Requirements
- **OS**: Ubuntu 20.04+, macOS 11+, or Windows 10+ with WSL2
- **RAM**: 4GB (8GB recommended)
- **Storage**: 10GB free space
- **ROS2**: Humble, Iron, or Rolling
- **Python**: 3.8+
- **Git**: 2.25+

### Recommended Setup
- **RAM**: 16GB
- **Storage**: 50GB SSD
- **CPU**: 4+ cores
- **Docker**: For consistent environments

## 🆘 Getting Help

### Self-Help Resources
1. Run diagnostics: `./setup_wizard.sh validate`
2. Check this troubleshooting guide
3. Review configuration: `config/dev_config.sh`
4. Check GitHub Issues for similar problems

### Community Support
1. **GitHub Issues**: Report bugs and request features
2. **GitHub Discussions**: Ask questions and share tips
3. **ROS2 Community**: Get help with ROS2-specific issues

### Support Information to Include
When asking for help, please include:
- OS and version
- ROS2 distribution
- Error messages (full text)
- Steps to reproduce
- Configuration file (anonymized)
- Output of `./setup_wizard.sh validate`

## 🔄 Known Issues

### Issue: "colcon not found"
**Solution**: Install colcon
```bash
sudo apt install python3-colcon-common-extensions
```

### Issue: "Docker permission denied"
**Solution**: Add user to docker group
```bash
sudo usermod -aG docker $USER
# Logout and login again
```

### Issue: "Branch already exists"
**Solution**: Use different branch name or clean up
```bash
./scripts/branch_manager.sh cleanup-merged
```

### Issue: "Workspace not found"
**Solution**: Create workspace or update config
```bash
mkdir -p ~/ros2_ws/src
# Update WORKSPACE_DIR in config/dev_config.sh
```
EOF
    
    print_success "Created documentation files"
}

# Create example files
create_examples() {
    print_status "Creating example configurations..."
    
    cat << 'EOF' > examples/sample_config.sh
#!/bin/bash
# Sample Configurations for Different Team Sizes and Robot Types

# =============================================================================
# SMALL ROBOTICS TEAM (2-3 developers)
# =============================================================================
SMALL_TEAM_CONFIG() {
    TEAM_MEMBERS=("alice" "bob")
    declare -A PACKAGES=(
        ["robot_controller"]="cpp"
        ["sensor_processing"]="python"
        ["basic_navigation"]="cpp"
    )
    ROS_DISTRO="humble"
    WORKSPACE_DIR="~/small_robot_ws"
}

# =============================================================================
# MEDIUM AUTONOMOUS VEHICLE TEAM (4-8 developers)
# =============================================================================
MEDIUM_TEAM_CONFIG() {
    TEAM_MEMBERS=("alice" "bob" "charlie" "diana" "eve")
    declare -A PACKAGES=(
        ["vehicle_control"]="cpp"
        ["perception_camera"]="python"
        ["perception_lidar"]="cpp"
        ["path_planning"]="python"
        ["sensor_fusion"]="cpp"
        ["hmi_interface"]="python"
        ["simulation"]="python"
    )
    ROS_DISTRO="humble"
    WORKSPACE_DIR="~/autonomous_vehicle_ws"
    MAX_PARALLEL_TESTS=6
}

# =============================================================================
# LARGE INDUSTRIAL ROBOTICS TEAM (8+ developers)
# =============================================================================
LARGE_TEAM_CONFIG() {
    TEAM_MEMBERS=("alice" "bob" "charlie" "diana" "eve" "frank" "grace" "henry" "ivan" "julia")
    declare -A PACKAGES=(
        # Motion Control
        ["motion_controller"]="cpp"
        ["kinematics_solver"]="cpp"
        ["trajectory_planner"]="cpp"
        
        # Perception
        ["vision_processing"]="python"
        ["point_cloud_processing"]="cpp"
        ["object_detection"]="python"
        ["pose_estimation"]="cpp"
        
        # High-level Control
        ["task_planner"]="python"
        ["behavior_trees"]="cpp"
        ["safety_monitor"]="cpp"
        
        # User Interfaces
        ["operator_interface"]="python"
        ["diagnostic_tools"]="python"
        ["data_visualization"]="python"
        
        # Simulation & Testing
        ["gazebo_worlds"]="python"
        ["integration_tests"]="python"
        ["performance_benchmarks"]="cpp"
    )
    ROS_DISTRO="humble"
    WORKSPACE_DIR="~/industrial_robot_ws"
    MAX_PARALLEL_TESTS=8
    TEST_TIMEOUT=600  # 10 minutes for complex tests
}

# =============================================================================
# RESEARCH LAB CONFIGURATION (Multi-robot systems)
# =============================================================================
RESEARCH_TEAM_CONFIG() {
    TEAM_MEMBERS=("prof_smith" "phd_alice" "phd_bob" "master_charlie" "master_diana")
    declare -A PACKAGES=(
        ["multi_robot_coordination"]="python"
        ["swarm_algorithms"]="cpp"
        ["distributed_planning"]="python"
        ["communication_protocols"]="cpp"
        ["experimental_validation"]="python"
        ["data_collection"]="python"
        ["analysis_tools"]="python"
    )
    ROS_DISTRO="rolling"  # Research often uses latest
    WORKSPACE_DIR="~/research_ws"
    DOCKER_REGISTRY="lab.university.edu/robotics"
}

# =============================================================================
# STARTUP CONFIGURATION (Fast iteration, lean team)
# =============================================================================
STARTUP_TEAM_CONFIG() {
    TEAM_MEMBERS=("founder" "cto" "intern")
    declare -A PACKAGES=(
        ["mvp_controller"]="python"  # Fast prototyping
        ["basic_perception"]="python"
        ["simple_navigation"]="python"
        ["mobile_app_bridge"]="python"
    )
    ROS_DISTRO="humble"
    WORKSPACE_DIR="~/startup_ws"
    MAX_PARALLEL_TESTS=2  # Limited resources
}

# =============================================================================
# COPY CONFIGURATION TO YOUR PROJECT
# =============================================================================
# To use any of these configurations:
# 1. Choose the configuration that matches your team
# 2. Copy the relevant parts to your config/dev_config.sh
# 3. Customize as needed

echo "📝 Sample Configurations Available:"
echo "=================================="
echo "1. Small Team (2-3 developers)"
echo "2. Medium Team (4-8 developers) - Autonomous Vehicle"
echo "3. Large Team (8+ developers) - Industrial Robotics"
echo "4. Research Lab - Multi-robot Systems"
echo "5. Startup - Fast Iteration"
echo ""
echo "Copy the appropriate configuration to config/dev_config.sh"
EOF

    cat << 'EOF' > examples/workflows/example_workflow.md
# 🔄 Example Development Workflows

This document shows typical development workflows using the ROS2 Multi-Developer Automation suite.

## 🚀 Workflow 1: New Feature Development

### Scenario
Alice needs to implement obstacle avoidance for the navigation system.

### Steps

1. **Start Feature Development**
   ```bash
   # Create feature branch and setup environment
   ./ros2_dev.sh start-feature alice navigation obstacle-avoidance
   ```

2. **Develop the Feature**
   ```bash
   # Switch to the new branch (if not already)
   git checkout feature/alice/navigation/obstacle-avoidance
   
   # Create or modify packages
   ./ros2_dev.sh create-package obstacle_detector cpp "Obstacle detection for navigation"
   
   # Edit code, add algorithms, etc.
   code src/obstacle_detector/
   ```

3. **Test During Development**
   ```bash
   # Test specific package
   ./ros2_dev.sh test test-package obstacle_detector
   
   # Test all navigation-related packages
   ./ros2_dev.sh test test-cpp
   
   # Monitor system performance
   ./ros2_dev.sh monitor watch
   ```

4. **Integration and Completion**
   ```bash
   # Run full test suite
   ./ros2_dev.sh test test-all
   
   # Generate test report
   ./ros2_dev.sh test generate-report
   
   # Test and integrate when ready
   ./ros2_dev.sh test-and-integrate feature/alice/navigation/obstacle-avoidance
   ```

5. **Cleanup**
   ```bash
   # After feature is merged, clean up old branches
   ./ros2_dev.sh branch cleanup-merged
   ```

## 🧪 Workflow 2: Bug Fix and Hotfix

### Scenario
Critical bug found in production that needs immediate fix.

### Steps

1. **Create Hotfix Branch**
   ```bash
   # Create hotfix from main branch
   ./scripts/branch_manager.sh create-hotfix bob fix-memory-leak
   ```

2. **Quick Fix and Test**
   ```bash
   # Make the fix
   git add .
   git commit -m "hotfix: resolve memory leak in sensor processing"
   
   # Test the fix
   ./ros2_dev.sh test test-package sensor_processing
   ```

3. **Deploy Hotfix**
   ```bash
   # Merge to main
   git checkout main
   git merge --no-ff hotfix/bob/fix-memory-leak
   
   # Also merge to develop to keep branches in sync
   git checkout develop
   git merge --no-ff hotfix/bob/fix-memory-leak
   
   # Clean up
   git branch -d hotfix/bob/fix-memory-leak
   ```

## 🔄 Workflow 3: Team Collaboration

### Scenario
Multiple developers working on related features.

### Steps

1. **Coordinate Team Work**
   ```bash
   # Check what everyone is working on
   ./scripts/branch_manager.sh list-branches
   ./scripts/monitor.sh team
   ```

2. **Sync with Latest Changes**
   ```bash
   # Before starting new work, sync with develop
   ./scripts/branch_manager.sh sync-develop
   ```

3. **Create Related Features**
   ```bash
   # Alice works on perception
   ./ros2_dev.sh start-feature alice perception camera-calibration
   
   # Bob works on related sensor fusion
   ./ros2_dev.sh start-feature bob perception sensor-fusion
   ```

4. **Integration Testing**
   ```bash
   # Test features together on staging
   ./scripts/branch_manager.sh integrate feature/alice/perception/camera-calibration
   ./scripts/branch_manager.sh integrate feature/bob/perception/sensor-fusion
   
   # Run integration tests
   git checkout staging
   ./ros2_dev.sh test integration-test
   ```

## 📊 Workflow 4: Release Preparation

### Scenario
Preparing for a major release with multiple features.

### Steps

1. **Pre-Release Checks**
   ```bash
   # Run full pipeline
   ./ros2_dev.sh full-pipeline
   
   # Check all team activity
   ./scripts/monitor.sh team
   ./scripts/monitor.sh performance
   ```

2. **Final Testing**
   ```bash
   # Test in Docker environment for consistency
   ./ros2_dev.sh docker-build
   ./ros2_dev.sh docker-run
   
   # Inside Docker container:
   ./ros2_dev.sh test test-all
   ```

3. **Documentation and Cleanup**
   ```bash
   # Update documentation
   git add docs/
   git commit -m "docs: update for v2.0.0 release"
   
   # Clean up merged branches
   ./ros2_dev.sh branch cleanup-merged
   
   # Generate final report
   ./scripts/ros2_tester.sh generate-report
   ```

## 🏠 Workflow 5: New Team Member Onboarding

### Scenario
New developer joins the team and needs to get up to speed.

### Steps

1. **Environment Setup**
   ```bash
   # Clone repository
   git clone https://github.com/company/robot-project.git
   cd robot-project
   
   # Run interactive setup
   ./setup_wizard.sh setup
   ```

2. **Configuration**
   ```bash
   # Add new team member to config
   # Edit config/dev_config.sh:
   # TEAM_MEMBERS=("alice" "bob" "charlie" "new_member")
   
   # Validate setup
   ./setup_wizard.sh validate
   ```

3. **First Contribution**
   ```bash
   # Start with simple task
   ./ros2_dev.sh start-feature new_member documentation update-readme
   
   # Make changes
   git add README.md
   git commit -m "docs: update setup instructions"
   
   # Test the workflow
   ./ros2_dev.sh test-and-integrate feature/new_member/documentation/update-readme
   ```

## 🐳 Workflow 6: Docker Development

### Scenario
Ensuring consistent development environment across team.

### Steps

1. **Setup Docker Environment**
   ```bash
   # Build development image
   ./ros2_dev.sh docker-build
   ```

2. **Develop in Container**
   ```bash
   # Start container with current directory mounted
   ./ros2_dev.sh docker-run
   
   # Inside container, all tools are available:
   ./ros2_dev.sh help
   ./setup_wizard.sh validate
   ```

3. **Team Consistency**
   ```bash
   # All team members use same environment
   # Share Dockerfile updates through git
   git add docker/Dockerfile.ros2
   git commit -m "docker: add new development dependencies"
   ```

## 📈 Workflow 7: Continuous Monitoring

### Scenario
Ongoing monitoring of team productivity and system health.

### Steps

1. **Daily Monitoring**
   ```bash
   # Morning team check
   ./scripts/monitor.sh status
   ./scripts/monitor.sh team
   ```

2. **Real-time Dashboard**
   ```bash
   # Keep dashboard running during development
   ./scripts/monitor.sh watch
   ```

3. **Performance Reviews**
   ```bash
   # Weekly performance check
   ./scripts/monitor.sh performance
   
   # Generate comprehensive reports
   ./scripts/ros2_tester.sh generate-report
   ```

## 💡 Pro Tips

### Branch Naming Best Practices
- Features: `feature/member/component/short-description`
- Tests: `test/member/test-name`
- Hotfixes: `hotfix/member/issue-description`
- Experiments: `experiment/member/hypothesis-name`

### Testing Strategy
- Test early and often with `./ros2_dev.sh test test-package`
- Use integration tests before merging
- Generate reports for documentation
- Test in Docker for release preparation

### Team Coordination
- Check team activity regularly with `./scripts/monitor.sh team`
- Use descriptive commit messages
- Sync with develop before starting new features
- Clean up branches after merging

### Performance Optimization
- Monitor resource usage during development
- Use parallel testing for faster feedback
- Profile performance with monitoring tools
- Optimize Docker images for faster builds

## 🎯 Workflow Summary

The automation suite supports various development patterns:
- **Feature-driven development** with automated branch management
- **Test-driven development** with comprehensive testing tools
- **Continuous integration** with automated pipelines
- **Team collaboration** with monitoring and coordination tools
- **Docker-based development** for environment consistency

Choose the workflows that best fit your team's needs and customize the automation accordingly!
EOF

    print_success "Created example workflows and configurations"
}

# Create support files
create_support_files() {
    print_status "Creating support files..."
    
    # Create .gitignore
    cat << 'EOF' > .gitignore
# =============================================================================
# ROS2 Multi-Developer Automation - Git Ignore Rules
# =============================================================================

# ROS2 build artifacts
build/
install/
log/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
*.egg-info/
.pytest_cache/
*.pyc
*.pyo
*.pyd
.Python
pip-log.txt
pip-delete-this-directory.txt
.coverage
.coverage.*
htmlcov/
.tox/
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.git
.mypy_cache
.pytest_cache
.hypothesis

# C++
*.o
*.so
*.a
*.dylib
*.exe
*.out
*.app
*.dSYM/
*.su
*.idb
*.pdb

# IDE and Editor files
.vscode/
.idea/
*.swp
*.swo
*~
*.sublime-*
.DS_Store
Thumbs.db

# Logs and reports
logs/
*.log
reports/
test_report_*.html
*.xml

# Docker
.dockerignore

# Backup files
*.backup.*
*.bak
*.orig

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Temporary files
*.tmp
*.temp
.tmp/
.temp/

# Node modules (if any JavaScript tools are used)
node_modules/

# ROS specific
*.bag
*.db3

# Custom ignores for this project
config/dev_config.sh.backup.*
setup_wizard_backup_*

# Don't ignore template files
!config/dev_config.sh.template
!examples/
EOF

    # Create LICENSE
    cat << 'EOF' > LICENSE
MIT License

Copyright (c) 2024 ROS2 Multi-Developer Automation Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
    
    # Create CHANGELOG.md
    cat << 'EOF' > CHANGELOG.md
# 📝 Changelog

All notable changes to the ROS2 Multi-Developer Automation suite will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive automation suite for ROS2 multi-developer teams
- Interactive setup wizard with team configuration
- Branch management with automated naming conventions
- Multi-language testing support (Python/C++)
- Real-time development monitoring dashboard
- Package template generator with test scaffolding
- Docker-based development environments
- GitHub Actions CI/CD pipeline
- Comprehensive documentation and troubleshooting guides

## [1.0.0] - 2024-12-XX

### ✨ Added
- **Core Automation Scripts**
  - Main orchestrator (`ros2_dev.sh`) with unified command interface
  - Interactive setup wizard (`setup_wizard.sh`) for easy configuration
  - Branch manager with feature/test/hotfix workflows
  - Comprehensive testing automation for Python and C++ packages
  - Real-time monitoring and performance tracking
  - Package template generator with best practices

- **Development Environment**
  - Docker containerization for consistent development
  - Support for ROS2 Humble, Iron, and Rolling distributions
  - Cross-platform compatibility (Linux, macOS, Windows/WSL)
  - Pre-configured development tools and dependencies

- **Team Collaboration Features**
  - Automated branch creation with consistent naming
  - Team activity monitoring and reporting
  - Integration testing workflows
  - Performance metrics and build time tracking
  - Merge conflict prevention with automated syncing

- **Quality Assurance**
  - Multi-language test execution (pytest, gtest)
  - Code coverage reporting
  - Integration test automation
  - HTML test report generation
  - CI/CD pipeline with GitHub Actions

- **Documentation**
  - Comprehensive user guide with examples
  - Troubleshooting guide for common issues
  - Contributing guidelines for open source development
  - Example configurations for different team sizes
  - Detailed workflow documentation

### 🎯 Features
- Support for teams of 2-20+ developers
- Automated Git workflow management
- Real-time development dashboard
- Package template generation
- Performance monitoring and optimization
- Docker-based consistency across environments
- Extensible configuration system

### 📖 Documentation
- Complete setup and usage documentation
- Troubleshooting guide with common solutions
- Contributing guidelines for community development
- Example workflows for different team scenarios
- Configuration templates for various project types

### 🔧 Technical Details
- **Languages**: Bash scripting with Python/C++ package support
- **Dependencies**: ROS2, Git, Docker (optional), standard Unix tools
- **Platforms**: Ubuntu 20.04+, macOS 11+, Windows 10+ (WSL2)
- **Architecture**: Modular script-based architecture
- **Configuration**: YAML-free, shell-based configuration

---

## Legend
- ✨ **Added**: New features
- 🔄 **Changed**: Changes in existing functionality  
- 🐛 **Fixed**: Bug fixes
- ❌ **Removed**: Removed features
- 🔒 **Security**: Security improvements
- 📖 **Documentation**: Documentation changes
- 🎯 **Features**: Major feature additions
- 🔧 **Technical**: Technical improvements
EOF

    print_success "Created support files (.gitignore, LICENSE, CHANGELOG.md)"
}

# Set proper permissions
set_permissions() {
    print_status "Setting file permissions..."
    
    # Make all shell scripts executable
    chmod +x *.sh 2>/dev/null || true
    chmod +x scripts/*.sh 2>/dev/null || true
    chmod +x docker/entrypoint.sh 2>/dev/null || true
    
    # Make sure directories are accessible
    chmod 755 config scripts docker .github examples docs 2>/dev/null || true
    
    print_success "Set executable permissions on scripts"
}

# Setup git repository
setup_git_repository() {
    print_status "Setting up Git repository..."
    
    if [[ ! -d ".git" ]]; then
        print_status "Initializing Git repository..."
        git init
        git checkout -b main
        
        # Create basic branches
        git checkout -b develop
        git checkout -b staging
        git checkout main
        
        print_success "Git repository initialized with main, develop, and staging branches"
    else
        print_warning "Git repository already exists"
    fi
    
    # Add all files
    git add .
    
    # Create initial commit if no commits exist
    if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
        git commit -m "feat: initial release of ROS2 multi-developer automation suite

🤖 Complete automation system for ROS2 development teams

✨ Features:
- Branch management with automated workflows
- Multi-language testing support (Python/C++)
- Real-time monitoring and dashboard
- Docker development environments
- Package template generator
- CI/CD pipeline with GitHub Actions
- Interactive setup wizard
- Comprehensive documentation

🎯 Benefits:
- Eliminates branch chaos and merge conflicts
- Standardizes testing across languages
- Provides real-time team visibility
- Ensures consistent development environments
- Automates repetitive development tasks
- Scales from 2 to 20+ developers

📦 Includes:
- Main orchestrator (ros2_dev.sh)
- Interactive setup wizard
- Branch management automation
- Testing and monitoring tools
- Docker containerization
- GitHub Actions workflow
- Complete documentation

Ready to transform your ROS2 development workflow! 🚀"
        
        print_success "Created initial commit"
    else
        print_warning "Repository already has commits"
    fi
}

# Show completion message
show_completion_message() {
    echo ""
    print_header "🎉 ROS2 Multi-Developer Automation Setup Complete!"
    print_header "=================================================="
    echo ""
    
    print_success "Repository structure created successfully!"
    echo ""
    
    echo -e "${CYAN}📁 Created Files:${NC}"
    echo "  ✅ Main orchestrator (ros2_dev.sh)"
    echo "  ✅ Interactive setup wizard (setup_wizard.sh)"
    echo "  ✅ Configuration template (config/dev_config.sh)"
    echo "  ✅ Branch management (scripts/branch_manager.sh)"
    echo "  ✅ Testing automation (scripts/ros2_tester.sh)"
    echo "  ✅ Development monitoring (scripts/monitor.sh)"
    echo "  ✅ Package generator (scripts/create_package.sh)"
    echo "  ✅ Docker environment (docker/)"
    echo "  ✅ GitHub Actions workflow (.github/workflows/)"
    echo "  ✅ Comprehensive documentation (docs/)"
    echo "  ✅ Example configurations (examples/)"
    echo "  ✅ Support files (.gitignore, LICENSE, CHANGELOG.md)"
    echo ""
    
    echo -e "${CYAN}🚀 Next Steps:${NC}"
    echo "1. ${YELLOW}Configure your team:${NC}"
    echo "   ./setup_wizard.sh setup"
    echo ""
    echo "2. ${YELLOW}Validate installation:${NC}"
    echo "   ./setup_wizard.sh validate"
    echo ""
    echo "3. ${YELLOW}Create GitHub repository:${NC}"
    echo "   - Go to GitHub and create 'ros2-multi-dev-automation'"
    echo "   - Make it public for community sharing"
    echo "   - Add description: '🤖 Comprehensive automation suite for ROS2 teams'"
    echo ""
    echo "4. ${YELLOW}Push to GitHub:${NC}"
    echo "   git remote add origin https://github.com/YOUR_USERNAME/ros2-multi-dev-automation.git"
    echo "   git push -u origin main"
    echo "   git push origin develop"
    echo "   git push origin staging"
    echo ""
    echo "5. ${YELLOW}Start developing:${NC}"
    echo "   ./ros2_dev.sh start-feature alice navigation obstacle-avoidance"
    echo ""
    
    echo -e "${CYAN}📖 Quick Reference:${NC}"
    echo "  ./ros2_dev.sh help                    # Show all commands"
    echo "  ./scripts/monitor.sh status          # Check development status"
    echo "  ./scripts/branch_manager.sh list     # List all branches"
    echo "  ./ros2_dev.sh test test-all          # Run all tests"
    echo "  ./ros2_dev.sh docker-build           # Build Docker environment"
    echo "  ./scripts/monitor.sh watch           # Real-time dashboard"
    echo ""
    
    echo -e "${CYAN}🌟 Repository Features:${NC}"
    echo "  📋 Professional README with examples"
    echo "  🤝 Contributing guidelines"  
    echo "  🛠️  Comprehensive troubleshooting guide"
    echo "  📊 GitHub Actions CI/CD pipeline"
    echo "  🐳 Docker development environment"
    echo "  📈 Real-time monitoring dashboard"
    echo "  🧪 Multi-language testing automation"
    echo "  🌲 Intelligent branch management"
    echo "  📦 Package template generator"
    echo "  ⚙️  Extensible configuration system"
    echo ""
    
    echo -e "${GREEN}✨ Your ROS2 automation suite is ready to help teams worldwide!${NC}"
    echo -e "${PURPLE}🤖 Share it on GitHub to make ROS2 development better for everyone!${NC}"
    echo ""
    
    print_warning "Remember to:"
    echo "  - Update team member names in config/dev_config.sh"
    echo "  - Customize package configurations for your projects"  
    echo "  - Test the setup with ./setup_wizard.sh validate"
    echo "  - Share with the ROS2 community!"
    echo ""
}

# Run main function
main "$@"#!/bin/bash
# =============================================================================
# ROS2 Multi-Developer Automation - Complete Repository Setup Script
# This script creates the entire repository structure and all files
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

# Main setup function
main() {
    print_header "🚀 ROS2 Multi-Developer Automation - Complete Setup"
    print_header "===================================================="
    echo ""
    
    # Check if we're in the right directory
    if [[ ! "$(basename $(pwd))" == "ros2-multi-dev-automation" ]]; then
        print_error "Please run this script from the ros2-multi-dev-automation directory"
        exit 1
    fi
    
    print_status "Setting up complete repository structure..."
    
    # Create all directories
    create_directories
    
    # Create all files
    create_main_scripts
    create_config_files
    create_automation_scripts
    create_docker_files
    create_github_workflows
    create_documentation
    create_examples
    create_support_files
    
    # Set permissions
    set_permissions
    
    # Initialize git if needed
    setup_git_repository
    
    # Final instructions
    show_completion_message
}

# Create directory structure
create_directories() {
    print_status "Creating directory structure..."
    
    local dirs=(
        "config"
        "scripts" 
        "docker"
        ".github/workflows"
        "docs"
        "examples"
        "examples/workflows"
        "logs"
        "reports"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        print_success "Created directory: $dir"
    done
}

# Create main orchestrator scripts
create_main_scripts() {
    print_status "Creating main orchestrator scripts..."
    
    # Create ros2_dev.sh
    cat << 'EOF' > ros2_dev.sh
#!/bin/bash
# =============================================================================
# ROS2 Development Orchestrator - Main Entry Point
# =============================================================================

show_help() {
    echo "🤖 ROS2 Development Automation Suite"
    echo "===================================="
    echo ""
    echo "Available Commands:"
    echo ""
    echo "Branch Management:"
    echo "  ./ros2_dev.sh branch <command>     - Manage branches"
    echo ""
    echo "Testing:"
    echo "  ./ros2_dev.sh test <command>       - Run tests"
    echo ""
    echo "Environment:"
    echo "  ./ros2_dev.sh setup                - Initial setup"
    echo "  ./ros2_dev.sh docker-build         - Build Docker environment"
    echo "  ./ros2_dev.sh docker-run           - Run in Docker"
    echo ""
    echo "Workflow:"
    echo "  ./ros2_dev.sh start-feature <member> <component> <description>"
    echo "  ./ros2_dev.sh test-and-integrate <branch>"
    echo "  ./ros2_dev.sh full-pipeline        - Complete CI/CD pipeline"
    echo ""
    echo "Monitoring:"
    echo "  ./ros2_dev.sh monitor <command>    - Development monitoring"
    echo "  ./ros2_dev.sh status               - Quick status check"
    echo ""
    echo "Package Management:"
    echo "  ./ros2_dev.sh create-package <name> <lang> [description]"
    echo ""
    echo "Examples:"
    echo "  ./ros2_dev.sh start-feature alice navigation obstacle-avoidance"
    echo "  ./ros2_dev.sh test-and-integrate feature/alice/navigation/obstacle-avoidance"
    echo "  ./ros2_dev.sh branch list alice"
    echo "  ./ros2_dev.sh test test-all"
    echo "  ./ros2_dev.sh create-package my_controller cpp 'Robot controller'"
}

setup_environment() {
    echo "🔧 Setting up ROS2 development environment..."
    
    # Run the setup wizard
    ./setup_wizard.sh setup
    
    echo "✅ Environment setup complete!"
}

start_feature_workflow() {
    local member=$1
    local component=$2
    local description=$3
    
    if [[ -z "$member" || -z "$component" || -z "$description" ]]; then
        echo "❌ Missing parameters"
        echo "Usage: start-feature <member> <component> <description>"
        exit 1
    fi
    
    echo "🚀 Starting feature development workflow..."
    
    # Create feature branch
    ./scripts/branch_manager.sh create-feature "$member" "$component" "$description"
    
    # Setup test environment for this feature
    echo "Setting up test environment..."
    ./scripts/ros2_tester.sh setup-test-env
    
    echo ""
    echo "✅ Feature workflow started!"
    echo "📝 Your feature branch is ready for development"
    echo "🧪 Run tests with: ./ros2_dev.sh test test-package $component"
    echo "📊 Monitor with: ./ros2_dev.sh monitor watch"
}

test_and_integrate() {
    local branch=$1
    
    if [[ -z "$branch" ]]; then
        echo "❌ Branch name required"
        echo "Usage: test-and-integrate <branch>"
        exit 1
    fi
    
    echo "🔄 Testing and integrating branch: $branch"
    
    # Checkout the branch
    if ! git checkout "$branch"; then
        echo "❌ Failed to checkout branch: $branch"
        exit 1
    fi
    
    # Run tests
    echo "Running tests..."
    if ./scripts/ros2_tester.sh test-all; then
        echo "✅ Tests passed!"
        
        # Integrate to staging
        ./scripts/branch_manager.sh integrate "$branch"
        
        # Run integration tests on staging
        git checkout staging
        if ./scripts/ros2_tester.sh integration-test; then
            echo "✅ Integration tests passed!"
            echo "🎉 Branch ready for merge to develop"
        else
            echo "❌ Integration tests failed"
            exit 1
        fi
    else
        echo "❌ Tests failed - fix issues before integration"
        ./scripts/ros2_tester.sh generate-report
        exit 1
    fi
}

full_pipeline() {
    echo "🏭 Running full CI/CD pipeline..."
    
    # Step 1: Build and test everything
    echo "Step 1: Building and testing workspace..."
    if ! ./scripts/ros2_tester.sh test-all; then
        echo "❌ Build/test failed"
        ./scripts/ros2_tester.sh generate-report
        exit 1
    fi
    
    # Step 2: Run integration tests
    echo "Step 2: Integration tests..."
    if ! ./scripts/ros2_tester.sh integration-test; then
        echo "❌ Integration tests failed"
        exit 1
    fi
    
    # Step 3: Generate comprehensive report
    echo "Step 3: Generating reports..."
    ./scripts/ros2_tester.sh generate-report
    ./scripts/monitor.sh performance
    
    # Step 4: Clean up old branches
    echo "Step 4: Cleanup..."
    ./scripts/branch_manager.sh cleanup-merged
    
    echo "✅ Full pipeline completed successfully!"
    echo "📊 Check reports/ directory for detailed results"
}

quick_status() {
    echo "⚡ Quick Status Check"
    echo "===================="
    ./scripts/monitor.sh status
}

docker_build() {
    echo "🐳 Building Docker development environment..."
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker not found. Please install Docker first."
        exit 1
    fi
    
    docker build -f docker/Dockerfile.ros2 -t ros2-dev-env .
    echo "✅ Docker environment built successfully!"
    echo "💡 Run with: ./ros2_dev.sh docker-run"
}

docker_run() {
    echo "🐳 Running Docker development environment..."
    
    if ! docker images | grep -q "ros2-dev-env"; then
        echo "❌ Docker image not found. Building..."
        docker_build
    fi
    
    docker run -it --rm \
        -v $(pwd):/ros2_ws \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=$DISPLAY \
        --network host \
        --name ros2-dev-container \
        ros2-dev-env
}

create_package() {
    local name=$1
    local lang=$2
    local description=$3
    
    if [[ -z "$name" || -z "$lang" ]]; then
        echo "❌ Missing parameters"
        echo "Usage: create-package <name> <language> [description]"
        echo "Languages: cpp, python"
        exit 1
    fi
    
    ./scripts/create_package.sh "$name" "$lang" "$description"
}

# Main command dispatcher
case "$1" in
    "setup")
        setup_environment
        ;;
    "branch")
        shift
        ./scripts/branch_manager.sh "$@"
        ;;
    "test")
        shift
        ./scripts/ros2_tester.sh "$@"
        ;;
    "monitor")
        shift
        ./scripts/monitor.sh "$@"
        ;;
    "start-feature")
        start_feature_workflow "$2" "$3" "$4"
        ;;
    "test-and-integrate")
        test_and_integrate "$2"
        ;;
    "full-pipeline")
        full_pipeline
        ;;
    "status")
        quick_status
        ;;
    "docker-build")
        docker_build
        ;;
    "docker-run")
        docker_run
        ;;
    "create-package")
        create_package "$2" "$3" "$4"
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
EOF
    print_success "Created ros2_dev.sh"
    
    # Create setup_wizard.sh
    cat << 'EOF' > setup_wizard.sh
#!/bin/bash
# =============================================================================
# ROS2 Development Setup Wizard
# Interactive setup for the automation suite
# =============================================================================

setup_wizard() {
    echo "🧙‍♂️ ROS2 Development Setup Wizard"
    echo "===================================="
    echo ""
    echo "This wizard will help you configure the automation suite for your team."
    echo ""

    # Get basic information
    read -p "👥 Enter team member usernames (space-separated): " team_input
    read -p "🤖 ROS2 distribution (humble/iron/rolling) [humble]: " ros_distro
    read -p "📁 Workspace directory [~/ros2_ws]: " workspace_dir
    read -p "🐳 Docker registry (optional): " docker_registry

    # Set defaults
    ros_distro=${ros_distro:-humble}
    workspace_dir=${workspace_dir:-~/ros2_ws}

    # Convert team input to array format
    IFS=' ' read -ra TEAM_ARRAY <<< "$team_input"
    team_members_str="("
    for member in "${TEAM_ARRAY[@]}"; do
        team_members_str+="\"$member\" "
    done
    team_members_str+=")"

    echo ""
    echo "📦 Package Configuration"
    echo "Let's define your ROS2 packages and their primary languages."
    echo "Enter packages one by one (press Enter after each):"
    echo ""

    packages_str="declare -A PACKAGES=("
    while true; do
        read -p "Package name (or 'done' to finish): " pkg_name
        if [[ "$pkg_name" == "done" ]]; then
            break
        fi
        
        echo "Languages: cpp, python"
        read -p "Primary language for $pkg_name: " pkg_lang
        
        packages_str+="\n    [\"$pkg_name\"]=\"$pkg_lang\""
    done
    packages_str+="\n)"

    # Generate configuration file
    cat << EOF > config/dev_config.sh
#!/bin/bash
# Development Configuration - Generated by Setup Wizard

# Repository settings
MAIN_BRANCH="main"
DEVELOP_BRANCH="develop"
STAGING_BRANCH="staging"

# ROS2 settings
ROS_DISTRO="$ros_distro"
WORKSPACE_DIR="$workspace_dir"

# Team members
TEAM_MEMBERS=$team_members_str

# Component packages
$packages_str

# Docker settings
DOCKER_IMAGE="ros:\${ROS_DISTRO}-desktop"
CONTAINER_PREFIX="ros2_dev"
$(if [[ -n "$docker_registry" ]]; then echo "DOCKER_REGISTRY=\"$docker_registry\""; fi)

# Testing settings
TEST_TIMEOUT=300  # 5 minutes
MAX_PARALLEL_TESTS=4
EOF

    echo ""
    echo "✅ Configuration generated!"
    echo ""
    
    # Create workspace if it doesn't exist
    if [[ ! -d "$workspace_dir" ]]; then
        read -p "📁 Create workspace directory $workspace_dir? (y/N): " create_ws
        if [[ "$create_ws" == [yY] ]]; then
            mkdir -p "$workspace_dir/src"
            echo "✅ Workspace created: $workspace_dir"
        fi
    fi

    # Git repository setup
    if [[ ! -d ".git" ]]; then
        read -p "📋 Initialize Git repository? (y/N): " init_git
        if [[ "$init_git" == [yY] ]]; then
            git init
            git checkout -b main
            echo "✅ Git repository initialized"
        fi
    fi

    echo ""
    echo "🔧 Additional Setup Options"
    echo ""

    # Docker setup
    read -p "🐳 Build Docker development environment? (y/N): " build_docker
    if [[ "$build_docker" == [yY] ]]; then
        ./ros2_dev.sh docker-build
    fi

    # Create sample packages
    read -p "📦 Create sample packages for testing? (y/N): " create_samples
    if [[ "$create_samples" == [yY] ]]; then
        echo "Creating sample packages..."
        ./scripts/create_package.sh sample_navigation cpp "Sample navigation package"
        ./scripts/create_package.sh sample_sensors python "Sample sensor processing package"
        echo "✅ Sample packages created"
    fi

    echo ""
    echo "🎉 Setup Complete!"
    echo "=================="
    echo ""
    echo "Your ROS2 development environment is ready!"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Review and customize config/dev_config.sh if needed"
    echo "2. Create your first feature branch:"
    echo "   ./ros2_dev.sh start-feature <member> <component> <description>"
    echo "3. Monitor your development:"
    echo "   ./ros2_dev.sh monitor status"
    echo "4. Create packages as needed:"
    echo "   ./ros2_dev.sh create-package <name> <cpp|python>"
    echo ""
    echo "📖 Documentation:"
    echo "  - Run any script with 'help' for detailed usage"
    echo "  - Use './ros2_dev.sh monitor watch' for real-time dashboard"
    echo "  - All automation commands: './ros2_dev.sh help'"
}

validate_setup() {
    echo "🔍 Validating ROS2 Development Setup"
    echo "====================================="
    echo ""

    local errors=0
    local warnings=0

    # Check configuration file
    if [[ -f "config/dev_config.sh" ]]; then
        echo "✅ Configuration file exists"
        source config/dev_config.sh
        
        # Validate configuration
        if [[ ${#TEAM_MEMBERS[@]} -eq 0 ]]; then
            echo "⚠️  Warning: No team members configured"
            ((warnings++))
        else
            echo "✅ Team members configured: ${#TEAM_MEMBERS[@]}"
        fi
        
        if [[ ${#PACKAGES[@]} -eq 0 ]]; then
            echo "⚠️  Warning: No packages configured"
            ((warnings++))
        else
            echo "✅ Packages configured: ${#PACKAGES[@]}"
        fi
        
        # Check workspace
        if [[ -d "$WORKSPACE_DIR" ]]; then
            echo "✅ Workspace directory exists: $WORKSPACE_DIR"
        else
            echo "❌ Workspace directory missing: $WORKSPACE_DIR"
            ((errors++))
        fi
    else
        echo "❌ Configuration file missing: config/dev_config.sh"
        echo "💡 Run: $0 setup"
        ((errors++))
    fi

    # Check scripts
    echo ""
    echo "📜 Checking scripts..."
    local scripts=("scripts/branch_manager.sh" "scripts/ros2_tester.sh" "scripts/monitor.sh" "scripts/create_package.sh")
    for script in "${scripts[@]}"; do
        if [[ -f "$script" && -x "$script" ]]; then
            echo "✅ $script"
        else
            echo "❌ $script (missing or not executable)"
            ((errors++))
        fi
    done

    # Check ROS2 installation
    echo ""
    echo "🤖 Checking ROS2..."
    if command -v ros2 > /dev/null; then
        echo "✅ ROS2 command available"
        local ros_version=$(ros2 --version 2>/dev/null | head -1)
        echo "   Version: $ros_version"
    else
        echo "⚠️  Warning: ROS2 not found in PATH"
        echo "💡 Make sure to source ROS2 setup: source /opt/ros/humble/setup.bash"
        ((warnings++))
    fi

    # Check development tools
    echo ""
    echo "🔧 Checking development tools..."
    local tools=("git" "docker")
    for tool in "${tools[@]}"; do
        if command -v "$tool" > /dev/null; then
            echo "✅ $tool available"
        else
            echo "⚠️  Warning: $tool not found"
            ((warnings++))
        fi
    done

    # Summary
    echo ""
    echo "📊 Validation Summary"
    echo "===================="
    if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
        echo "🎉 Perfect! Everything is set up correctly."
    elif [[ $errors -eq 0 ]]; then
        echo "✅ Setup is functional with $warnings warnings."
        echo "💡 Address warnings for optimal experience."
    else
        echo "❌ Setup has $errors errors and $warnings warnings."
        echo "🔧 Fix errors before proceeding."
        return 1
    fi
    
    echo ""
    echo "🚀 Ready to start development!"
    echo "Run: ./ros2_dev.sh help"
}

show_help() {
    echo "🧙‍♂️ ROS2 Development Setup Wizard"
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup          - Interactive setup wizard"
    echo "  validate       - Validate current setup"
    echo "  reset          - Reset configuration to defaults"
    echo "  help           - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 setup       # Run interactive setup"
    echo "  $0 validate    # Check if everything is configured correctly"
}

reset_setup() {
    echo "🔄 Resetting ROS2 Development Setup"
    echo "===================================="
    echo ""
    echo "⚠️  This will reset your configuration to defaults."
    echo "Your source code and git history will NOT be affected."
    echo ""
    read -p "Are you sure you want to reset? (y/N): " confirm
    
    if [[ "$confirm" != [yY] ]]; then
        echo "❌ Reset cancelled"
        return 0
    fi
    
    # Backup existing config
    if [[ -f "config/dev_config.sh" ]]; then
        cp config/dev_config.sh "config/dev_config.sh.backup.$(date +%Y%m%d_%H%M%S)"
        echo "📁 Backed up existing config"
    fi
    
    # Reset to default configuration
    cp config/dev_config.sh.template config/dev_config.sh 2>/dev/null || {
        echo "⚠️  Template not found, creating default config"
        ./setup_wizard.sh setup
    }
    
    echo "✅ Configuration reset"
    echo "💡 Run: $0 setup to reconfigure interactively"
}

# Main script execution
case "${1:-setup}" in
    "setup")
        setup_wizard
        ;;
    "validate")
        validate_setup
        ;;
    "reset")
        reset_setup
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
EOF
    print_success "Created setup_wizard.sh"
}

# Create configuration files
create_config_files() {
    print_status "Creating configuration files..."
    
    # Create main config template
    cat << 'EOF' > config/dev_config.sh
#!/bin/bash
# Development Configuration Template
# Customize this file for your team and project

# Repository settings
MAIN_BRANCH="main"
DEVELOP_BRANCH="develop"
STAGING_BRANCH="staging"

# ROS2 settings
ROS_DISTRO="humble"  # humble, iron, rolling
WORKSPACE_DIR="~/ros2_ws"

# Team members - Add your team member usernames
TEAM_MEMBERS=("developer1" "developer2" "developer3")

# Component packages - Define your ROS2 packages and primary language
declare -A PACKAGES=(
    ["navigation"]="cpp"
    ["perception"]="python"
    ["control"]="cpp"
    ["planning"]="python"
    ["sensors"]="cpp"
    ["ui"]="python"
)

# Docker settings
DOCKER_IMAGE="ros:${ROS_DISTRO}-desktop"
CONTAINER_PREFIX="ros2_dev"

# Testing settings
TEST_TIMEOUT=300  # 5 minutes
MAX_PARALLEL_TESTS=4

# Optional settings
# DOCKER_REGISTRY="your-registry.com"
# SLACK_WEBHOOK_URL="https://hooks.slack.com/..."
# NOTIFICATION_EMAIL="team@company.com"
EOF
    
    # Create config template backup
    cp config/dev_config.sh config/dev_config.sh.template
    
    print_success "Created configuration files"
}

# Create automation scripts
create_automation_scripts() {
    print_status "Creating automation scripts..."
    
    # Create scripts/branch_manager.sh
    cat << 'EOF' > scripts/branch_manager.sh
#!/bin/bash
# =============================================================================
# ROS2 Branch Manager - Git Workflow Automation
# =============================================================================

# Source configuration
if [[ -f "config/dev_config.sh" ]]; then
    source config/dev_config.sh
else
    echo "❌ Configuration file not found: config/dev_config.sh"
    echo "💡 Run: ./setup_wizard.sh setup"
    exit 1
fi

show_help() {
    echo "🌲 ROS2 Branch Manager"
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  create-feature <member> <component> <description>  - Create feature branch"
    echo "  create-test <member> <test-name>                   - Create test branch"
    echo "  create-hotfix <member> <issue-description>         - Create hotfix branch"
    echo "  list-branches [member]                             - List branches"
    echo "  cleanup-merged                                     - Clean up merged branches"
    echo "  sync-develop                                       - Sync with develop branch"
    echo "  integrate <feature-branch>                         - Integrate to staging"
    echo "  status                                             - Show branch status"
    echo ""
    echo "Examples:"
    echo "  $0 create-feature alice navigation obstacle-avoidance"
    echo "  $0 create-test bob lidar-integration"
    echo "  $0 create-hotfix charlie fix-memory-leak"
    echo "  $0 integrate feature/alice/navigation/obstacle-avoidance"
    echo "  $0 list-branches alice"
}

create_feature_branch() {
    local member=$1
    local component=$2
    local description=$3
    
    if [[ -z "$member" || -z "$component" || -z "$description" ]]; then
        echo "❌ Missing parameters for feature branch creation"
        echo "Usage: create-feature <member> <component> <description>"
        return 1
    fi
    
    local branch_name="feature/${member}/${component}/${description}"
    
    echo "🌱 Creating feature branch: $branch_name"
    
    # Switch to develop and pull latest
    git checkout $DEVELOP_BRANCH 2>/dev/null || {
        echo "📝 Creating develop branch"
        git checkout -b $DEVELOP_BRANCH
    }
    git pull origin $DEVELOP_BRANCH 2>/dev/null || echo "💡 No remote origin configured"
    
    # Create and switch to new branch
    git checkout -b "$branch_name"
    git push -u origin "$branch_name" 2>/dev/null || echo "💡 Branch created locally (no remote)"
    
    echo "✅ Feature branch '$branch_name' created"
    echo ""
    echo "📝 Next steps:"
    echo "   - Start coding your feature"
    echo "   - Add tests: ./ros2_dev.sh test test-package $component"
    echo "   - Monitor progress: ./ros2_dev.sh monitor status"
    echo "   - When ready: ./ros2_dev.sh test-and-integrate $branch_name"
}

create_test_branch() {
    local member=$1
    local test_name=$2
    
    if [[ -z "$member" || -z "$test_name" ]]; then
        echo "❌ Missing parameters for test branch creation"
        echo "Usage: create-test <member> <test-name>"
        return 1
    fi
    
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local branch_name="test/${member}/${test_name}-${timestamp}"
    
    echo "🧪 Creating test branch: $branch_name"
    
    git checkout $DEVELOP_BRANCH 2>/dev/null || git checkout -b $DEVELOP_BRANCH
    git pull origin $DEVELOP_BRANCH 2>/dev/null || echo "💡 No remote origin configured"
    git checkout -b "$branch_name"
    git push -u origin "$branch_name" 2>/dev/null || echo "💡 Branch created locally (no remote)"
    
    echo "✅ Test branch '$branch_name' created"
    echo "⚠️  This is a temporary branch - it will be cleaned up after testing"
}

create_hotfix_branch() {
    local member=$1
    local description=$2
    
    if [[ -z "$member" || -z "$description" ]]; then
        echo "❌ Missing parameters for hotfix branch creation"
        echo "Usage: create-hotfix <member> <issue-description>"
        return 1
    fi
    
    local branch_name="hotfix/${member}/${description}"
    
    echo "🚨 Creating hotfix branch: $branch_name"
    
    # Hotfixes branch from main
    git checkout $MAIN_BRANCH
    git pull origin $MAIN_BRANCH 2>/dev/null || echo "💡 No remote origin configured"
    git checkout -b "$branch_name"
    git push -u origin "$branch_name" 2>/dev/null || echo "💡 Branch created locally (no remote)"
    
    echo "✅ Hotfix branch '$branch_name' created"
    echo "🚨 Remember: Hotfixes should be merged to both main and develop"
}

list_branches() {
    local member_filter=$1
    
    echo "🌲 Branch Status Report"
    echo "======================="
    echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    echo "Repository: $(git remote get-url origin 2>/dev/null || echo 'local only')"
    echo ""
    
    if [[ -n "$member_filter" ]]; then
        echo "📋 Branches for: $member_filter"
        git branch -a 2>/dev/null | grep "$member_filter" | sort | sed 's/^/  /'
    else
        echo "📋 All development branches:"
        git branch -a 2>/dev/null | grep -E "(feature|test|hotfix)/" | sort | sed 's/^/  /'
    fi
    
    echo ""
    echo "👥 Team Activity Summary:"
    for member in "${TEAM_MEMBERS[@]}"; do
        local count=$(git branch -a 2>/dev/null | grep -c "$member" || echo "0")
        local last_commit=$(git log --author="$member" --oneline -1 --since="7 days ago" 2>/dev/null | head -1 || echo "")
        if [[ -n "$last_commit" ]]; then
            echo "  $member: $count branches (recent: ${last_commit:0:50}...)"
        else
            echo "  $member: $count branches (no recent activity)"
        fi
    done
}

show_branch_status() {
    echo "📊 Detailed Branch Status"
    echo "========================="
    
    # Current branch info
    local current_branch=$(git branch --show-current 2>/dev/null || echo 'unknown')
    local last_commit=$(git log -1 --pretty=format:'%h - %s (%cr)' 2>/dev/null || echo 'No commits')
    local uncommitted=$(git status --porcelain 2>/dev/null | wc -l || echo '0')
    
    echo "Current branch: $current_branch"
    echo "Last commit: $last_commit"
    echo "Uncommitted changes: $uncommitted files"
    echo ""
    
    # Branch comparison
    if git show-ref --verify --quiet refs/heads/$DEVELOP_BRANCH; then
        local ahead=$(git rev-list --count HEAD..$DEVELOP_BRANCH 2>/dev/null || echo '0')
        local behind=$(git rev-list --count $DEVELOP_BRANCH..HEAD 2>/dev/null || echo '0')
        echo "Compared to develop: $ahead commits ahead, $behind commits behind"
    fi
    
    # Recent activity
    echo ""
    echo "📈 Recent Activity (last 5 commits):"
    git log --oneline -5 2>/dev/null | sed 's/^/  /' || echo "  No commit history"
}

cleanup_merged_branches() {
    echo "🧹 Cleaning up merged branches..."
    
    # Get list of merged branches (excluding main branches)
    local merged_branches=$(git branch --merged $MAIN_BRANCH 2>/dev/null | \
                           grep -v -E "(${MAIN_BRANCH}|${DEVELOP_BRANCH}|${STAGING_BRANCH})" | \
                           sed 's/^[ *]*//' | xargs)
    
    if [[ -z "$merged_branches" ]]; then
        echo "✅ No merged branches to clean up"
        return 0
    fi
    
    echo "Found merged branches:"
    for branch in $merged_branches; do
        echo "  📎 $branch"
    done
    echo ""
    
    read -p "Delete these branches? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        for branch in $merged_branches; do
            git branch -d "$branch" && echo "  ✅ Deleted: $branch"
            # Also delete remote branch if it exists
            git push origin --delete "$branch" 2>/dev/null && echo "     🌐 Deleted remote: $branch"
        done
        echo ""
        echo "✅ Cleanup complete"
    else
        echo "❌ Cleanup cancelled"
    fi
}

sync_develop() {
    echo "🔄 Syncing with develop branch..."
    
    local current_branch=$(git branch --show-current)
    
    # Update develop branch
    git checkout $DEVELOP_BRANCH 2>/dev/null || git checkout -b $DEVELOP_BRANCH
    git pull origin $DEVELOP_BRANCH 2>/dev/null || echo "💡 No remote origin configured"
    
    # Return to original branch and rebase if different
    if [[ "$current_branch" != "$DEVELOP_BRANCH" && "$current_branch" != "" ]]; then
        git checkout "$current_branch"
        echo "🔄 Rebasing current branch on develop..."
        if git rebase $DEVELOP_BRANCH; then
            echo "✅ Rebase successful"
        else
            echo "⚠️  Rebase conflicts detected"
            echo "💡 Resolve conflicts and run: git rebase --continue"
            return 1
        fi
    fi
    
    echo "✅ Sync complete"
}

integrate_branch() {
    local feature_branch=$1
    
    if [[ -z "$feature_branch" ]]; then
        echo "❌ No branch specified for integration"
        echo "Usage: integrate <feature-branch>"
        return 1
    fi
    
    echo "🔄 Integrating $feature_branch to staging..."
    
    # Verify branch exists
    if ! git show-ref --verify --quiet "refs/heads/$feature_branch"; then
        echo "❌ Branch not found: $feature_branch"
        return 1
    fi
    
    # Switch to staging and update
    git checkout $STAGING_BRANCH 2>/dev/null || {
        echo "📝 Creating staging branch"
        git checkout -b $STAGING_BRANCH
    }
    git pull origin $STAGING_BRANCH 2>/dev/null || echo "💡 No remote origin configured"
    
    # Merge feature branch
    if git merge --no-ff "$feature_branch" -m "Integrate: $feature_branch"; then
        echo "✅ Integration successful"
        
        # Push to staging
        git push origin $STAGING_BRANCH 2>/dev/null || echo "💡 Integrated locally (no remote)"
        
        echo ""
        echo "✅ Integration complete"
        echo "🧪 Next steps:"
        echo "   - Run integration tests: ./ros2_dev.sh test integration-test"
        echo "   - If tests pass, merge to develop"
        echo "   - Clean up feature branch when done"
    else
        echo "❌ Integration failed - resolve conflicts"
        return 1
    fi
}

# Main command dispatcher
case "$1" in
    "create-feature")
        create_feature_branch "$2" "$3" "$4"
        ;;
    "create-test")
        create_test_branch "$2" "$3"
        ;;
    "create-hotfix")
        create_hotfix_branch "$2" "$3"
        ;;
    "list-branches"|"list")
        list_branches "$2"
        ;;
    "status")
        show_branch_status
        ;;
    "cleanup-merged"|"cleanup")
        cleanup_merged_branches
        ;;
    "sync-develop"|"sync")
        sync_develop
        ;;
    "integrate")
        integrate_branch "$2"
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        show_help
        exit 1
        ;;
esac
EOF
    print_success "Created scripts/branch_manager.sh"
    
    # Continue with remaining automation scripts...
    # (Due to length constraints, I'll create the essential files and provide instructions for the rest)
    
    # Create scripts/ros2_tester.sh (essential testing script)
    cat << 'EOF' > scripts/ros2_tester.sh
#!/bin/bash
# =============================================================================
# ROS2 Testing Automation - Multi-language Test Runner
# =============================================================================

# Source configuration
if [[ -f "config/dev_config.sh" ]]; then
    source config/dev_config.sh
else
    echo "❌ Configuration file not found: config/dev_config.sh"
    echo "💡 Run: ./setup_wizard.sh setup"
    exit 1
fi

show_help() {
    echo "🧪 ROS2 Testing Automation"
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  test-package <package>     - Test specific package"
    echo "  test-all                   - Test all packages"
    echo "  test-python                - Test only Python packages"
    echo "  test-cpp                   - Test only C++ packages"
    echo "  integration-test           - Run integration tests"
    echo "  setup-test-env             - Setup testing environment"
    echo "  generate-report            - Generate HTML test report"
    echo "  coverage                   - Generate code coverage report"
    echo ""
    echo "Examples:"
    echo "  $0 test-all                # Test everything"
    echo "  $0 test-package navigation # Test specific package"
    echo "  $0 generate-report         # Create HTML report"
}

setup_ros2_env() {
    echo "🔧 Setting up ROS2 environment..."
    
    # Source ROS2
    if [[ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
        source /opt/ros/${ROS_DISTRO}/setup.bash
        echo "✅ ROS2 ${ROS_DISTRO} sourced"
    else
        echo "❌ ROS2 ${ROS_DISTRO} not found"
        echo "💡 Install ROS2 or update ROS_DISTRO in config/dev_config.sh"
        return 1
    fi
    
    # Source workspace if it exists
    if [[ -f "${WORKSPACE_DIR}/install/setup.bash" ]]; then
        source ${WORKSPACE_DIR}/install/setup.bash
        echo "✅ Workspace environment loaded"
    fi
    
    return 0
}

build_workspace() {
    echo "🔨 Building ROS2 workspace..."
    
    # Expand workspace directory
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    
    if [[ ! -d "$expanded_workspace_dir" ]]; then
        echo "❌ Workspace directory not found: $expanded_workspace_dir"
        echo "💡 Create workspace or update WORKSPACE_DIR in config"
        return 1
    fi
    
    cd "$expanded_workspace_dir"
    
    # Clean previous build if requested
    if [[ "$1" == "--clean" ]]; then
        echo "🧹 Cleaning previous build..."
        rm -rf build/ install/ log/
    fi
    
    # Build with colcon
    echo "🔨 Building packages..."
    if colcon build \
        --cmake-args -DCMAKE_BUILD_TYPE=Debug \
        --parallel-workers $MAX_PARALLEL_TESTS \
        --event-handlers console_direct+; then
        
        echo "✅ Build successful"
        source install/setup.bash
        return 0
    else
        echo "❌ Build failed"
        echo "📄 Check build logs in log/ directory"
        return 1
    fi
}

test_package() {
    local package_name=$1
    
    if [[ -z "$package_name" ]]; then
        echo "❌ Package name required"
        echo "Usage: test-package <package>"
        return 1
    fi
    
    echo "🧪 Testing package: $package_name"
    
    if ! setup_ros2_env; then
        return 1
    fi
    
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    cd "$expanded_workspace_dir"
    
    # Build the specific package first
    echo "🔨 Building $package_name..."
    if ! colcon build --packages-select "$package_name"; then
        echo "❌ Build failed for $package_name"
        return 1
    fi
    
    source install/setup.bash
    
    # Run tests
    echo "🧪 Running tests for $package_name..."
    if colcon test --packages-select "$package_name" --event-handlers console_direct+; then
        echo "✅ Tests passed for $package_name"
        
        # Show test results
        colcon test-result --verbose --test-result-base "build/$package_name" 2>/dev/null || {
            echo "📊 Test results:"
            find "build/$package_name" -name "*.xml" -path "*/test_results/*" 2>/dev/null | head -5
        }
        
        return 0
    else
        echo "❌ Tests failed for $package_name"
        echo "📄 Check test logs in build/$package_name/test_results/"
        return 1
    fi
}

test_all_packages() {
    echo "🧪 Testing all packages..."
    
    if ! setup_ros2_env; then
        return 1
    fi
    
    if ! build_workspace; then
        return 1
    fi
    
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    cd "$expanded_workspace_dir"
    
    # Run all tests
    echo "🧪 Running all tests..."
    if colcon test --event-handlers console_direct+; then
        echo ""
        echo "📊 Test Summary:"
        echo "================"
        
        colcon test-result --all --verbose 2>/dev/null || {
            echo "Test results available in build/*/test_results/"
            find build -name "*.xml" -path "*/test_results/*" 2>/dev/null | wc -l | \
            xargs -I {} echo "Found {} test result files"
        }
        
        echo "✅ All tests completed"
        return 0
    else
        echo "❌ Some tests failed"
        echo "📄 Check individual test logs in build/*/test_results/"
        return 1
    fi
}

test_by_language() {
    local language=$1
    echo "🧪 Testing $language packages..."
    
    if ! setup_ros2_env; then
        return 1
    fi
    
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    cd "$expanded_workspace_dir"
    
    local packages_to_test=()
    
    # Find packages of specified language
    for package in "${!PACKAGES[@]}"; do
        if [[ "${PACKAGES[$package]}" == "$language" ]]; then
            packages_to_test+=("$package")
        fi
    done
    
    if [[ ${#packages_to_test[@]} -eq 0 ]]; then
        echo "⚠️  No $language packages found in configuration"
        echo "💡 Update PACKAGES in config/dev_config.sh"
        return 0
    fi
    
    echo "📦 Testing $language packages: ${packages_to_test[*]}"
    
    # Build packages
    if colcon build --packages-select "${packages_to_test[@]}"; then
        source install/setup.bash
        
        # Test packages
        if colcon test --packages-select "${packages_to_test[@]}" --event-handlers console_direct+; then
            echo "✅ All $language packages tested successfully"
            return 0
        else
            echo "❌ Some $language package tests failed"
            return 1
        fi
    else
        echo "❌ Build failed for $language packages"
        return 1
    fi
}

integration_test() {
    echo "🔗 Running integration tests..."
    
    if ! setup_ros2_env; then
        return 1
    fi
    
    if ! build_workspace; then
        return 1
    fi
    
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    cd "$expanded_workspace_dir"
    
    # Look for integration test launch files
    local integration_launches=$(find . -name "*integration*" -name "*.launch.py" 2>/dev/null | head -1)
    
    if [[ -n "$integration_launches" ]]; then
        echo "🚀 Running integration launch file: $integration_launches"
        timeout $TEST_TIMEOUT ros2 launch "$integration_launches"
        local result=$?
        
        if [[ $result -eq 0 ]]; then
            echo "✅ Integration tests passed"
        elif [[ $result -eq 124 ]]; then
            echo "⏰ Integration tests timed out after ${TEST_TIMEOUT}s"
            echo "💡 Increase TEST_TIMEOUT or optimize tests"
        else
            echo "❌ Integration tests failed"
        fi
        
        return $result
    else
        echo "✅ Integration test placeholder completed"
        echo "💡 Create integration test launch files in your packages"
        echo "💡 Example: src/*/launch/*integration*.launch.py"
        return 0
    fi
}

setup_test_environment() {
    echo "🔧 Setting up test environment..."
    
    # Create directory structure
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    mkdir -p "$expanded_workspace_dir/src"
    mkdir -p logs/tests
    mkdir -p reports
    
    # Install testing dependencies (if on Ubuntu/Debian)
    if command -v apt &> /dev/null; then
        echo "📦 Installing test dependencies..."
        sudo apt update -qq
        sudo apt install -y python3-pytest python3-pytest-cov libgtest-dev cmake 2>/dev/null || {
            echo "⚠️  Could not install some dependencies (may require manual installation)"
        }
    fi
    
    echo "✅ Test environment setup complete"
    echo "💡 Workspace: $expanded_workspace_dir"
}

generate_test_report() {
    echo "📊 Generating comprehensive test report..."
    
    local report_file="reports/test_report_$(date +%Y%m%d_%H%M%S).html"
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    
    mkdir -p reports
    
    # Create HTML report
    cat << 'REPORT_EOF' > "$report_file"
<!DOCTYPE html>
<html>
<head>
    <title>ROS2 Test Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background: #f5f7fa; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px; margin-bottom: 30px; }
        .header h1 { margin: 0; font-size: 2.5em; }
        .header p { margin: 5px 0; opacity: 0.9; }
        .section { background: white; margin: 20px 0; padding: 25px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .section h2 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .stat-card { background: #f8f9fa; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #3498db; }
        .stat-number { font-size: 2em; font-weight: bold; color: #2c3e50; }
        .stat-label { color: #7f8c8d; margin-top: 5px; }
        .pass { color: #27ae60; }
        .fail { color: #e74c3c; }
        .warning { color: #f39c12; }
        .package-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 15px; }
        .package-card { border: 1px solid #ddd; border-radius: 8px; padding: 15px; }
        .package-card.pass { border-left: 4px solid #27ae60; }
        .package-card.fail { border-left: 4px solid #e74c3c; }
        .package-card.warning { border-left: 4px solid #f39c12; }
        .timestamp { color: #7f8c8d; font-size: 0.9em; }
        .footer { text-align: center; margin-top: 40px; color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 ROS2 Test Report</h1>
            <p>Generated: $(date)</p>
            <p>Branch: $(git branch --show-current 2>/dev/null || echo "unknown")</p>
            <p>Commit: $(git rev-parse --short HEAD 2>/dev/null || echo "unknown")</p>
            <p>Workspace: $expanded_workspace_dir</p>
        </div>
REPORT_EOF

    # Add test statistics
    echo '        <div class="section">' >> "$report_file"
    echo '            <h2>📊 Test Statistics</h2>' >> "$report_file"
    echo '            <div class="stats">' >> "$report_file"
    
    # Count packages
    local total_packages=${#PACKAGES[@]}
    echo "                <div class=\"stat-card\">" >> "$report_file"
    echo "                    <div class=\"stat-number\">$total_packages</div>" >> "$report_file"
    echo "                    <div class=\"stat-label\">Total Packages</div>" >> "$report_file"
    echo "                </div>" >> "$report_file"
    
    # Count test files
    local test_files=0
    if [[ -d "$expanded_workspace_dir/build" ]]; then
        test_files=$(find "$expanded_workspace_dir/build" -name "*.xml" -path "*/test_results/*" 2>/dev/null | wc -l)
    fi
    echo "                <div class=\"stat-card\">" >> "$report_file"
    echo "                    <div class=\"stat-number\">$test_files</div>" >> "$report_file"
    echo "                    <div class=\"stat-label\">Test Result Files</div>" >> "$report_file"
    echo "                </div>" >> "$report_file"
    
    echo '            </div>' >> "$report_file"
    echo '        </div>' >> "$report_file"
    
    # Add package details
    echo '        <div class="section">' >> "$report_file"
    echo '            <h2>📦 Package Details</h2>' >> "$report_file"
    echo '            <div class="package-list">' >> "$report_file"
    
    for package in "${!PACKAGES[@]}"; do
        local status="warning"
        local status_text="Not tested"
        
        if [[ -d "$expanded_workspace_dir/src/$package" ]]; then
            status="pass"
            status_text="Found"
        else
            status="fail"
            status_text="Missing"
        fi
        
        echo "                <div class=\"package-card $status\">" >> "$report_file"
        echo "                    <h3>$package</h3>" >> "$report_file"
        echo "                    <p><strong>Language:</strong> ${PACKAGES[$package]}</p>" >> "$report_file"
        echo "                    <p><strong>Status:</strong> <span class=\"$status\">$status_text</span></p>" >> "$report_file"
        echo "                </div>" >> "$report_file"
    done
    
    echo '            </div>' >> "$report_file"
    echo '        </div>' >> "$report_file"
    
    # Add recent commits
    echo '        <div class="section">' >> "$report_file"
    echo '            <h2>📈 Recent Development Activity</h2>' >> "$report_file"
    echo '            <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; font-family: monospace;">' >> "$report_file"
    git log --oneline -5 2>/dev/null | sed 's/^/                /' | sed 's/$/<br>/' >> "$report_file" || echo "                No git history available<br>" >> "$report_file"
    echo '            </div>' >> "$report_file"
    echo '        </div>' >> "$report_file"
    
    # Close HTML
    echo '        <div class="footer">' >> "$report_file"
    echo '            <p>Generated by ROS2 Multi-Developer Automation Suite</p>' >> "$report_file"
    echo '            <p class="timestamp">Report created: $(date)</p>' >> "$report_file"
    echo '        </div>' >> "$report_file"
    echo '    </div>' >> "$report_file"
    echo '</body>' >> "$report_file"
    echo '</html>' >> "$report_file"
    
    echo "✅ Test report generated: $report_file"
    
    # Try to open in browser
    if command -v open &> /dev/null; then
        open "$report_file"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$report_file"
    else
        echo "💡 Open $report_file in your web browser to view the report"
    fi
}

# Main command dispatcher
case "$1" in
    "test-package")
        test_package "$2"
        ;;
    "test-all")
        test_all_packages
        ;;
    "test-python")
        test_by_language "python"
        ;;
    "test-cpp")
        test_by_language "cpp"
        ;;
    "integration-test")
        integration_test
        ;;
    "setup-test-env")
        setup_test_environment
        ;;
    "generate-report")
        generate_test_report
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        show_help
        exit 1
        ;;
esac
EOF
    print_success "Created scripts/ros2_tester.sh"
    
    # Create remaining essential scripts (abbreviated for space)
    create_remaining_scripts
}

create_remaining_scripts() {
    # Create scripts/monitor.sh (essential monitoring)
    cat << 'EOF' > scripts/monitor.sh
#!/bin/bash
# =============================================================================
# ROS2 Development Monitor - Status and Performance Tracking
# =============================================================================

# Source configuration
if [[ -f "config/dev_config.sh" ]]; then
    source config/dev_config.sh
else
    echo "❌ Configuration file not found: config/dev_config.sh"
    exit 1
fi

show_help() {
    echo "📊 ROS2 Development Monitor"
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  status           - Show development status overview"
    echo "  logs             - Show recent logs and activity"
    echo "  resources        - Show system resource usage"
    echo "  performance      - Show performance metrics"
    echo "  watch            - Real-time monitoring dashboard"
    echo "  team             - Show team activity summary"
    echo ""
    echo "Examples:"
    echo "  $0 status        # Quick status overview"
    echo "  $0 watch         # Real-time dashboard"
    echo "  $0 team          # Team activity report"
}

show_status() {
    echo "🤖 ROS2 Development Status Overview"
    echo "==================================="
    echo ""
    
    # Git status
    echo "📋 Repository Status:"
    echo "  Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    echo "  Last commit: $(git log -1 --pretty=format:'%h - %s (%cr)' 2>/dev/null || echo 'No commits')"
    echo "  Uncommitted changes: $(git status --porcelain 2>/dev/null | wc -l || echo '0') files"
    echo ""
    
    # Team activity
    echo "👥 Team Activity (last 7 days):"
    for member in "${TEAM_MEMBERS[@]}"; do
        local commits=$(git log --author="$member" --oneline --since="7 days ago" 2>/dev/null | wc -l || echo "0")
        local branches=$(git branch -a 2>/dev/null | grep -c "$member" || echo "0")
        echo "  $member: $commits commits, $branches branches"
    done
    echo ""
    
    # Package status
    echo "📦 Package Configuration:"
    echo "  Total packages: ${#PACKAGES[@]}"
    for package in "${!PACKAGES[@]}"; do
        local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
        if [[ -d "$expanded_workspace_dir/src/$package" ]]; then
            echo "  ✅ $package (${PACKAGES[$package]})"
        else
            echo "  ❌ $package (${PACKAGES[$package]}) - missing"
        fi
    done
    echo ""
    
    # Build status
    echo "🔨 Build Status:"
    local expanded_workspace_dir="${WORKSPACE_DIR/#\~/$HOME}"
    if [[ -d "$expanded_workspace_dir/build" ]]; then
        local build_dirs=$(find "$expanded_workspace_dir/build" -maxdepth 1 -type d 2>/dev/null | wc -l)
        echo "  Build directory exists with $build_dirs entries"
        
        local error_logs=$(find "$expanded_workspace_dir/build" -name "*.log" -exec grep -l "error:" {} \; 2>/dev/null | wc -l)
        if [[ $error_logs -gt 0 ]]; then
            echo "  ⚠️  $error_logs packages have build errors"
        else
            echo "  ✅ No build errors detected"
        fi
    else
        echo "  No build directory found"
    fi
}

watch_dashboard() {
    echo "📊 Real-time Development Dashboard"
    echo "Press Ctrl+C to exit"
    echo "=================================="
    
    while true; do
        clear
        echo "🤖 ROS2 Development Dashboard - $(date)"
        echo "========================================="
        echo ""
        
        # Quick status
        echo "📋 Current Status:"
        echo "  Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
        echo "  Workspace: ${WORKSPACE_DIR}"
        echo "  ROS2 Distribution: ${ROS_DISTRO}"
        echo ""
        
        # System resources
        echo "💻 System Resources:"
        if command -v top &> /dev/null; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                local cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' 2>/dev/null || echo "N/A")
                echo "  CPU: $cpu_usage"
            else
                # Linux
                local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "N/A")
                echo "  CPU: ${cpu_usage}%"
            fi
        fi
        
        local disk_usage=$(df -h . 2>/dev/null | tail -1 | awk '{print $5}' || echo "N/A")
        echo "  Disk: $disk_usage used"
        echo ""
        
        # Recent activity
        echo "📝 Recent Activity:"
        git log --oneline -3 2>/dev/null | sed 's/^/  /' || echo "  No recent commits"
        echo ""
        
        # ROS2 status
        echo "🤖 ROS2 Status:"
        if command -v ros2 &> /dev/null && pgrep -f ros2 > /dev/null; then
            local node_count=$(ros2 node list 2>/dev/null | wc -l || echo "0")
            echo "  Active nodes: $node_count"
        else
            echo "  ROS2 not running"
        fi
        
        sleep 5
    done
}

show_team_activity() {
    echo "👥 Team Activity Report"
    echo "======================="
    echo ""
    
    for member in "${TEAM_MEMBERS[@]}"; do
        echo "👤 $member:"
        
        # Recent commits
        local recent_commits=$(git log --author="$member" --oneline --since="7 days ago" 2>/dev/null | wc -l || echo "0")
        echo "  📝 Commits (7 days): $recent_commits"
        