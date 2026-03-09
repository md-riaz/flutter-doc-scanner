# Release Workflow Documentation

## Overview

This document explains how to create a manual release of the Flutter Document Scanner app using the GitHub Actions workflow. The workflow builds a release APK and creates a GitHub release that anyone can download.

## Prerequisites

- Repository access with workflow permissions
- Access to GitHub Actions in the repository
- The workflow file: `.github/workflows/release.yml`

## How to Create a Release

### Step 1: Navigate to GitHub Actions

1. Go to the repository on GitHub: `https://github.com/md-riaz/flutter-doc-scanner`
2. Click on the **Actions** tab at the top of the repository
3. In the left sidebar, find and click on **Manual Release** workflow

### Step 2: Run the Workflow

1. Click the **Run workflow** dropdown button (top right)
2. You'll see a form with the following fields:

   - **Branch**: Select the branch to build from (usually `main` or `develop`)
   - **Release version**: Enter the version number (e.g., `1.0.0`, `1.2.3`, `2.0.0-beta`)
   - **Release notes**: Optionally add release notes describing changes in this version

3. Fill in the required fields:
   ```
   Branch: main
   Release version: 1.0.0
   Release notes: Initial release with document scanning features
   ```

4. Click the green **Run workflow** button

### Step 3: Monitor the Build

1. The workflow will appear in the workflow runs list
2. Click on the running workflow to see detailed progress
3. The build process includes:
   - Setting up the build environment (Java, Flutter)
   - Installing dependencies
   - Generating code with build_runner
   - Updating version in pubspec.yaml
   - Building the release APK
   - Creating a GitHub release
   - Uploading the APK to the release

4. The entire process typically takes 5-10 minutes

### Step 4: Access the Release

Once the workflow completes successfully:

1. Go to the **Releases** section of the repository
   - Click on **Releases** in the right sidebar, or
   - Navigate to: `https://github.com/md-riaz/flutter-doc-scanner/releases`

2. You'll see the new release with:
   - Release title: `Release v1.0.0` (or your version)
   - Git tag: `v1.0.0`
   - Release notes you provided
   - Downloadable APK file: `doc-scanner-v1.0.0.apk`
   - Build information (version, build number, commit SHA, date)

## Downloading and Installing the APK

### For End Users

1. **Download the APK**:
   - Go to the Releases page
   - Find the latest release
   - Click on the APK file (e.g., `doc-scanner-v1.0.0.apk`) to download

2. **Enable Installation from Unknown Sources** (Android):
   - Go to Settings → Security (or Apps & notifications)
   - Enable "Install unknown apps" or "Unknown sources"
   - Select your browser or file manager and allow installations

3. **Install the App**:
   - Open the downloaded APK file from your Downloads folder
   - Tap "Install"
   - Wait for installation to complete
   - Tap "Open" to launch the app

## Workflow Details

### Version Management

The workflow automatically handles versioning:

- **Version Name**: Uses the input you provide (e.g., `1.0.0`)
- **Build Number**: Uses the GitHub Actions run number (auto-incremented)
- **Format**: `version+buildNumber` (e.g., `1.0.0+123`)
- **Git Tag**: Creates a tag like `v1.0.0`

### Build Configuration

- **Build Type**: Release (optimized, production-ready)
- **Flutter Version**: 3.24.5 (stable)
- **Java Version**: 17 (Zulu distribution)
- **Android SDK**: 34
- **Min SDK**: 21 (Android 5.0+)

### APK Signing

**Current Configuration**: The release APK uses debug signing for simplicity.

**For Production Use**: You should configure proper release signing:

1. Generate a keystore file
2. Add keystore credentials to GitHub Secrets
3. Update `android/app/build.gradle` to use release signing
4. Update the workflow to use the keystore

