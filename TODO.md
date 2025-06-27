# TODO: Swift Port of macdefaultbrowser

- Read `CLEANUP.md` and perform the maintenance tasks. 

## 1. Overview

This document outlines the detailed plan for porting the Objective-C implementation ( `reference/src/main.m` ) to Swift while incorporating the dialog automation functionality from `reference/good.sh` .

## 2. Project Structure

### 2.1. Create Swift Package Structure

- [ ] Create `Package.swift` file with proper package definition
- [ ] Create `Sources/macdefaultbrowser/` directory structure
- [ ] Create `main.swift` as the entry point
- [ ] Create separate modules for:
  - `BrowserManager.swift` - Core browser management logic
  - `DialogAutomation.swift` - System dialog automation
  - `LaunchServicesWrapper.swift` - Swift wrapper for Launch Services API

### 2.2. Core Implementation Tasks

#### 2.2.1. Launch Services API Wrapper

- [ ] Create Swift-friendly wrapper for Launch Services functions:
  - `LSCopyAllHandlersForURLScheme` → `getAllHandlers(for scheme: String) -> [String]`
  - `LSCopyDefaultHandlerForURLScheme` → `getCurrentHandler(for scheme: String) -> String?`
  - `LSSetDefaultHandlerForURLScheme` → `setDefaultHandler(_ bundleID: String, for scheme: String)`
- [ ] Handle memory management for Core Foundation objects
- [ ] Add proper error handling for API failures

#### 2.2.2. Browser Management Module

- [ ] Port `app_name_from_bundle_id` function:

```swift
  func browserName(from bundleID: String) -> String
```

- [ ] Port `get_http_handlers` function:

```swift
  func getAvailableBrowsers() -> [String: String] // [name: bundleID]
```

- [ ] Port `get_current_http_handler` function:

```swift
  func getCurrentDefaultBrowser() -> String?
```

- [ ] Port browser setting logic with both HTTP and HTTPS schemes
- [ ] Add validation for browser availability

#### 2.2.3. Dialog Automation Module

- [ ] Implement AppleScript execution from Swift
- [ ] Create function to handle CoreServicesUIAgent dialog:

```swift
  func confirmBrowserChangeDialog(for browserName: String, timeout: TimeInterval = 2.0) async throws
```

- [ ] Implement retry logic for dialog detection
- [ ] Add proper error handling for automation failures
- [ ] Make automation optional with fallback to manual confirmation

#### 2.2.4. 2.4 Command-Line Interface

- [ ] Parse command-line arguments
- [ ] Implement two modes:
  - No arguments: List all browsers with current default marked
  - With browser name: Set as default and auto-confirm dialog
- [ ] Add proper exit codes for different error conditions
- [ ] Format output to match original tool

### 2.3. Build System

#### 2.3.1. Makefile

- [ ] Create new Makefile that:
  - Builds Swift package with `swift build -c release`
  - Creates universal binary with `lipo` for Intel + Apple Silicon
  - Installs to `/usr/local/bin`
  - Includes clean and uninstall targets
- [ ] Ensure compatibility with existing Makefile commands

#### 2.3.2. 3.2 Swift Package Configuration

- [ ] Configure minimum macOS version (10.15 or later for Swift concurrency)
- [ ] Set up proper build settings for universal binary
- [ ] Configure code signing if needed

### 2.4. Testing

- [ ] Create unit tests for:
  - Browser name extraction from bundle IDs
  - Command-line argument parsing
  - Error handling scenarios
- [ ] Create integration tests for:
  - Listing available browsers
  - Setting default browser (with mock dialog)
- [ ] Manual testing checklist:
  - Test on both Intel and Apple Silicon Macs
  - Test with various browsers (Safari, Chrome, Firefox, Edge, etc.)
  - Test dialog automation timing and reliability

### 2.5. Distribution

#### 2.5.1. Homebrew Formula

- [ ] Create `macdefaultbrowser.rb` formula
- [ ] Include proper dependencies and installation steps
- [ ] Test formula locally before submission
- [ ] Submit to homebrew-core or create custom tap

#### 2.5.2. GitHub Actions

- [ ] Create `.github/workflows/build.yml` for:
  - Building on macOS (latest)
  - Running tests
  - Creating universal binary
- [ ] Create `.github/workflows/release.yml` for:
  - Triggering on tags matching `vA.B.C`
  - Building release binary
  - Creating GitHub release
  - Uploading binary as release asset
- [ ] Add code signing workflow if distributing outside App Store

### 2.6. Documentation

- [ ] Update README.md with:
  - Installation instructions (Homebrew, manual)
  - Usage examples
  - Build instructions for developers
- [ ] Add inline documentation for Swift code
- [ ] Create CHANGELOG.md for version history

### 2.7. License and Legal

- [ ] Add MIT LICENSE file
- [ ] Add license headers to all source files
- [ ] Ensure compliance with Apple's guidelines for automation

## 3. Implementation Order

1. **Phase 1: Core Functionality** (Priority: High)

   - Launch Services wrapper
   - Basic browser listing and setting
   - Command-line interface

2. **Phase 2: Dialog Automation** (Priority: High)

   - AppleScript integration
   - Dialog detection and clicking
   - Error handling and fallbacks

3. **Phase 3: Build System** (Priority: Medium)

   - Makefile updates
   - Universal binary creation
   - GitHub Actions setup

4. **Phase 4: Distribution** (Priority: Medium)
   - Homebrew formula
   - Release automation
   - Documentation updates

## 4. Technical Considerations

### 4.1. Swift-Specific Implementation Details

1. **Memory Management**

   - Use Swift's automatic reference counting
   - Properly bridge Core Foundation objects with `Unmanaged`

   - Clean up any manual allocations

2. **Concurrency**

   - Use Swift's async/await for dialog automation timing
   - Implement timeout handling with Task cancellation
   - Consider using Combine for event handling

3. **Error Handling**

   - Define custom error types for different failure scenarios
   - Use Result types where appropriate
   - Provide helpful error messages to users

4. **Platform Integration**
   - Use `@available` annotations for OS version requirements
   - Handle missing entitlements gracefully
   - Test on various macOS versions

### 4.2. Security Considerations

1. **Code Signing**

   - Sign the binary for Gatekeeper compliance
   - Consider notarization for distribution
   - Document any required entitlements

2. **Automation Permissions**
   - Handle Accessibility permissions for UI automation
   - Provide clear instructions for permission setup
   - Gracefully degrade if permissions are denied

## 5. Success Criteria

- [ ] Tool lists all available browsers correctly
- [ ] Current default browser is marked with asterisk
- [ ] Setting a browser as default works reliably
- [ ] Dialog automation confirms changes automatically
- [ ] Universal binary runs on both Intel and Apple Silicon
- [ ] Homebrew installation works smoothly
- [ ] GitHub Actions create releases automatically
- [ ] All tests pass on supported macOS versions
