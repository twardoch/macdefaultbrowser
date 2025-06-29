# TODO: macdefaultbrowser

## Phase 1: Foundation (Immediate Priority)

### Testing Infrastructure
- [ ] Add unit tests for LaunchServicesWrapper with mocked APIs
- [ ] Add unit tests for DialogAutomation AppleScript generation
- [ ] Add unit tests for Version module and git tag parsing
- [ ] Create integration tests for complete workflow
- [ ] Add tests for error handling and edge cases
- [ ] Achieve 80%+ code coverage

### Bug Fixes & Stability
- [ ] Fix potential memory leaks in Core Foundation bridging
- [ ] Add retry logic for transient Launch Services failures
- [ ] Improve error messages with actionable recovery suggestions
- [ ] Handle edge case when no browsers are installed

### Distribution
- [ ] Create official homebrew-tap repository
- [ ] Update Homebrew formula with correct SHA256 after releases
- [ ] Set up automatic bottle generation for Homebrew
- [ ] Create installation verification script

### Documentation
- [ ] Create man page for `macdefaultbrowser`
- [ ] Add `--verbose` flag with detailed logging
- [ ] Document all command-line options and environment variables
- [ ] Add troubleshooting guide to README

## Phase 2: Enhancement (Short-term)

### Performance Optimization
- [ ] Cache browser information to reduce API calls
- [ ] Implement single-scan browser detection
- [ ] Profile and optimize startup time
- [ ] Add performance benchmarks to test suite

### User Experience
- [ ] Add progress indicators during browser scanning
- [ ] Implement colored output for better readability
- [ ] Add `--quiet` mode for scripting
- [ ] Show elapsed time for operations in verbose mode

### Configuration Support
- [ ] Add support for config file at `~/.config/macdefaultbrowser/config.json`
- [ ] Allow browser name aliases in configuration
- [ ] Support custom dialog automation timeouts
- [ ] Add `--config` flag to specify custom config path

### Code Quality
- [ ] Refactor AppleScript generation to use type-safe builder
- [ ] Create comprehensive error type hierarchy
- [ ] Add SwiftLint configuration and fix all warnings
- [ ] Implement dependency injection for better testability

## Phase 3: Expansion (Medium-term)

### Interactive Features
- [ ] Add interactive mode with menu-based browser selection
- [ ] Implement tab completion for browser names
- [ ] Add confirmation prompts for browser changes
- [ ] Create wizard mode for first-time users

### Auto-update System
- [ ] Implement version checking against GitHub releases
- [ ] Add `--check-update` command
- [ ] Add `--update` command for self-updating
- [ ] Show update notifications when available

### Alternative Installation
- [ ] Create standalone .pkg installer with GUI
- [ ] Add MacPorts portfile
- [ ] Create curl-based installation script
- [ ] Build universal binary for all architectures

### Localization
- [ ] Extract all user-facing strings for localization
- [ ] Add support for system language detection
- [ ] Translate to major languages (es, fr, de, ja, zh)
- [ ] Support localized browser names

## Phase 4: Advanced Features (Long-term)

### GUI Components
- [ ] Create menu bar application for quick browser switching
- [ ] Design preferences window for configuration
- [ ] Add system tray notifications
- [ ] Implement drag-and-drop browser selection

### Advanced Integration
- [ ] Add Shortcuts.app actions
- [ ] Create AppleScript dictionary
- [ ] Support URL scheme for automation
- [ ] Add support for browser profiles/workspaces

### Enterprise Features
- [ ] Add MDM configuration profile support
- [ ] Implement logging for compliance
- [ ] Create deployment guide for IT administrators
- [ ] Add group policy support

### Developer Tools
- [ ] Generate API documentation with DocC
- [ ] Create Swift package for library usage
- [ ] Add example projects
- [ ] Set up documentation hosting

## Completed Tasks

### Building ✅
- [x] Fix GitHub Actions build failure (Version.swift.template)
- [x] Fix deprecation warnings with NSWorkspace APIs
- [x] Add version generation from git tags
- [x] Implement help and version flags

### Distribution ✅
- [x] Create Homebrew formula template
- [x] Add code signing support to Makefile
- [x] Implement notarization scripts
- [x] Set up GitHub Actions for releases

### Documentation ✅
- [x] Write comprehensive README
- [x] Create code signing documentation
- [x] Document Homebrew installation process
- [x] Add build and installation instructions

## Notes

- Priority should be given to Phase 1 tasks to ensure a stable foundation
- Each phase should be completed before moving to the next
- Regular releases should be made after completing significant features
- All changes should maintain backward compatibility
- Performance benchmarks should be run before each release
