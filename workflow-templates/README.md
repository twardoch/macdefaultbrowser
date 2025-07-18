# GitHub Actions Workflow Templates

## Overview

This directory contains GitHub Actions workflow templates for the macdefaultbrowser project. Due to GitHub App permission restrictions, these files need to be manually moved to `.github/workflows/`.

## Quick Setup

```bash
# Create the workflows directory
mkdir -p .github/workflows

# Copy the workflow files
cp workflow-templates/*.yml .github/workflows/

# Commit and push
git add .github/workflows/
git commit -m "Add GitHub Actions workflows"
git push
```

## Workflow Files

### 1. `build.yml` - Build and Test
- **Triggers**: Push to main, Pull requests
- **Purpose**: Continuous integration testing
- **Features**: Multi-platform testing, artifact upload

### 2. `release.yml` - Release Management
- **Triggers**: Git tags matching `v*.*.*`
- **Purpose**: Automated release creation
- **Features**: Code signing, notarization, multi-format artifacts

### 3. `ci.yml` - Continuous Integration
- **Triggers**: Daily schedule, manual dispatch
- **Purpose**: Comprehensive testing and monitoring
- **Features**: Performance tests, compatibility checks

## Required Secrets

Set these in your GitHub repository settings under Settings → Secrets and variables → Actions:

### Code Signing (Optional)
- `CODESIGN_CERTIFICATE` - Base64 encoded P12 certificate
- `CODESIGN_PASSWORD` - Certificate password
- `CODESIGN_IDENTITY` - Developer ID Application string

### Notarization (Optional)
- `APPLE_ID` - Apple ID email
- `TEAM_ID` - Apple Team ID
- `NOTARIZATION_PASSWORD` - App-specific password

## Usage

### Creating a Release

1. Tag your release:
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```

2. GitHub Actions will automatically:
   - Build and test
   - Sign and notarize (if configured)
   - Create release artifacts
   - Upload to GitHub Releases

### Monitoring

- Check the Actions tab in your repository
- Review build logs for any issues
- Monitor artifact uploads and releases

## Testing Locally

Before pushing tags, test the build system locally:

```bash
# Test build and test
./scripts/build-and-test.sh --verbose

# Test release process (dry run)
./scripts/release.sh --dry-run 1.2.3
```

## Support

For detailed setup instructions, see:
- `docs/GITHUB_ACTIONS_SETUP.md`
- `docs/BUILD.md`
- `docs/DEVELOPMENT.md`

## Security Note

Never commit certificates, passwords, or other sensitive information to the repository. Always use GitHub Secrets for sensitive data.