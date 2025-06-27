#!/bin/bash
# this_file: scripts/notarize.sh
set -e

# Script to notarize macdefaultbrowser binary
# Requires: APPLE_ID, TEAM_ID, and NOTARIZATION_PASSWORD environment variables

BINARY_PATH="build/macdefaultbrowser"
ZIP_PATH="macdefaultbrowser-notarize.zip"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check required environment variables
check_env() {
    local missing=0
    
    if [ -z "$APPLE_ID" ]; then
        echo -e "${RED}Error: APPLE_ID environment variable not set${NC}"
        missing=1
    fi
    
    if [ -z "$TEAM_ID" ]; then
        echo -e "${RED}Error: TEAM_ID environment variable not set${NC}"
        missing=1
    fi
    
    if [ -z "$NOTARIZATION_PASSWORD" ]; then
        echo -e "${RED}Error: NOTARIZATION_PASSWORD environment variable not set${NC}"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        echo -e "${YELLOW}Required environment variables:${NC}"
        echo "  APPLE_ID - Your Apple ID email"
        echo "  TEAM_ID - Your Apple Developer Team ID"
        echo "  NOTARIZATION_PASSWORD - App-specific password for notarization"
        echo ""
        echo "You can set these in your shell:"
        echo "  export APPLE_ID=\"your-apple-id@example.com\""
        echo "  export TEAM_ID=\"TEAM_ID\""
        echo "  export NOTARIZATION_PASSWORD=\"xxxx-xxxx-xxxx-xxxx\""
        exit 1
    fi
}

# Check if binary exists
if [ ! -f "$BINARY_PATH" ]; then
    echo -e "${RED}Error: Binary not found at $BINARY_PATH${NC}"
    echo "Run 'make build' first"
    exit 1
fi

# Check if binary is signed
echo "Checking code signature..."
if ! codesign --verify --verbose "$BINARY_PATH" 2>&1 | grep -q "satisfies its Designated Requirement"; then
    echo -e "${RED}Error: Binary is not properly signed${NC}"
    echo "Run 'make sign' first with a valid Developer ID"
    exit 1
fi

# Check for hardened runtime
if ! codesign --display --verbose "$BINARY_PATH" 2>&1 | grep -q "flags=0x10000(runtime)"; then
    echo -e "${YELLOW}Warning: Binary may not have hardened runtime enabled${NC}"
    echo "Notarization may fail without --options runtime flag during signing"
fi

# Check environment variables
check_env

# Create ZIP for notarization
echo -e "${GREEN}Creating ZIP for notarization...${NC}"
zip -j "$ZIP_PATH" "$BINARY_PATH"

# Submit for notarization
echo -e "${GREEN}Submitting for notarization...${NC}"
echo "Apple ID: $APPLE_ID"
echo "Team ID: $TEAM_ID"

# Submit and wait for result
if xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "$NOTARIZATION_PASSWORD" \
    --wait; then
    echo -e "${GREEN}Notarization successful!${NC}"
    
    # For .pkg files, we would staple the ticket here
    # Since this is just a binary, stapling is not applicable
    echo -e "${YELLOW}Note: Stapling is not applicable for standalone binaries${NC}"
    echo "The binary is now notarized and can be distributed"
else
    echo -e "${RED}Notarization failed${NC}"
    echo "Check the error messages above for details"
    exit 1
fi

# Clean up
rm -f "$ZIP_PATH"

echo -e "${GREEN}Notarization complete!${NC}"
echo "The notarized binary is at: $BINARY_PATH"