#!/usr/bin/env bash
# this_file: scripts/release.sh

set -euo pipefail

# Release Script for macdefaultbrowser
# This script creates a new release with proper git tagging and artifact generation

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
DRY_RUN=false
SKIP_TESTS=false
SKIP_SIGN=false
SKIP_NOTARIZE=false

# Print usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS] <version>

Create a new release for macdefaultbrowser

ARGUMENTS:
    version             Version to release (e.g., 1.2.3)

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -d, --dry-run       Show what would be done without actually doing it
    -t, --skip-tests    Skip running tests
    -s, --skip-sign     Skip code signing
    -n, --skip-notarize Skip notarization
    
ENVIRONMENT VARIABLES:
    CODESIGN_IDENTITY           Developer ID for code signing
    APPLE_ID                    Apple ID for notarization
    TEAM_ID                     Team ID for notarization
    NOTARIZATION_PASSWORD       App-specific password for notarization

EXAMPLES:
    $0 1.2.3                    # Create release v1.2.3
    $0 --dry-run 1.2.3         # Show what would be done
    $0 --skip-notarize 1.2.3   # Create release without notarization
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
VERSION=""
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
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -t|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -s|--skip-sign)
            SKIP_SIGN=true
            shift
            ;;
        -n|--skip-notarize)
            SKIP_NOTARIZE=true
            shift
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            if [[ -z "$VERSION" ]]; then
                VERSION="$1"
            else
                print_error "Too many arguments"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate version argument
if [[ -z "$VERSION" ]]; then
    print_error "Version argument is required"
    usage
    exit 1
fi

# Validate version format (semantic versioning)
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
    print_error "Invalid version format. Use semantic versioning (e.g., 1.2.3)"
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT"

print_status "Starting release process for version $VERSION..."

# Step 1: Check git status
print_status "Checking git status..."
if ! git diff --quiet; then
    print_error "Working directory is not clean. Please commit or stash changes."
    exit 1
fi

if ! git diff --cached --quiet; then
    print_error "There are staged changes. Please commit or unstage them."
    exit 1
fi

# Step 2: Check if tag already exists
TAG="v$VERSION"
if git tag -l | grep -q "^$TAG$"; then
    print_error "Tag $TAG already exists"
    exit 1
fi

# Step 3: Check if we're on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    print_warning "Not on main branch (current: $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 4: Update changelog if it exists
if [[ -f "CHANGELOG.md" ]]; then
    print_status "Updating CHANGELOG.md..."
    if [[ "$DRY_RUN" == false ]]; then
        # Add release header to changelog
        sed -i.bak "1s/^/## [$VERSION] - $(date +%Y-%m-%d)\n\n/" CHANGELOG.md
        rm CHANGELOG.md.bak
    fi
    print_success "CHANGELOG.md updated"
fi

# Step 5: Run tests
if [[ "$SKIP_TESTS" == false ]]; then
    print_status "Running tests..."
    if [[ "$DRY_RUN" == false ]]; then
        ./scripts/build-and-test.sh --skip-tests false
    else
        echo "Would run: ./scripts/build-and-test.sh --skip-tests false"
    fi
    print_success "Tests passed"
fi

# Step 6: Create git tag
print_status "Creating git tag $TAG..."
if [[ "$DRY_RUN" == false ]]; then
    git tag -a "$TAG" -m "Release version $VERSION"
else
    echo "Would run: git tag -a '$TAG' -m 'Release version $VERSION'"
fi
print_success "Git tag created"

# Step 7: Build release artifacts
print_status "Building release artifacts..."
BUILD_ARGS=""
if [[ "$SKIP_SIGN" == false ]]; then
    BUILD_ARGS="$BUILD_ARGS --sign"
fi
if [[ "$SKIP_NOTARIZE" == false ]]; then
    BUILD_ARGS="$BUILD_ARGS --notarize"
fi
if [[ "$VERBOSE" == true ]]; then
    BUILD_ARGS="$BUILD_ARGS --verbose"
fi

if [[ "$DRY_RUN" == false ]]; then
    ./scripts/build-and-test.sh --release --skip-tests $BUILD_ARGS
else
    echo "Would run: ./scripts/build-and-test.sh --release --skip-tests $BUILD_ARGS"
fi
print_success "Release artifacts built"

# Step 8: Push tag to remote
print_status "Pushing tag to remote..."
if [[ "$DRY_RUN" == false ]]; then
    git push origin "$TAG"
else
    echo "Would run: git push origin '$TAG'"
fi
print_success "Tag pushed to remote"

# Step 9: Show release summary
print_success "Release $VERSION completed successfully!"
print_status "Summary:"
echo "  - Tag: $TAG"
echo "  - Branch: $CURRENT_BRANCH"
echo "  - Commit: $(git rev-parse HEAD)"

if [[ "$DRY_RUN" == false ]]; then
    if [[ -d "macdefaultbrowser/dist" ]]; then
        echo "  - Artifacts:"
        ls -la macdefaultbrowser/dist/ | grep -E "\.(dmg|pkg|tar\.gz|zip)$" | awk '{print "    " $9}'
    fi
fi

print_status "Next steps:"
echo "  1. GitHub Actions will automatically create a release"
echo "  2. Release artifacts will be uploaded to the GitHub release"
echo "  3. Update Homebrew formula if needed"
echo "  4. Announce the release"

if [[ "$DRY_RUN" == true ]]; then
    print_warning "This was a dry run. No changes were made."
fi