See the [Android Signing Documentation](#android-release-signing-setup-optional) below for details.

### Artifacts

The workflow creates two types of artifacts:

1. **GitHub Release Asset**: The APK attached to the release (permanent)
2. **Workflow Artifact**: Backup APK stored for 90 days (downloadable from Actions tab)

## Versioning Guidelines

### Semantic Versioning

Follow semantic versioning principles:

- **Major.Minor.Patch** (e.g., `1.2.3`)
- **Major**: Breaking changes or major feature releases
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, small improvements

### Version Examples

- `1.0.0` - Initial release
- `1.1.0` - Added new features
- `1.1.1` - Bug fixes
- `2.0.0` - Major update with breaking changes
- `2.0.0-beta` - Beta version of 2.0.0
- `2.0.0-rc.1` - Release candidate

## Troubleshooting

### Workflow Fails to Start

- **Check permissions**: Ensure you have write access to the repository
- **Check branch**: Make sure the branch you selected exists

### Build Fails

Common issues and solutions:

1. **Dependencies fail to install**:
   - Check if `pubspec.yaml` has correct dependencies
   - Review the workflow logs for specific error messages

2. **Code generation fails**:
   - Ensure all necessary annotations are in place
   - Check for syntax errors in generated code files

3. **Build fails**:
   - Review Flutter analyze errors in the logs
   - Check for platform-specific issues in `android/` directory

4. **Release creation fails**:
   - Check if a release with the same tag already exists
   - Ensure GitHub token has correct permissions

### APK Installation Issues

1. **Installation blocked**:
   - Enable "Install from Unknown Sources" in Android settings
   - Check if device allows app installations

2. **App crashes on launch**:
   - Check Android version (minimum Android 5.0 required)
   - Report the issue with device details

## Android Release Signing Setup (Optional)

For production releases, you should use proper release signing:

### 1. Generate a Keystore

```bash
keytool -genkey -v -keystore release-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias release
```

### 2. Add Secrets to GitHub

Add these secrets to your repository (Settings → Secrets and variables → Actions):

- `KEYSTORE_BASE64`: Base64-encoded keystore file
- `KEYSTORE_PASSWORD`: Keystore password
- `KEY_ALIAS`: Key alias (e.g., `release`)
- `KEY_PASSWORD`: Key password

### 3. Update build.gradle

Modify `android/app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            storeFile file(System.getenv("KEYSTORE_FILE"))
            storePassword System.getenv("KEYSTORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 4. Update Workflow

Add these steps before the build step in `.github/workflows/release.yml`:

```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/release-keystore.jks

- name: Build Release APK
  env:
    KEYSTORE_FILE: ${{ github.workspace }}/android/app/release-keystore.jks
    KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
    KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
    KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
  run: flutter build apk --release
```

## Best Practices

1. **Version Planning**: Plan versions in advance and communicate with your team
2. **Release Notes**: Always provide clear, concise release notes
3. **Testing**: Test the APK on real devices before announcing the release
4. **Changelog**: Maintain a CHANGELOG.md file for tracking changes
5. **Backup**: Keep workflow artifacts as backup (automatically retained for 90 days)
6. **Security**: Use proper release signing for production releases
7. **Tagging**: Use consistent tag naming (e.g., always prefix with `v`)

## Release Checklist

Before creating a release:

- [ ] All features are tested and working
- [ ] Code is reviewed and merged to main branch
- [ ] Version number is decided (follow semantic versioning)
- [ ] Release notes are prepared
- [ ] Previous issues are closed or documented
- [ ] Documentation is up to date

After creating a release:

- [ ] Test the APK on real devices
- [ ] Verify the release page looks correct
- [ ] Announce the release to users
- [ ] Update project documentation
- [ ] Monitor for issues and feedback

## Support

If you encounter issues with the release workflow:

1. Check the workflow logs in GitHub Actions
2. Review this documentation
3. Check the Flutter and Android build logs
4. Open an issue in the repository with details

## Additional Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Semantic Versioning](https://semver.org/)
