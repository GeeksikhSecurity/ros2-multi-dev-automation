# 🤖 ROS2 Multi-Developer Automation Suite

A comprehensive automation system for managing ROS2 development across multiple team members working with both Python and C++ code.

## 🚀 Quick Start

1. **Initial Setup**
   ```bash
   # Run the interactive setup wizard
   chmod +x setup_wizard.sh
   ./setup_wizard.sh setup
   ```

2. **Start Development**
   ```bash
   # Create a feature branch
   ./ros2_dev.sh start-feature alice navigation obstacle-avoidance
   
   # Create a new package
   ./scripts/create_package.sh my_controller cpp "Robot controller package"
   
   # Run tests
   ./ros2_dev.sh test test-all
   ```

3. **Monitor Progress**
   ```bash
   # Real-time dashboard
   ./scripts/monitor.sh watch
   
   # Check status
   ./scripts/monitor.sh status
   ```

## 📁 Project Structure

```
├── ros2_dev.sh                    # Main orchestrator script
├── setup_wizard.sh                # Interactive setup wizard
├── config/
│   └── dev_config.sh              # Team and project configuration
├── scripts/
│   ├── branch_manager.sh          # Git workflow automation
│   ├── ros2_tester.sh             # Testing automation
│   ├── create_package.sh          # Package template generator
│   └── monitor.sh                 # Development monitoring
├── docker/
│   ├── Dockerfile.ros2            # Development container
│   └── entrypoint.sh              # Container entry point
├── .github/workflows/
│   └── ros2_ci.yml                # CI/CD pipeline
└── README.md                      # This file
```

## 🎯 Key Features

### Branch Management
- **Automated branch creation** with consistent naming conventions
- **Feature branches**: `feature/member/component/description`
- **Test branches**: `test/member/test-name-timestamp`
- **Integration workflow** through staging branches
- **Automatic cleanup** of merged branches

### Testing Automation
- **Multi-language support** for Python and C++ packages
- **Parallel test execution** with configurable worker count
- **Integration testing** with launch file automation
- **Test reporting** with HTML output
- **Performance metrics** and build time tracking

### Development Monitoring
- **Real-time dashboard** showing system status
- **Resource usage monitoring** (CPU, memory, disk)
- **ROS2 node and topic monitoring**
- **Git activity tracking** per team member
- **Build and test status reporting**

### Package Management
- **Template-based package creation** for Python and C++
- **Automated test file generation** with proper structure
- **Launch file templates** with parameter configuration
- **Package dependency management**

### Containerization
- **Docker environment** for consistent development
- **Pre-configured ROS2 containers** with all tools
- **Volume mounting** for live code editing
- **Cross-platform compatibility**

## 📋 Available Commands

### Main Orchestrator (`./ros2_dev.sh`)

```bash
# Branch Management
./ros2_dev.sh branch create-feature <member> <component> <description>
./ros2_dev.sh branch list [member]
./ros2_dev.sh branch cleanup-merged

# Testing
./ros2_dev.sh test test-all
./ros2_dev.sh test test-package <package>
./ros2_dev.sh test integration-test

# Workflows
./ros2_dev.sh start-feature <member> <component> <description>
./ros2_dev.sh test-and-integrate <branch>
./ros2_dev.sh full-pipeline

# Environment
./ros2_dev.sh docker-build
./ros2_dev.sh docker-run
```

### Branch Manager (`./scripts/branch_manager.sh`)

```bash
# Create branches
./scripts/branch_manager.sh create-feature alice navigation obstacle-avoidance
./scripts/branch_manager.sh create-test bob lidar-integration

# List and manage
./scripts/branch_manager.sh list-branches [member]
./scripts/branch_manager.sh sync-develop
./scripts/branch_manager.sh integrate <feature-branch>
./scripts/branch_manager.sh cleanup-merged
```

### Testing (`./scripts/ros2_tester.sh`)

```bash
# Test execution
./scripts/ros2_tester.sh test-all
./scripts/ros2_tester.sh test-package <package>
./scripts/ros2_tester.sh test-python
./scripts/ros2_tester.sh test-cpp
./scripts/ros2_tester.sh integration-test

# Environment and reporting
./scripts/ros2_tester.sh setup-test-env
./scripts/ros2_tester.sh generate-report
```

### Package Creation (`./scripts/create_package.sh`)

```bash
# Create packages
./scripts/create_package.sh my_navigation cpp "Navigation algorithms"
./scripts/create_package.sh sensor_fusion python "Multi-sensor data fusion"
```

### Monitoring (`./scripts/monitor.sh`)

```bash
# Status and monitoring
./scripts/monitor.sh status           # Development overview
./scripts/monitor.sh logs             # Recent logs and activity
./scripts/monitor.sh resources        # System resource usage
./scripts/monitor.sh performance      # Performance metrics
./scripts/monitor.sh watch           # Real-time dashboard

# ROS2 specific
./scripts/monitor.sh node-graph       # ROS2 node visualization
./scripts/monitor.sh topics           # Topic monitoring
```

## ⚙️ Configuration

### Team Configuration (`config/dev_config.sh`)

```bash
# Team members
TEAM_MEMBERS=("alice" "bob" "charlie" "diana")

# ROS2 packages and primary languages
declare -A PACKAGES=(
    ["navigation"]="cpp"
    ["perception"]="python"
    ["control"]="cpp"
    ["planning"]="python"
    ["sensors"]="cpp"
    ["ui"]="python"
)

# ROS2 settings
ROS_DISTRO="humble"
WORKSPACE_DIR="~/ros2_ws"

# Testing settings
TEST_TIMEOUT=300
MAX_PARALLEL_TESTS=4
```

