# Testing Guide

## Overview

This document describes the testing strategy and implementation for `macdefaultbrowser`.

## Test Structure

### Unit Tests

Located in `macdefaultbrowser/Tests/macdefaultbrowserTests/`:

- **BrowserManagerTests.swift**: Tests for the main browser management logic
- **LaunchServicesWrapperTests.swift**: Tests for Launch Services API integration
- **DialogAutomationTests.swift**: Tests for system dialog automation
- **VersionTests.swift**: Tests for version information handling

### Integration Tests

Included within unit test files, these tests verify:
- Complete workflows (list → set → verify)
- Error handling across components
- System integration points

### Performance Tests

Available through CI/CD workflows:
- Startup time measurement
- Browser listing performance
- Dialog automation timing

## Running Tests

### Local Testing

```bash
# Run all tests
make test

# Run with verbose output
swift test --package-path macdefaultbrowser --verbose

# Run specific test file
swift test --package-path macdefaultbrowser --filter BrowserManagerTests

# Run specific test method
swift test --package-path macdefaultbrowser --filter testGetAllBrowsers
```

### Comprehensive Testing

```bash
# Run build and test script
./scripts/build-and-test.sh --verbose

# Clean build and test
./scripts/build-and-test.sh --clean --verbose

# Test with different configurations
./scripts/build-and-test.sh --release
```

### Manual Testing

```bash
# Build the binary
make build

# Test basic functionality
./macdefaultbrowser/build/macdefaultbrowser --version
./macdefaultbrowser/build/macdefaultbrowser --help
./macdefaultbrowser/build/macdefaultbrowser

# Test browser setting (replace 'chrome' with an available browser)
./macdefaultbrowser/build/macdefaultbrowser chrome
```

## Test Coverage

### Current Coverage Areas

1. **Browser Discovery**
   - Launch Services API calls
   - Browser name extraction
   - Bundle identifier validation

2. **Default Browser Management**
   - Getting current default
   - Setting new default
   - Error handling

3. **Dialog Automation**
   - AppleScript generation
   - Timeout handling
   - Error recovery

4. **Version Management**
   - Version string formatting
   - Git tag parsing
   - Build-time generation

### Coverage Goals

- **Unit Tests**: 85%+ line coverage
- **Integration Tests**: All major workflows
- **Error Handling**: All error paths tested
- **Edge Cases**: Boundary conditions covered

## Test Categories

### 1. Functional Tests

Test that the application works as expected:

```swift
func testListBrowsers() throws {
    let browsers = try browserManager.listBrowsers()
    XCTAssertFalse(browsers.isEmpty, "Should find at least one browser")
}
```

### 2. Error Handling Tests

Test error conditions and recovery:

```swift
func testBrowserNotFound() async {
    await XCTAssertThrowsError(
        try await browserManager.setDefaultBrowser("NonExistentBrowser")
    ) { error in
        XCTAssertTrue(error is BrowserManager.BrowserError)
    }
}
```

### 3. Performance Tests

Test performance characteristics:

```swift
func testBrowserListingPerformance() throws {
    measure {
        _ = try browserManager.listBrowsers()
    }
}
```

### 4. Integration Tests

Test component interactions:

```swift
func testCompleteWorkflow() async throws {
    // List browsers
    let browsers = try browserManager.listBrowsers()
    
    // Find a browser to test with
    guard let testBrowser = browsers.first else { return }
    
    // Set as default
    try await browserManager.setDefaultBrowser(testBrowser.name)
    
    // Verify it's set
    let current = try browserManager.getCurrentDefaultBrowser()
    XCTAssertEqual(current?.bundleIdentifier, testBrowser.bundleIdentifier)
}
```

## CI/CD Testing

### GitHub Actions

#### Build and Test Workflow
- Runs on every push and pull request
- Tests on multiple macOS versions
- Uploads test results and coverage

#### Release Workflow
- Comprehensive testing before release
- Signed binary testing
- Multi-platform verification

#### Continuous Integration
- Daily comprehensive test runs
- Performance regression testing
- Compatibility testing

### Test Matrix

```yaml
strategy:
  matrix:
    os: [macos-13, macos-14, macos-latest]
    swift-version: ['5.9', '5.10']
```

## Mocking and Test Doubles

### Launch Services Mocking

For testing without system dependencies:

```swift
protocol LaunchServicesProtocol {
    func getAllBrowsers() throws -> [Browser]
    func getCurrentDefaultBrowser() throws -> Browser?
    func setDefaultBrowser(_ bundleIdentifier: String) throws
}

class MockLaunchServices: LaunchServicesProtocol {
    var mockBrowsers: [Browser] = []
    var mockDefault: Browser?
    
    func getAllBrowsers() throws -> [Browser] {
        return mockBrowsers
    }
    
    // ... other mock implementations
}
```

