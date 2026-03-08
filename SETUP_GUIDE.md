# Flutter App Setup & Running Guide

This guide will help you set up Flutter and run the Document Scanner app to take screenshots.

## Prerequisites

1. **Operating System**: Windows, macOS, or Linux
2. **Disk Space**: At least 2GB free
3. **Internet Connection**: Required for initial setup

## Step 1: Install Flutter

### Option A: Using Flutter SDK (Recommended)

#### On Linux/macOS:

```bash
# Download Flutter
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (add this to ~/.bashrc or ~/.zshrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Reload shell
source ~/.bashrc  # or source ~/.zshrc

# Verify installation
flutter doctor
```

#### On Windows:

1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add `C:\src\flutter\bin` to your PATH
4. Open new terminal and run `flutter doctor`

### Option B: Using Snap (Linux only)

```bash
sudo snap install flutter --classic
flutter doctor
```

### Option C: Using Homebrew (macOS only)

```bash
brew install --cask flutter
flutter doctor
```

## Step 2: Install Dependencies

### Android Studio (for Android development)

1. Download from: https://developer.android.com/studio
2. Install Android SDK and Android SDK Command-line Tools
3. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```

### VS Code (Alternative to Android Studio)

1. Download from: https://code.visualstudio.com/
2. Install Flutter and Dart extensions

## Step 3: Set Up the Project

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/md-riaz/flutter-doc-scanner.git
cd flutter-doc-scanner

# Install dependencies
flutter pub get

# Generate database code
dart run build_runner build --delete-conflicting-outputs

# Verify everything is working
flutter doctor -v
```

## Step 4: Run the App

### Option A: Run on Android Emulator

1. Start Android emulator from Android Studio or use:
   ```bash
   flutter emulators
   flutter emulators --launch <emulator_id>
   ```

2. Run the app:
   ```bash
   flutter run
   ```

### Option B: Run on Physical Device

1. Enable Developer Options and USB Debugging on your Android device
2. Connect device via USB
3. Run:
   ```bash
   flutter devices  # Verify device is detected
   flutter run
   ```

### Option C: Run on Web

```bash
flutter run -d chrome
```

### Option D: Run on Linux Desktop

```bash
flutter run -d linux
```

## Step 5: Take Screenshots

### Using Flutter DevTools

1. Run the app:
   ```bash
   flutter run
   ```

2. Press `v` in the terminal to open DevTools
3. Navigate to the "Inspector" tab
4. Click "Screenshot" button

### Using Android Studio

1. Run app from Android Studio
2. Go to View > Tool Windows > Logcat
3. Click camera icon in the Device Frame section

### Manual Screenshots

#### On Android Emulator:
- Press the camera icon in the emulator toolbar
- Screenshots saved to: `~/.android/avd/<emulator_name>.avd/screenshots/`

#### On Physical Android Device:
- Press Power + Volume Down simultaneously
- Screenshots in Gallery app

#### On Web:
- Use browser's built-in screenshot tool (F12 > DevTools > Menu > Capture screenshot)

## Step 6: Test with Mock Credentials

Login with one of these test accounts:

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin123` | Admin |
| `user` | `user123` | User |
| `viewer` | `viewer123` | Viewer |

## Screens to Screenshot

1. **Splash Screen** - Initial loading screen
2. **Login Screen** - Enter mock credentials
3. **Home Screen** - Dashboard with 5 menu options
4. **Scan Camera** - Document scanning interface
5. **Scan Review** - Multi-page review screen
6. **PDF Generation** - PDF creation with metadata
7. **Documents List** - Browse saved documents
8. **Projects Screen** - Project management with colors
9. **Upload Queue** - Upload status with progress
10. **Settings Screen** - App settings

## Navigation Flow

```
Splash → Login → Home
         ↓
    ┌────┴────┬────────┬──────────┬─────────┐
    ↓         ↓        ↓          ↓         ↓
  Scan   Documents  Projects   Upload   Settings
    ↓                                    Queue
Preview
    ↓
  Review
    ↓
PDF Gen
```

## Troubleshooting

### "Flutter not found"
- Ensure Flutter is in your PATH
- Restart terminal after adding to PATH

### "Android licenses not accepted"
```bash
flutter doctor --android-licenses
```

### "No devices found"
- Start an emulator or connect a physical device
- Run `flutter devices` to check

### "Build failed - drift code missing"
```bash
dart run build_runner build --delete-conflicting-outputs
```

### "Camera permission denied"
- On emulator: Use camera2 API (already configured)
- On device: Grant camera permission when prompted

### Build errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Using GitHub Actions CI

This repository includes a GitHub Actions workflow that automatically:
- Builds the app on every push
- Runs tests
- Generates APK artifacts

The workflow is in `.github/workflows/flutter-ci.yml`

To download build artifacts:
1. Go to Actions tab on GitHub
2. Select the latest workflow run
3. Download APK from Artifacts section

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [API Specification](docs/API_SPECIFICATION.md)
- [Implementation Status](docs/IMPLEMENTATION_STATUS.md)

## Quick Commands Reference

```bash
# Install dependencies
flutter pub get

# Generate code
dart run build_runner build

# Run app
flutter run

# Run on specific device
flutter run -d <device_id>

# Build APK
flutter build apk

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Clean build
flutter clean
```

## Environment Information

- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=3.0.0
- **Android API Level**: 21+ (Android 5.0+)
- **iOS**: Not configured (Android-first app)

## Mock Mode

The app runs in **mock mode** by default, meaning:
- No backend server required
- All features work offline
- Mock data and APIs are used
- Perfect for testing and screenshots

To switch to real backend:
1. Edit `lib/core/constants/app_constants.dart`
2. Set `useMockApi = false`
3. Update `baseUrl` to your backend URL

## Support

For issues or questions:
- Check [Implementation Status](docs/IMPLEMENTATION_STATUS.md)
- Review [Technical Specification](docs/TECHNICAL_SPECIFICATION.md)
- Create an issue on GitHub
