# Detailed Refactoring Plan: Splitting Large Source Files

## Overview
This plan outlines how to split the larger source files in the macdefaultbrowser project into smaller, more manageable modules while maintaining functionality. The project currently has 4 files over 1KB that could benefit from refactoring.

## Current File Sizes
- **LaunchServicesWrapper.swift**: 4,869 bytes (100 lines)
- **DialogAutomation.swift**: 4,672 bytes (113 lines)
- **BrowserManager.swift**: 3,905 bytes (100 lines)
- **main.swift**: 2,847 bytes (83 lines)

## Refactoring Plan

### 1. LaunchServicesWrapper.swift (4,869 bytes → ~1,500 bytes each)

**Current Structure**: Single enum containing all Launch Services functionality with modern and legacy implementations.

**Split into 3 files:**

#### a) `LaunchServicesModern.swift` (~1,500 bytes)
```swift
// this_file: Sources/macdefaultbrowser/LaunchServicesModern.swift
import Foundation
import AppKit

/// Modern implementation using NSWorkspace API (macOS 12.0+)
@available(macOS 12.0, *)
enum LaunchServicesModern {
    static func getAllHandlers(for scheme: String) -> [String]
    static func getCurrentHandler(for scheme: String) -> String?
}
```
- Move lines 14-32 (getAllHandlers modern implementation)
- Move lines 37-55 (getCurrentHandler modern implementation)
- Add appropriate imports and documentation

