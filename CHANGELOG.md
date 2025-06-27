# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

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

### Technical Details

- Built with Swift 5.7 and macOS 10.15 minimum deployment target
- Uses async/await for dialog automation
- Proper error handling with custom error types
- Memory-safe Core Foundation bridging
- Deprecation warnings addressed (though still using deprecated APIs for compatibility)

## Reference Implementation

The Swift version is based on the original Objective-C implementation found in `reference/src/main.m` and incorporates the dialog automation functionality from `reference/good.sh`.