### Dialog Automation Mocking

For testing dialog automation without system dialogs:

```swift
protocol DialogAutomationProtocol {
    func confirmDefaultBrowserDialog() async throws
}

class MockDialogAutomation: DialogAutomationProtocol {
    var shouldSucceed = true
    
    func confirmDefaultBrowserDialog() async throws {
        if !shouldSucceed {
            throw DialogAutomation.DialogError.dialogNotFound
        }
    }
}
```

## Test Data

### Sample Browser Data

```swift
let sampleBrowsers: [LaunchServicesWrapper.Browser] = [
    Browser(name: "chrome", bundleIdentifier: "com.google.Chrome", 
            displayName: "Google Chrome", isDefault: false),
    Browser(name: "safari", bundleIdentifier: "com.apple.Safari", 
            displayName: "Safari", isDefault: true),
    Browser(name: "firefox", bundleIdentifier: "org.mozilla.firefox", 
            displayName: "Firefox", isDefault: false)
]
```

### Test Scenarios

1. **Single Browser**: System with only one browser
2. **Multiple Browsers**: System with several browsers
3. **No Default**: System with no default browser set
4. **Invalid Browser**: Attempting to set non-existent browser
5. **Permission Denied**: Launch Services API permission issues

## Test Utilities

### Custom Assertions

```swift
func XCTAssertContainsBrowser(_ browsers: [Browser], name: String) {
    XCTAssertTrue(browsers.contains { $0.name == name }, 
                  "Browser list should contain \(name)")
}

func XCTAssertValidBrowser(_ browser: Browser) {
    XCTAssertFalse(browser.name.isEmpty, "Browser name should not be empty")
    XCTAssertFalse(browser.bundleIdentifier.isEmpty, 
                   "Bundle identifier should not be empty")
    XCTAssertTrue(browser.bundleIdentifier.contains("."), 
                  "Bundle identifier should be valid")
}
```

### Test Helpers

```swift
class TestHelper {
    static func createMockBrowser(name: String = "testbrowser", 
                                isDefault: Bool = false) -> Browser {
        return Browser(
            name: name,
            bundleIdentifier: "com.test.\(name)",
            displayName: name.capitalized,
            isDefault: isDefault
        )
    }
}
```

## Debugging Tests

### Debug Output

```swift
func testWithDebugOutput() throws {
    print("Testing browser listing...")
    let browsers = try browserManager.listBrowsers()
    print("Found browsers: \(browsers.map { $0.name })")
    // ... test assertions
}
```

### Conditional Testing

```swift
func testRequiringSpecificBrowser() throws {
    let browsers = try browserManager.listBrowsers()
    let hasChrome = browsers.contains { $0.name == "chrome" }
    
    guard hasChrome else {
        throw XCTSkip("Chrome not installed, skipping test")
    }
    
    // ... test that requires Chrome
}
```

## Best Practices

### Test Organization

1. **One concept per test**: Each test should verify one specific behavior
2. **Descriptive names**: Test names should clearly describe what they test
3. **AAA Pattern**: Arrange, Act, Assert structure
4. **Independent tests**: Tests should not depend on each other

### Error Testing

```swift
func testErrorHandling() {
    // Test specific error conditions
    XCTAssertThrowsError(try someOperation()) { error in
        guard case SomeError.specificError = error else {
            XCTFail("Expected specific error, got \(error)")
            return
        }
    }
}
```

### Async Testing

```swift
func testAsyncOperation() async throws {
    let result = try await someAsyncOperation()
    XCTAssertNotNil(result)
}
```

## Continuous Improvement

### Test Metrics

- **Coverage**: Aim for 85%+ line coverage
- **Performance**: Monitor test execution time
- **Reliability**: Track test flakiness
- **Maintainability**: Keep tests simple and focused

### Test Reviews

- All new code should include tests
- Tests should be reviewed for quality
- Test coverage should be maintained
- Performance tests should be added for critical paths

## Troubleshooting

### Common Issues

1. **Permission Errors**: May require running with elevated permissions
2. **System Dependencies**: Some tests may fail on systems without certain browsers
3. **Timing Issues**: Dialog automation tests may be sensitive to timing
4. **Xcode Version**: Tests may behave differently across Xcode versions

### Debug Commands

```bash
# Run specific test with debug output
swift test --package-path macdefaultbrowser --filter testName -v

# Build test target only
swift build --package-path macdefaultbrowser --target macdefaultbrowserTests

# Generate test coverage report
swift test --package-path macdefaultbrowser --enable-code-coverage
```