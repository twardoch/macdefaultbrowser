# TODO: macdefaultbrowser

### 0.1. Building

- [x] The builds should go into the `build/` folder, not into the root folder of the repo
- [x] `make dist` should in the `dist` folder create an installable .pkg and then a .dmg with the .pkg inside. The .pkg should install the binary into `/usr/local/bin`
- [x] Ensure that the distributable .dmg is uploaded to the Github release artifacts on tag-based release

### 0.2. Distribution

- [ ] Update Homebrew formula with correct SHA256 after first release
- [ ] Submit to homebrew-core or create custom tap
- [ ] Add code signing for distribution outside App Store
- [ ] Consider notarization for enhanced security

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
