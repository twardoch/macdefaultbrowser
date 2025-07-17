#!/usr/bin/env bash
# this_file: scripts/build-and-test.sh

set -euo pipefail

# Build and Test Script for macdefaultbrowser
# This script provides a convenient way to build, test, and optionally release the project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VERBOSE=false
CLEAN=false
SIGN=false
NOTARIZE=false
RELEASE=false
SKIP_TESTS=false

# Print usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build and test script for macdefaultbrowser

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -c, --clean         Clean build artifacts before building
    -s, --sign          Sign the binary (requires CODESIGN_IDENTITY)
    -n, --notarize      Notarize the binary (requires Apple ID credentials)
    -r, --release       Create release artifacts (implies --sign)
    -t, --skip-tests    Skip running tests
    
ENVIRONMENT VARIABLES:
    CODESIGN_IDENTITY           Developer ID for code signing
    APPLE_ID                    Apple ID for notarization
    TEAM_ID                     Team ID for notarization
    NOTARIZATION_PASSWORD       App-specific password for notarization

EXAMPLES:
    $0                          # Build and test
    $0 --clean --verbose        # Clean build with verbose output
    $0 --release               # Create signed release artifacts
    $0 --sign --notarize       # Build, sign, and notarize
EOF
}

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -s|--sign)
            SIGN=true
            shift
            ;;
        -n|--notarize)
            NOTARIZE=true
            SIGN=true  # Notarization requires signing
            shift
            ;;
        -r|--release)
            RELEASE=true
            SIGN=true  # Release requires signing
            shift
            ;;
        -t|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Set verbose mode for Make if requested
MAKE_VERBOSE=""
if [[ "$VERBOSE" == true ]]; then
    MAKE_VERBOSE="V=1"
fi

# Change to project root
cd "$PROJECT_ROOT"

print_status "Starting build and test process..."

# Step 1: Clean if requested
if [[ "$CLEAN" == true ]]; then
    print_status "Cleaning build artifacts..."
    make clean
    print_success "Clean completed"
fi

# Step 2: Show version information
print_status "Version information:"
make version

# Step 3: Build the project
print_status "Building project..."
if [[ "$VERBOSE" == true ]]; then
    make build $MAKE_VERBOSE
else
    make build
fi
print_success "Build completed"

# Step 4: Run tests (unless skipped)
if [[ "$SKIP_TESTS" == false ]]; then
    print_status "Running tests..."
    if [[ "$VERBOSE" == true ]]; then
        make test $MAKE_VERBOSE
    else
        make test
    fi
    print_success "Tests passed"
else
    print_warning "Tests skipped"
fi

# Step 5: Sign if requested
if [[ "$SIGN" == true ]]; then
    if [[ -z "${CODESIGN_IDENTITY:-}" ]]; then
        print_warning "CODESIGN_IDENTITY not set, skipping code signing"
    else
        print_status "Signing binary..."
        make sign CODESIGN_IDENTITY="$CODESIGN_IDENTITY"
        print_success "Code signing completed"
    fi
fi

# Step 6: Create release artifacts if requested
if [[ "$RELEASE" == true ]]; then
    print_status "Creating release artifacts..."
    if [[ "$VERBOSE" == true ]]; then
        make dist $MAKE_VERBOSE
    else
        make dist
    fi
    print_success "Release artifacts created"
fi

# Step 7: Notarize if requested
if [[ "$NOTARIZE" == true ]]; then
    if [[ -z "${APPLE_ID:-}" ]] || [[ -z "${TEAM_ID:-}" ]] || [[ -z "${NOTARIZATION_PASSWORD:-}" ]]; then
        print_warning "Apple ID credentials not set, skipping notarization"
        print_warning "Set APPLE_ID, TEAM_ID, and NOTARIZATION_PASSWORD environment variables"
    else
        print_status "Notarizing binary..."
        make notarize
        print_success "Notarization completed"
    fi
fi

# Step 8: Summary
print_success "Build and test process completed successfully!"

# Show build artifacts
if [[ -d "macdefaultbrowser/build" ]]; then
    print_status "Build artifacts:"
    ls -la macdefaultbrowser/build/
fi

if [[ -d "macdefaultbrowser/dist" ]]; then
    print_status "Distribution artifacts:"
    ls -la macdefaultbrowser/dist/
fi

# Final binary test
if [[ -f "macdefaultbrowser/build/macdefaultbrowser" ]]; then
    print_status "Testing binary..."
    ./macdefaultbrowser/build/macdefaultbrowser --version
    print_success "Binary test completed"
fi

print_success "All operations completed successfully!"