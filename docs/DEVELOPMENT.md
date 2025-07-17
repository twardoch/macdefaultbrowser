# Development Guide

## Project Structure

```
macdefaultbrowser/
├── .github/workflows/         # GitHub Actions CI/CD
├── docs/                      # Documentation
├── macdefaultbrowser/         # Swift project
│   ├── Package.swift         # Swift package definition
│   ├── Sources/macdefaultbrowser/
│   │   ├── main.swift        # CLI entry point
│   │   ├── BrowserManager.swift      # Core browser management
│   │   ├── LaunchServicesWrapper.swift  # Launch Services API
│   │   ├── DialogAutomation.swift    # System dialog automation
│   │   └── Version.swift.template    # Version template
│   └── Tests/macdefaultbrowserTests/
│       ├── BrowserManagerTests.swift
│       ├── LaunchServicesWrapperTests.swift
│       ├── DialogAutomationTests.swift
│       └── VersionTests.swift
├── scripts/                   # Build and release scripts
│   ├── build-and-test.sh     # Main build script
│   ├── release.sh            # Release management
│   └── notarize.sh           # Notarization helper
├── Makefile                  # Build system
└── build.sh                 # Quick build script
```

## Architecture

### Core Components

1. **BrowserManager**: Main orchestrator for browser operations
2. **LaunchServicesWrapper**: Interface to macOS Launch Services API
3. **DialogAutomation**: Handles system dialog confirmation
4. **Version**: Embedded version information

### Key Design Principles

- **Separation of Concerns**: Each component has a single responsibility
- **Error Handling**: Comprehensive error types with descriptive messages
- **Async/Await**: Modern Swift concurrency for dialog automation
- **Testability**: Interfaces designed for easy testing

## Development Setup

### Prerequisites

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify Swift version
swift --version  # Should be 5.9 or later
```

### Getting Started

```bash
# Clone the repository
git clone https://github.com/twardoch/macdefaultbrowser.git
cd macdefaultbrowser

# Build and test
./scripts/build-and-test.sh --verbose

# Run the binary
./macdefaultbrowser/build/macdefaultbrowser --version
```

## Code Style

### Swift Guidelines

- Follow Apple's Swift API Design Guidelines
- Use meaningful names for functions and variables
- Prefer explicit types over type inference when clarity is improved
- Use `guard` statements for early returns
- Handle all error cases explicitly

### Example Code Structure

```swift
// File header with path
// this_file: macdefaultbrowser/Sources/macdefaultbrowser/ExampleFile.swift

import Foundation

/// Documentation comment explaining the class purpose
public class ExampleClass {
    
    /// Error types for this class
    public enum ExampleError: Error, LocalizedError {
        case specificError(String)
        
        public var errorDescription: String? {
            switch self {
            case .specificError(let message):
                return "Specific error: \(message)"
            }
        }
    }
    
    /// Public function with documentation
    public func exampleFunction() throws -> String {
        // Implementation
    }
}
```

## Testing

### Test Structure

- Unit tests for each component
- Integration tests for complete workflows
- Error handling tests
- Performance tests for critical paths

### Running Tests

```bash
# Run all tests
make test

# Run specific test file
swift test --package-path macdefaultbrowser --filter BrowserManagerTests

# Run with verbose output
swift test --package-path macdefaultbrowser --verbose
```

### Writing Tests

```swift
import XCTest
@testable import macdefaultbrowser

final class ExampleTests: XCTestCase {
    
    var subject: ExampleClass!
    
    override func setUp() {
        super.setUp()
        subject = ExampleClass()
    }
    
    override func tearDown() {
        subject = nil
        super.tearDown()
    }
    
    func testExampleFunction() throws {
        let result = try subject.exampleFunction()
        XCTAssertEqual(result, "expected")
    }
}
```

## Debugging

### Common Debug Techniques

1. **Verbose Mode**: Use `--verbose` flag for detailed output
2. **LLDB**: Use Xcode debugger for breakpoints
3. **Print Debugging**: Add temporary print statements
4. **Error Inspection**: Check error types and messages

### Debug Build

```bash
# Build debug version
swift build --package-path macdefaultbrowser -c debug

# Run with debugger
lldb .build/debug/macdefaultbrowser
```

## Contributing

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch
3. **Implement** your changes
4. **Test** thoroughly
5. **Submit** a pull request

### Code Review Process

- All changes require tests
- Follow existing code style
- Update documentation as needed
- Ensure CI passes

### Branch Strategy

- `main`: Production-ready code
- `develop`: Integration branch (if used)
- `feature/*`: Feature branches
- `hotfix/*`: Critical fixes

## Release Process

### Semantic Versioning

- `MAJOR.MINOR.PATCH` format
- `MAJOR`: Breaking changes
- `MINOR`: New features (backward compatible)
- `PATCH`: Bug fixes

### Creating Releases

```bash
# Create release (automated via scripts)
./scripts/release.sh 1.2.3

# Test release process
./scripts/release.sh --dry-run 1.2.3
```

### Release Checklist

- [ ] All tests pass
- [ ] Version bumped appropriately
- [ ] CHANGELOG.md updated
- [ ] Documentation updated
- [ ] Code signed (for distribution)
- [ ] Notarized (for public release)

## Performance Optimization

### Profiling

```bash
# Profile build time
time ./scripts/build-and-test.sh

# Profile runtime
time ./macdefaultbrowser/build/macdefaultbrowser
```

### Optimization Areas

1. **Startup Time**: Minimize work in main thread
2. **Memory Usage**: Proper cleanup of Core Foundation objects
3. **Launch Services**: Cache results when possible
4. **Dialog Automation**: Minimize timeout values

## Security Considerations

### Code Signing

```bash
# Sign binary
export CODESIGN_IDENTITY="Developer ID Application: Your Name"
make sign
```

### Notarization

```bash
# Notarize for distribution
export APPLE_ID="your@apple.id"
export TEAM_ID="TEAM_ID"
export NOTARIZATION_PASSWORD="app-specific-password"
make notarize
```

### Security Best Practices

- Never commit certificates or keys
- Use app-specific passwords for notarization
- Validate all user inputs
- Handle permissions gracefully

## Troubleshooting

### Build Issues

```bash
# Clean build
make clean
./scripts/build-and-test.sh --clean

# Check environment
make version
swift --version
```

### Runtime Issues

```bash
# Check permissions
./macdefaultbrowser/build/macdefaultbrowser --verbose

# Test specific functionality
./macdefaultbrowser/build/macdefaultbrowser chrome --verbose
```

### Common Problems

1. **Launch Services API**: May require permissions
2. **Dialog Automation**: Needs Accessibility permissions
3. **Code Signing**: Requires valid certificates
4. **Notarization**: Requires Apple ID credentials

## Resources

- [Swift Documentation](https://docs.swift.org/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Launch Services Reference](https://developer.apple.com/documentation/coreservices/launch_services)
- [Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)

## Getting Help

- Check existing issues on GitHub
- Review documentation in `/docs`
- Ask questions in discussions
- Submit bug reports with reproduction steps