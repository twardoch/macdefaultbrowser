#!/bin/bash
# this_file: scripts/update-homebrew-formula.sh
#
# Script to update Homebrew formula after a new release
# Usage: ./scripts/update-homebrew-formula.sh vX.Y.Z

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 vX.Y.Z"
    echo "Example: $0 v1.2.1"
    exit 1
fi

VERSION_TAG=$1
VERSION=${VERSION_TAG#v}  # Remove 'v' prefix

echo "Updating Homebrew formula for version $VERSION_TAG..."

# Download the tarball
TARBALL_URL="https://github.com/twardoch/macdefaultbrowser/archive/refs/tags/${VERSION_TAG}.tar.gz"
TEMP_FILE="/tmp/macdefaultbrowser-${VERSION_TAG}.tar.gz"

echo "Downloading tarball from $TARBALL_URL..."
curl -L -o "$TEMP_FILE" "$TARBALL_URL"

# Calculate SHA256
echo "Calculating SHA256..."
SHA256=$(shasum -a 256 "$TEMP_FILE" | awk '{print $1}')
echo "SHA256: $SHA256"

# Update the formula
FORMULA_FILE="macdefaultbrowser.rb"

if [ -f "$FORMULA_FILE" ]; then
    echo "Updating $FORMULA_FILE..."
    
    # Update URL
    sed -i '' "s|url \"https://github.com/twardoch/macdefaultbrowser/archive/refs/tags/v.*\.tar\.gz\"|url \"https://github.com/twardoch/macdefaultbrowser/archive/refs/tags/${VERSION_TAG}.tar.gz\"|" "$FORMULA_FILE"
    
    # Update SHA256
    sed -i '' "s|sha256 \".*\"|sha256 \"${SHA256}\"|" "$FORMULA_FILE"
    
    echo "Formula updated successfully!"
    echo ""
    echo "Updated formula content:"
    grep -E "(url|sha256)" "$FORMULA_FILE" | grep -v "#"
else
    echo "Error: $FORMULA_FILE not found!"
    exit 1
fi

# Clean up
rm -f "$TEMP_FILE"

echo ""
echo "Next steps:"
echo "1. Test the formula locally: brew install --build-from-source $FORMULA_FILE"
echo "2. Commit the updated formula"
echo "3. Push to homebrew tap repository"