#### b) `LaunchServicesLegacy.swift` (~1,500 bytes)
```swift
// this_file: Sources/macdefaultbrowser/LaunchServicesLegacy.swift
import Foundation
import ApplicationServices

/// Legacy implementation for macOS 10.15-11.x compatibility
enum LaunchServicesLegacy {
    static func getAllHandlers(for scheme: String) -> [String]
    static func getCurrentHandler(for scheme: String) -> String?
}
```
- Move lines 80-99 (legacy implementations)
- Remove @available deprecation markers (they'll be internal)
- Add appropriate imports and documentation

#### c) `LaunchServicesWrapper.swift` (~1,869 bytes)
```swift
// this_file: Sources/macdefaultbrowser/LaunchServicesWrapper.swift
import Foundation
import ApplicationServices

/// Swift wrapper for Launch Services API functionality
enum LaunchServicesWrapper {
    static func getAllHandlers(for scheme: String) -> [String]
    static func getCurrentHandler(for scheme: String) -> String?
    static func setDefaultHandler(_ bundleID: String, for scheme: String) -> Bool
}
```
- Keep the main wrapper enum as the public interface
- Implement methods that delegate to Modern or Legacy based on OS version
- Keep setDefaultHandler (lines 62-73) as it doesn't have OS-specific variants

### 2. DialogAutomation.swift (4,672 bytes → ~2,300 bytes each)

**Current Structure**: Single struct with dialog automation logic, browser name mapping, and osascript execution.

**Split into 2 files:**

#### a) `DialogBrowserMapping.swift` (~800 bytes)
```swift
// this_file: Sources/macdefaultbrowser/DialogBrowserMapping.swift
import Foundation

/// Maps internal browser names to display names used in system dialogs
enum DialogBrowserMapping {
    static func dialogBrowserName(for browserName: String) -> String
}
```
- Move lines 9-25 (dialogBrowserName function)
- Create as a separate utility enum for browser name mappings

#### b) `OsascriptRunner.swift` (~1,200 bytes)
```swift
// this_file: Sources/macdefaultbrowser/OsascriptRunner.swift
import Foundation

/// Executes AppleScript via osascript subprocess
struct OsascriptRunner {
    static func run(_ script: String) -> String?
}
```
- Move lines 28-47 (runOsascript implementation)
- Make it a reusable utility for running AppleScript

#### c) `DialogAutomation.swift` (~2,672 bytes)
```swift
// this_file: Sources/macdefaultbrowser/DialogAutomation.swift
import Foundation

/// Handles automatic confirmation of system dialogs
struct DialogAutomation {
    static func setDefaultBrowserWithAutomation(_ browserName: String) async throws
    private static func monitorAndClickDialog(browserName: String)
}
```
- Keep lines 50-113 (main automation logic)
- Import and use DialogBrowserMapping and OsascriptRunner
- Focus on the core automation workflow

### 3. BrowserManager.swift (3,905 bytes → ~1,300 bytes each)

**Current Structure**: Single struct with browser management logic and error definitions.

**Split into 3 files:**

#### a) `BrowserError.swift` (~600 bytes)
```swift
// this_file: Sources/macdefaultbrowser/BrowserError.swift
import Foundation

/// Errors that can occur during browser management
enum BrowserError: LocalizedError {
    case browserNotFound(String)
    case alreadyDefault(String)
    case setDefaultFailed(String)
    
    var errorDescription: String?
}
```
- Move lines 85-100 (BrowserError enum)
- Separate error definitions from business logic

#### b) `BrowserUtilities.swift` (~800 bytes)
```swift
// this_file: Sources/macdefaultbrowser/BrowserUtilities.swift
import Foundation

/// Utility functions for browser identification
enum BrowserUtilities {
    static func browserName(from bundleID: String) -> String
}
```
- Move lines 8-15 (browserName extraction)
- Create a utilities enum for browser-related helper functions

#### c) `BrowserManager.swift` (~2,505 bytes)
```swift
// this_file: Sources/macdefaultbrowser/BrowserManager.swift
import Foundation

/// Manages browser detection and default browser settings
struct BrowserManager {
    static func getAvailableBrowsers() -> [String: String]
    static func getCurrentDefaultBrowser() -> String?
    static func setDefaultBrowser(_ browserName: String) throws
    static func listBrowsers() -> [(name: String, isDefault: Bool)]
}
```
- Keep lines 19-82 (core browser management functions)
- Import and use BrowserUtilities and BrowserError
- Focus on the main browser management operations

### 4. main.swift (2,847 bytes → ~1,400 bytes each)

**Current Structure**: Single file with main entry point, command handling, and help text.

**Split into 2 files:**

#### a) `CommandLineInterface.swift` (~1,500 bytes)
```swift
// this_file: Sources/macdefaultbrowser/CommandLineInterface.swift
import Foundation

/// Command-line interface helpers
struct CommandLineInterface {
    static func printHelp()
    static func listBrowsers()
    static func setDefaultBrowser(_ browserName: String) async
}
```
- Move lines 34-82 (all static functions)
- Separate CLI logic from main entry point

#### b) `main.swift` (~1,347 bytes)
```swift
// this_file: Sources/macdefaultbrowser/main.swift
import Foundation

/// Main entry point for macdefaultbrowser
@main
struct MacDefaultBrowser {
    static func main() async
}
```
- Keep lines 1-32 (main function with argument parsing)
- Import and delegate to CommandLineInterface methods
- Focus on being the entry point and argument router

## Implementation Steps for Junior Developers

### Step 1: Create New Files
1. Create all new Swift files in the `Sources/macdefaultbrowser/` directory
2. Add the `this_file:` comment at the top of each file
3. Add appropriate imports

### Step 2: Move Code (File by File)
For each file to be split:

1. **Copy** (don't cut) the relevant code sections to the new files
2. Update imports in the new files
3. Add proper access modifiers (internal/public) if needed
4. Test that the project still compiles after each file split
5. Once confirmed working, remove the moved code from the original file

### Step 3: Update References
1. Update the original files to import and use the new modules
2. Replace direct function calls with calls to the new types
3. Ensure all error types are properly imported where used

### Step 4: Test Each Refactoring
After splitting each file:
1. Run `swift build` to ensure compilation
2. Run `swift test` to ensure tests pass
3. Test the binary manually with commands like:
   - `swift run macdefaultbrowser` (list browsers)
   - `swift run macdefaultbrowser safari` (set default)

### Step 5: Clean Up
1. Remove any duplicate imports
2. Ensure consistent formatting
3. Verify all `this_file:` comments are correct
4. Run the linter if one is configured

## Benefits of This Refactoring

1. **Better Organization**: Each file has a single, clear responsibility
2. **Easier Testing**: Smaller units can be tested in isolation
3. **Improved Maintainability**: Changes to one aspect don't require understanding the entire file
4. **Clearer Dependencies**: Import statements show exactly what each module depends on
5. **Faster Compilation**: Smaller files can lead to better incremental compilation

## Important Notes

- **Preserve Functionality**: The external API must remain exactly the same
- **Maintain Compatibility**: Ensure the refactoring doesn't break existing usage
- **Test Thoroughly**: Run all tests after each file is split
- **Document Changes**: Update any documentation that references file locations
- **Commit Incrementally**: Make a git commit after successfully splitting each file

## Verification Checklist

After completing all refactoring:
- [ ] All files are under 2KB (except where it makes sense to keep larger)
- [ ] Project builds without warnings
- [ ] All tests pass
- [ ] Binary works correctly for all commands
- [ ] No functionality has been lost or changed
- [ ] Code is properly organized by responsibility
- [ ] All imports are minimal and necessary