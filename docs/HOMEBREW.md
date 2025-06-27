# Homebrew Installation Guide

## Installing macdefaultbrowser via Homebrew

### Option 1: From a Tap (Recommended)

Once a Homebrew tap is created:

```bash
brew tap twardoch/tap
brew install macdefaultbrowser
```

### Option 2: Direct Formula Installation

For testing or before the tap is available:

```bash
# Download the formula
curl -O https://raw.githubusercontent.com/twardoch/macdefaultbrowser/main/macdefaultbrowser.rb

# Install from the formula file
brew install --build-from-source macdefaultbrowser.rb
```

## Creating a Homebrew Tap

To create a tap for easier distribution:

1. Create a new GitHub repository named `homebrew-tap`
2. Create directory structure:
   ```
   Formula/
   └── macdefaultbrowser.rb
   ```
3. Copy the formula file to `Formula/macdefaultbrowser.rb`
4. Users can then install using: `brew tap twardoch/tap && brew install macdefaultbrowser`

## Updating the Formula

After creating a new release:

1. Run the update script:
   ```bash
   ./scripts/update-homebrew-formula.sh v1.2.1
   ```

2. The script will:
   - Download the release tarball
   - Calculate the SHA256 checksum
   - Update the formula file

3. Test the updated formula:
   ```bash
   brew install --build-from-source macdefaultbrowser.rb
   ```

4. Commit and push the updated formula to the tap repository

## Formula Structure

The formula includes:
- **desc**: Brief description of the tool
- **homepage**: Project homepage
- **url**: Source tarball URL for the specific version
- **sha256**: Checksum for integrity verification
- **license**: MIT license declaration
- **head**: Support for installing development version
- **depends_on**: Requirements (macOS and Xcode)
- **install**: Build and installation instructions
- **test**: Basic functionality test

## Troubleshooting

If installation fails:

1. Ensure Xcode Command Line Tools are installed:
   ```bash
   xcode-select --install
   ```

2. Check that you're on a supported macOS version (10.15+)

3. Try building manually:
   ```bash
   git clone https://github.com/twardoch/macdefaultbrowser.git
   cd macdefaultbrowser
   make build
   ```