## 🐳 Docker Usage

### Build Development Environment
```bash
./ros2_dev.sh docker-build
```

### Run in Container
```bash
./ros2_dev.sh docker-run
```

### Custom Docker Setup
The Docker environment includes:
- ROS2 Humble (configurable)
- Development tools (colcon, pytest, gtest)
- Pre-configured workspace
- X11 forwarding for GUI applications

## 🔄 Development Workflow

### 1. Start New Feature
```bash
# Create feature branch and setup environment
./ros2_dev.sh start-feature alice navigation obstacle-avoidance
```

### 2. Develop Code
- Edit your packages in the workspace
- Use provided templates for new packages
- Follow ROS2 best practices

### 3. Test Changes
```bash
# Test specific package
./ros2_dev.sh test test-package navigation

# Test all packages
./ros2_dev.sh test test-all

# Run integration tests
./ros2_dev.sh test integration-test
```

### 4. Monitor Progress
```bash
# Check overall status
./scripts/monitor.sh status

# Real-time monitoring
./scripts/monitor.sh watch
```

### 5. Integrate Changes
```bash
# Test and integrate to staging
./ros2_dev.sh test-and-integrate feature/alice/navigation/obstacle-avoidance
```

### 6. Clean Up
```bash
# Remove merged branches
./ros2_dev.sh branch cleanup-merged
```

## 🧪 Testing Strategy

### Unit Tests
- **Python packages**: pytest with automatic discovery
- **C++ packages**: Google Test framework
- **Automated generation** of test templates

### Integration Tests
- **Launch file based** testing
- **Multi-node communication** verification
- **System-level** behavior validation

### Performance Tests
- **Build time** tracking
- **Test execution** timing
- **Resource usage** monitoring

### Continuous Integration
- **GitHub Actions** workflow
- **Multi-matrix** testing (Python/C++)
- **Automated reporting**

## 📊 Monitoring and Reporting

### Real-time Dashboard
```bash
./scripts/monitor.sh watch
```
Shows:
- Current branch and commit
- System resources (CPU, RAM)
- Active ROS2 nodes and topics
- Recent git activity

### Status Reports
```bash
./scripts/monitor.sh status
```
Provides:
- Git repository status
- Team member activity
- Package build status
- Test results summary

### Performance Metrics
```bash
./scripts/monitor.sh performance
```
Includes:
- Build times per package
- Test execution times
- Development velocity metrics
- Resource usage trends

## 🛠️ Troubleshooting

### Common Issues

**Build Failures**
```bash
# Check build logs
./scripts/monitor.sh logs

# Clean rebuild
cd $WORKSPACE_DIR
rm -rf build/ install/ log/
colcon build
```

**Test Failures**
```bash
# Generate detailed test report
./scripts/ros2_tester.sh generate-report

# Check specific package
./scripts/ros2_tester.sh test-package <package_name>
```

**Branch Conflicts**
```bash
# Sync with develop
./scripts/branch_manager.sh sync-develop

# Check branch status
./scripts/branch_manager.sh list-branches
```

**Environment Issues**
```bash
# Validate setup
./setup_wizard.sh validate

# Reset configuration
./setup_wizard.sh reset
```

### Log Locations
- Build logs: `$WORKSPACE_DIR/log/`
- Test results: `$WORKSPACE_DIR/build/*/test_results/`
- ROS2 logs: `~/.ros/log/`
- Custom logs: `logs/`

## 🤝 Contributing

### Adding New Team Members
1. Update `TEAM_MEMBERS` in `config/dev_config.sh`
2. Ensure they have access to the repository
3. Run setup wizard for their environment

### Adding New Packages
1. Update `PACKAGES` in `config/dev_config.sh`
2. Create package: `./scripts/create_package.sh <n> <lang>`
3. Update CI/CD pipeline if needed

### Customizing Workflows
- Modify scripts in `scripts/` directory
- Update configuration in `config/dev_config.sh`
- Customize Docker environment in `docker/`

## 📚 Best Practices

### Branch Naming
- Features: `feature/member/component/description`
- Tests: `test/member/test-name`
- Hotfixes: `hotfix/member/issue-description`

### Commit Messages
- Use conventional commits format
- Include component prefix: `navigation: add obstacle avoidance`
- Reference issues: `fixes #123`

### Testing
- Write tests for all new functionality
- Run tests before creating pull requests
- Include integration tests for complex features

### Code Organization
- One package per major component
- Consistent coding style per language
- Comprehensive documentation

## 📖 Additional Resources

### ROS2 Documentation
- [ROS2 Official Docs](https://docs.ros.org/)
- [Colcon Documentation](https://colcon.readthedocs.io/)
- [ROS2 Testing Guide](https://docs.ros.org/en/humble/Tutorials/Intermediate/Testing/Testing-Main.html)

### Development Tools
- [pytest Documentation](https://docs.pytest.org/)
- [Google Test Guide](https://google.github.io/googletest/)
- [Docker ROS](https://hub.docker.com/_/ros)

### Git Workflows
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)

## 🆘 Support

For issues or questions:
1. Check the [troubleshooting guide](docs/TROUBLESHOOTING.md)
2. Run diagnostics: `./setup_wizard.sh validate`
3. Check logs: `./scripts/monitor.sh logs`
4. Review configuration: `config/dev_config.sh`
5. Open an issue on GitHub

## 📄 License

This automation suite is provided under the MIT License. See [LICENSE](LICENSE) for details.

## ⭐ Star This Repository

If this automation suite helps your ROS2 development team, please give it a star! It helps others discover the project.

---

**Made with ❤️ for the ROS2 community**
