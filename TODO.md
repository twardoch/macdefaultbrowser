# TODO: macdefaultbrowser

### 0.1. Building

- [x] `issues/101.txt` read and fix - Added Version.swift.template to git repository

### 0.2. Distribution

- [x] Update Homebrew formula with correct SHA256 after first release - Created update script and documentation
- [ ] Submit to homebrew-core or create custom tap - Formula ready, needs tap repository
- [x] Add code signing for distribution outside App Store - Added to Makefile with documentation
- [x] Consider notarization for enhanced security - Added scripts and GitHub Actions support

### 0.3. Testing

- [ ] Create integration tests for dialog automation
- [ ] Test on Intel Macs (currently tested on Apple Silicon)
- [ ] Add CI tests for different macOS versions


### 0.4. Documentation

- [ ] Add license headers to all source files
- [ ] Document accessibility permissions requirements in README
- [ ] Create troubleshooting guide for common issues

### 0.5. Code Quality

- [ ] Address deprecated API warnings (migrate to NSWorkspace methods)
- [ ] Add more comprehensive error messages
- [ ] Improve test coverage
