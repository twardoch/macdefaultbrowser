# TODO: macdefaultbrowser

### 0.1. Building

- [x] `issues/101.txt` read and fix - Added Version.swift.template to git repository
- [x] Fix deprecation warnings - Updated LaunchServicesWrapper to use modern NSWorkspace APIs on macOS 12.0+ with fallback to deprecated APIs for older versions

### 0.2. Distribution

- [x] Update Homebrew formula with correct SHA256 after first release - Created update script and documentation
- [ ] Submit to homebrew-core or create custom tap - Formula ready, needs tap repository
- [x] Add code signing for distribution outside App Store - Added to Makefile with documentation
- [x] Consider notarization for enhanced security - Added scripts and GitHub Actions support

### 0.3. Testing

- [ ] Comprehensive test suite for BrowserManager
- [ ] Integration tests with multiple browsers
- [ ] Test dialog automation functionality  
- [ ] Cross-platform compatibility testing
- [ ] Performance benchmarking

### 0.4. Documentation

- [ ] Update README with usage examples
- [ ] Create man page for CLI tool
- [ ] Document dialog automation setup
- [ ] Add troubleshooting guide

### 0.5. Future Features

- [ ] GUI version consideration
- [ ] Additional browser metadata display
- [ ] Batch operations support
- [ ] Configuration file support
