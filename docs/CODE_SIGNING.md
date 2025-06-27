# Code Signing and Notarization Guide

## Overview

Code signing and notarization are important for distributing macOS applications outside the App Store. They help users trust that the software hasn't been tampered with and comes from a known developer.

## Code Signing

### Prerequisites

1. Apple Developer Account (free or paid)
2. Developer ID Application certificate (requires paid account)
3. Xcode Command Line Tools

### Creating a Certificate

1. Sign in to [Apple Developer](https://developer.apple.com)
2. Go to Certificates, Identifiers & Profiles
3. Create a new certificate:
   - Type: Developer ID Application
   - Follow the instructions to create a CSR
   - Download and install the certificate

### Signing the Binary

Add code signing to the Makefile:

```makefile
# Code signing configuration
CODESIGN_IDENTITY ?= "Developer ID Application: Your Name (TEAM_ID)"
CODESIGN_FLAGS = --force --options runtime --timestamp

# Sign the binary
.PHONY: sign
sign: build
	@echo "Signing $(BUILD_DIR)/$(BINARY_NAME)..."
	codesign $(CODESIGN_FLAGS) --sign "$(CODESIGN_IDENTITY)" $(BUILD_DIR)/$(BINARY_NAME)
	@echo "Verifying signature..."
	codesign --verify --verbose $(BUILD_DIR)/$(BINARY_NAME)
```

### Environment Variables

Set your signing identity:
```bash
export CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
```

Or create a `.env` file (don't commit this):
```
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
```

## Notarization

### Why Notarize?

Starting with macOS 10.15 (Catalina), apps distributed outside the App Store must be notarized to run without warnings.

### Notarization Process

1. Sign the binary (as above)
2. Create a ZIP for notarization:
   ```bash
   zip -j macdefaultbrowser.zip build/macdefaultbrowser
   ```

3. Submit for notarization:
   ```bash
   xcrun notarytool submit macdefaultbrowser.zip \
     --apple-id "your-apple-id@example.com" \
     --team-id "TEAM_ID" \
     --password "app-specific-password" \
     --wait
   ```

4. Staple the ticket (for installers):
   ```bash
   xcrun stapler staple dist/macdefaultbrowser-1.2.1.pkg
   ```

### Automation Script

Create `scripts/notarize.sh`:

```bash
#!/bin/bash
set -e

BINARY_PATH="build/macdefaultbrowser"
ZIP_PATH="macdefaultbrowser-notarize.zip"

# Check if binary exists
if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    echo "Run 'make build' first"
    exit 1
fi

# Create ZIP for notarization
echo "Creating ZIP for notarization..."
zip -j "$ZIP_PATH" "$BINARY_PATH"

# Submit for notarization
echo "Submitting for notarization..."
xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "$NOTARIZATION_PASSWORD" \
    --wait

# Clean up
rm "$ZIP_PATH"

echo "Notarization complete!"
```

### GitHub Actions Integration

Add to `.github/workflows/release.yml`:

```yaml
- name: Code Sign Binary
  if: env.CODESIGN_IDENTITY != ''
  env:
    CODESIGN_IDENTITY: ${{ secrets.CODESIGN_IDENTITY }}
  run: |
    # Import certificate from secrets
    echo "${{ secrets.CODESIGN_CERTIFICATE }}" | base64 --decode > certificate.p12
    security create-keychain -p actions temp.keychain
    security import certificate.p12 -k temp.keychain -P "${{ secrets.CODESIGN_PASSWORD }}" -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple: -s -k actions temp.keychain
    
    # Sign the binary
    codesign --force --options runtime --timestamp --sign "$CODESIGN_IDENTITY" build/macdefaultbrowser
    
    # Clean up
    security delete-keychain temp.keychain
    rm certificate.p12

- name: Notarize Binary
  if: env.APPLE_ID != ''
  env:
    APPLE_ID: ${{ secrets.APPLE_ID }}
    TEAM_ID: ${{ secrets.TEAM_ID }}
    NOTARIZATION_PASSWORD: ${{ secrets.NOTARIZATION_PASSWORD }}
  run: |
    # Create ZIP for notarization
    zip -j macdefaultbrowser.zip build/macdefaultbrowser
    
    # Submit for notarization
    xcrun notarytool submit macdefaultbrowser.zip \
      --apple-id "$APPLE_ID" \
      --team-id "$TEAM_ID" \
      --password "$NOTARIZATION_PASSWORD" \
      --wait
```

## Required Secrets for GitHub Actions

Add these secrets to your repository:
- `CODESIGN_IDENTITY`: Your Developer ID (e.g., "Developer ID Application: Name (TEAM)")
- `CODESIGN_CERTIFICATE`: Base64-encoded .p12 certificate
- `CODESIGN_PASSWORD`: Password for the .p12 certificate
- `APPLE_ID`: Your Apple ID email
- `TEAM_ID`: Your Apple Developer Team ID
- `NOTARIZATION_PASSWORD`: App-specific password for notarization

## Testing Code Signing

Verify the signature:
```bash
codesign --verify --verbose build/macdefaultbrowser
spctl --assess --type execute --verbose build/macdefaultbrowser
```

Check entitlements:
```bash
codesign --display --entitlements - build/macdefaultbrowser
```

## Troubleshooting

1. **"unrecognized blob type"**: Certificate not found. Check identity name.
2. **"resource fork, Finder information, or similar detritus"**: Clean build and retry.
3. **Notarization fails**: Ensure binary is signed with hardened runtime (`--options runtime`).
4. **Gatekeeper blocks**: Binary might need notarization or proper signing.

## Optional: Ad-hoc Signing

For local testing without a Developer ID:
```bash
codesign --force --deep --sign - build/macdefaultbrowser
```

Note: Ad-hoc signed binaries won't pass Gatekeeper on other machines.