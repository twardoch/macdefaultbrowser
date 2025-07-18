# Build Documentation

## Overview

This document describes the build system for `macdefaultbrowser`, including local development, testing, and release processes.

## Prerequisites

- macOS 10.15 or later
- Xcode Command Line Tools or Xcode
- Swift 5.9 or later
- Git

## Quick Start

### Development Build

```bash
# Quick build for development
./build.sh

# Or use the comprehensive build script
./scripts/build-and-test.sh
```

### Testing

```bash
# Run all tests
./scripts/build-and-test.sh --verbose

# Skip tests (build only)
./scripts/build-and-test.sh --skip-tests
```

### Release Build

```bash
# Create a release build with signing (requires certificates)
./scripts/build-and-test.sh --release --sign

# Create a release without signing
./scripts/build-and-test.sh --release --skip-sign
```

## Build System Components

### 1. Makefile

The main build system is based on a comprehensive Makefile:

```bash
# Basic operations
make build          # Build the binary
make test           # Run tests
make clean          # Clean build artifacts
make install        # Install to /usr/local/bin

# Version management
make version        # Show version information
make generate-version  # Generate Version.swift from git tags

# Distribution
make dist           # Create distribution packages (DMG, PKG)
make sign           # Sign the binary
make notarize       # Notarize the binary

# Python support
make py-install     # Install Python dependencies
make py-test        # Run Python tests
make py-run         # Run Python version
```

### 2. Build Scripts

#### `./scripts/build-and-test.sh`

Comprehensive build and test script with options:

```bash
./scripts/build-and-test.sh [OPTIONS]

OPTIONS:
  -h, --help          Show help message
  -v, --verbose       Enable verbose output
  -c, --clean         Clean build artifacts before building
  -s, --sign          Sign the binary (requires CODESIGN_IDENTITY)
  -n, --notarize      Notarize the binary (requires Apple ID credentials)
  -r, --release       Create release artifacts (implies --sign)
  -t, --skip-tests    Skip running tests
```

#### `./scripts/release.sh`

Release management script:

```bash
./scripts/release.sh [OPTIONS] <version>

OPTIONS:
  -h, --help          Show help message
  -v, --verbose       Enable verbose output
  -d, --dry-run       Show what would be done without actually doing it
  -t, --skip-tests    Skip running tests
  -s, --skip-sign     Skip code signing
  -n, --skip-notarize Skip notarization
```

### 3. Version Management

The build system uses git tags for version management:

- Version is automatically extracted from git tags
- Uses semantic versioning (e.g., `v1.2.3`)
- Fallback to git describe for development builds
- Version information is embedded in the binary

### 4. Universal Binary Support

The build system creates universal binaries for distribution:

```bash
# Build universal binary (ARM64 + x86_64)
make dist

# Build for current architecture only
make build
```

## Development Workflow

### 1. Local Development

```bash
# Clone the repository
git clone https://github.com/twardoch/macdefaultbrowser.git
cd macdefaultbrowser

# Build and test
./scripts/build-and-test.sh --verbose

# Run the binary
./macdefaultbrowser/build/macdefaultbrowser --version
```

### 2. Testing

```bash
# Run unit tests
make test

# Run comprehensive tests
./scripts/build-and-test.sh --clean --verbose

# Test specific functionality
./macdefaultbrowser/build/macdefaultbrowser --help
./macdefaultbrowser/build/macdefaultbrowser
```

### 3. Code Signing (Optional)

For distribution, you can sign the binary:

```bash
# Set up code signing identity
export CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"

# Build and sign
./scripts/build-and-test.sh --release --sign
```

### 4. Creating Releases

```bash
# Create a new release
./scripts/release.sh 1.2.3

# Test release process without making changes
./scripts/release.sh --dry-run 1.2.3
```

## Continuous Integration

### GitHub Actions

The project uses GitHub Actions for CI/CD:

1. **Build and Test** (`.github/workflows/build.yml`)
   - Runs on every push and pull request
   - Tests on multiple macOS versions
   - Uploads build artifacts

2. **Release** (`.github/workflows/release.yml`)
   - Triggers on version tags (`v*.*.*`)
   - Creates signed and notarized releases
   - Uploads to GitHub Releases

3. **Continuous Integration** (`.github/workflows/ci.yml`)
   - Daily comprehensive tests
   - Compatibility testing
   - Performance benchmarks

### Environment Variables

For CI/CD, set these secrets in GitHub:

```bash
# Code signing
CODESIGN_CERTIFICATE      # Base64 encoded P12 certificate
CODESIGN_PASSWORD         # Certificate password
CODESIGN_IDENTITY         # Developer ID Application

# Notarization
APPLE_ID                  # Apple ID for notarization
TEAM_ID                   # Apple Team ID
NOTARIZATION_PASSWORD     # App-specific password
```

## Build Artifacts

### Directory Structure

```
macdefaultbrowser/
├── build/                      # Build output
│   ├── macdefaultbrowser      # Main binary
│   └── *.dSYM/               # Debug symbols
├── dist/                      # Distribution packages
│   ├── macdefaultbrowser-*.dmg
│   ├── macdefaultbrowser-*.pkg
│   └── checksums
└── .build/                    # Swift build cache
```

### Artifact Types

1. **Binary**: `macdefaultbrowser/build/macdefaultbrowser`
   - Universal binary (ARM64 + x86_64)
   - Optimized for release

2. **DMG**: `macdefaultbrowser/dist/macdefaultbrowser-*.dmg`
   - Disk image with installer package
   - Suitable for manual installation

3. **PKG**: `macdefaultbrowser/dist/macdefaultbrowser-*.pkg`
   - Installer package
   - Can be deployed via MDM

4. **Archives**: `tar.gz` and `zip` files
   - Binary-only archives
   - Suitable for automation

## Troubleshooting

### Common Issues

1. **Swift Build Errors**
   ```bash
   # Clean and rebuild
   make clean
   ./scripts/build-and-test.sh --clean
   ```

2. **Code Signing Issues**
   ```bash
   # Check certificate
   security find-identity -v -p codesigning
   
   # Skip signing for development
   ./scripts/build-and-test.sh --skip-sign
   ```

3. **Test Failures**
   ```bash
   # Run tests with verbose output
   ./scripts/build-and-test.sh --verbose
   
   # Skip tests if needed
   ./scripts/build-and-test.sh --skip-tests
   ```

### Debug Information

```bash
# Show build environment
make version
swift --version
xcodebuild -version

# Check binary
file macdefaultbrowser/build/macdefaultbrowser
otool -l macdefaultbrowser/build/macdefaultbrowser
```

## Performance Considerations

- Universal binaries are larger but provide better compatibility
- Release builds are optimized for performance
- Debug builds include additional information for debugging
- Consider using `--skip-tests` for faster development builds

## Security

- Code signing is recommended for distribution
- Notarization is required for Gatekeeper compatibility
- All certificates and keys should be stored securely
- Use app-specific passwords for notarization