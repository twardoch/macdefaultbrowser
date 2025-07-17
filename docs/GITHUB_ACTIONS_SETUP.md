# GitHub Actions Setup Guide

## Overview

This guide explains how to set up the GitHub Actions workflows for automated building, testing, and releasing of macdefaultbrowser.

## Workflow Files

The workflow files are located in `workflow-templates/` and need to be manually moved to `.github/workflows/` due to permission restrictions.

### Required Workflows

1. **build.yml** - Build and test on every push/PR
2. **release.yml** - Create releases on git tags
3. **ci.yml** - Daily comprehensive testing

## Manual Setup Instructions

### Step 1: Create Workflow Directory

```bash
mkdir -p .github/workflows
```

### Step 2: Copy Workflow Files

```bash
cp workflow-templates/*.yml .github/workflows/
```

### Step 3: Set Up Repository Secrets

In your GitHub repository settings, add these secrets:

#### Code Signing (Optional but recommended)
- `CODESIGN_CERTIFICATE`: Base64 encoded P12 certificate
- `CODESIGN_PASSWORD`: Certificate password
- `CODESIGN_IDENTITY`: Developer ID Application string

#### Notarization (Optional but recommended)
- `APPLE_ID`: Your Apple ID email
- `TEAM_ID`: Your Apple Team ID
- `NOTARIZATION_PASSWORD`: App-specific password

### Step 4: Enable GitHub Actions

1. Go to repository Settings → Actions → General
2. Enable "Allow all actions and reusable workflows"
3. Set workflow permissions to "Read and write permissions"

## Workflow Details

### Build and Test Workflow (`build.yml`)

**Triggers:**
- Push to main branch
- Pull requests to main branch

**Features:**
- Tests on multiple macOS versions (13, 14, latest)
- Comprehensive testing with verbose output
- Artifact upload for debugging
- Binary functionality verification

**Matrix Strategy:**
```yaml
strategy:
  matrix:
    os: [macos-13, macos-14, macos-latest]
```

### Release Workflow (`release.yml`)

**Triggers:**
- Git tags matching `v*.*.*` pattern

**Features:**
- Automatic version extraction from tags
- Code signing and notarization
- Multiple artifact formats (DMG, PKG, tar.gz, zip)
- SHA256 checksums
- GitHub Release creation

**Artifacts Created:**
- `macdefaultbrowser-v1.2.3.dmg`
- `macdefaultbrowser-v1.2.3.pkg`
- `macdefaultbrowser-v1.2.3.tar.gz`
- `macdefaultbrowser-v1.2.3.zip`
- SHA256 checksums for all files

### Continuous Integration Workflow (`ci.yml`)

**Triggers:**
- Daily at 2 AM UTC
- Manual dispatch

**Features:**
- Comprehensive testing
- Performance benchmarks
- Compatibility testing
- Code signing validation

## Environment Variables

### Build Environment

Set these in your workflow environment:

```yaml
env:
  CODESIGN_IDENTITY: ${{ secrets.CODESIGN_IDENTITY }}
  APPLE_ID: ${{ secrets.APPLE_ID }}
  TEAM_ID: ${{ secrets.TEAM_ID }}
  NOTARIZATION_PASSWORD: ${{ secrets.NOTARIZATION_PASSWORD }}
```

### Local Development

For local testing of the same commands:

```bash
export CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
export APPLE_ID="your@apple.id"
export TEAM_ID="TEAM_ID"
export NOTARIZATION_PASSWORD="app-specific-password"
```

## Release Process

### Creating a Release

1. **Tag the release:**
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```

2. **GitHub Actions will automatically:**
   - Build the project
   - Run tests
   - Sign the binary (if certificates are configured)
   - Create distribution packages
   - Notarize (if Apple ID is configured)
   - Create GitHub Release
   - Upload all artifacts

### Release Artifacts

Each release includes:
- **DMG**: Disk image for manual installation
- **PKG**: Installer package for enterprise deployment
- **tar.gz**: Binary archive for Unix systems
- **zip**: Binary archive for general use
- **SHA256SUMS**: Checksum file for verification

## Security Configuration

### Code Signing Certificate

1. **Export certificate from Keychain:**
   ```bash
   # Export as P12 file
   # Then encode as base64
   base64 -i certificate.p12 | pbcopy
   ```

2. **Add to GitHub Secrets:**
   - `CODESIGN_CERTIFICATE`: The base64 encoded P12 content
   - `CODESIGN_PASSWORD`: The password for the P12 file
   - `CODESIGN_IDENTITY`: Full Developer ID string

### Notarization Setup

1. **Create app-specific password:**
   - Go to appleid.apple.com
   - Sign in and generate app-specific password
   - Use this as `NOTARIZATION_PASSWORD`

2. **Find your Team ID:**
   ```bash
   # Check your certificates
   security find-identity -v -p codesigning
   ```

## Troubleshooting

### Common Issues

1. **Build Failures:**
   - Check macOS version compatibility
   - Verify Swift version requirements
   - Review build logs in Actions tab

2. **Code Signing Issues:**
   - Verify certificate is valid
   - Check CODESIGN_IDENTITY format
   - Ensure certificate password is correct

3. **Notarization Problems:**
   - Verify Apple ID credentials
   - Check Team ID format
   - Ensure app-specific password is correct

### Debug Commands

```bash
# Test locally
./scripts/build-and-test.sh --verbose

# Test signing
./scripts/build-and-test.sh --sign

# Test release process
./scripts/release.sh --dry-run 1.0.0
```

## Monitoring

### GitHub Actions Dashboard

Monitor workflow runs in:
- Repository → Actions tab
- Check for failed builds
- Review artifact uploads
- Monitor release creation

### Notifications

Set up notifications for:
- Build failures
- Release completions
- Security alerts

## Best Practices

1. **Always test locally first:**
   ```bash
   ./scripts/build-and-test.sh --verbose
   ```

2. **Use semantic versioning:**
   ```bash
   git tag v1.2.3  # Not 1.2.3 or version-1.2.3
   ```

3. **Keep secrets secure:**
   - Use GitHub repository secrets
   - Never commit certificates or passwords
   - Rotate credentials regularly

4. **Monitor build times:**
   - Optimize slow builds
   - Use caching where appropriate
   - Review resource usage

## Migration from Existing Workflows

If you have existing workflows, compare and merge:

1. **Backup existing workflows:**
   ```bash
   cp .github/workflows/*.yml backup/
   ```

2. **Review differences:**
   ```bash
   diff -u old-build.yml workflow-templates/build.yml
   ```

3. **Test thoroughly:**
   ```bash
   # Test all workflows before merging
   ./scripts/build-and-test.sh --verbose
   ```

## Support

For issues with GitHub Actions:
1. Check the Actions tab for detailed logs
2. Review the workflow files for syntax errors
3. Verify all secrets are properly configured
4. Test the build scripts locally first

The workflow files are designed to be robust and handle most common scenarios, but may need customization for specific requirements.