# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Documentation
- **Comprehensive README.md rewrite** - Improved clarity and structure of main documentation with better usage examples and installation instructions

### Changed
- **Streamlined .gitignore** - Refactored to better organize ignored files and patterns

## [1.3.0] - 2025-06-28

### Added
- Build output now goes to `build/` directory instead of root
- New `make dist` target creates installable .pkg and .dmg files
- Distribution packages include installer that places binary in `/usr/local/bin`
- GitHub Actions now automatically uploads .dmg and .pkg files to releases
- Both .dmg and .pkg files include checksums for verification
- **Dynamic version detection** - Version is now extracted from git tags during build
- **Semantic versioning from git tags** - Version is automatically extracted from git tags (e.g., v1.2.1 → 1.2.1)
- **Version information in binary** - Added `--version` flag to display version
- **Help command** - Added `--help` flag to display usage information
- Version.swift is generated during build with git tag information
- `make version` target to display current version information

### Fixed
- GitHub Actions build failure - Added missing Version.swift.template to repository
- Fixed .gitignore to properly exclude only generated Version.swift, not the template
- **Deprecation warnings** - Updated LaunchServicesWrapper to use modern NSWorkspace APIs on macOS 12.0+ with backward compatibility fallback for older macOS versions

### Documentation
- Added Homebrew installation guide in docs/HOMEBREW.md
- Created script to update Homebrew formula with correct SHA256 after releases
- Updated Homebrew formula with instructions and proper build directory
- **Code signing documentation** - Added comprehensive code signing guide in docs/CODE_SIGNING.md
- Added code signing support to Makefile with `make sign` target
- Documented notarization process and GitHub Actions integration
- **Notarization support** - Added `make notarize` target and scripts/notarize.sh
- Enhanced GitHub Actions workflow with automatic code signing and notarization
- Added instructions for exporting certificates for CI/CD

## [1.1.1] - 2025-06-27

### Changed

- Initial Swift implementation of macdefaultbrowser
- Core functionality to list all available browsers
- Ability to set default browser with automatic dialog confirmation
- Launch Services API wrapper for Swift
- Browser management module with case-insensitive matching
- Dialog automation using AppleScript
- Universal binary support (Intel + Apple Silicon)
- Makefile for building and installation
- Homebrew formula template
- GitHub Actions workflows for CI/CD
- MIT License
- Comprehensive README documentation
- Unit tests for browser management
- `.gitignore` for Swift projects

### Fixed

- Dialog automation now properly maps internal browser names to display names (e.g., "edgemac" → "Edge")
- Improved error handling for Launch Services API that may return errors even when dialog is shown
- Added multiple retry strategies for dialog button detection
- Increased timeouts and improved timing for dialog automation
- Fixed unused variable warnings in browser setting code
- **Fixed dialog automation by using subprocess approach** - AppleScript is now executed via osascript subprocess instead of NSAppleScript API, which properly handles system dialog clicking
- Improved user messaging - Changed from technical "Dialog automation: Clicked:" to user-friendly "As the default browser, the system will now use [Browser]"

### Technical Details

- Built with Swift 5.7 and macOS 10.15 minimum deployment target
- Uses async/await for dialog automation
- Proper error handling with custom error types
- Memory-safe Core Foundation bridging
- Deprecation warnings addressed (though still using deprecated APIs for compatibility)

## Reference Implementation

The Swift version is based on the original Objective-C implementation found in `reference/src/main.m` and incorporates the dialog automation functionality from `reference/good.sh`.
