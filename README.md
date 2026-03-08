# Flutter Document Scanner

Android-first Flutter application for document scanning, PDF generation, secure cloud upload, document management, and workflow integration.

## Features

- 📷 Camera-based document scanning with edge detection
- 🎨 Image enhancement (brightness, contrast, shadow removal)
- 📄 Multi-page PDF generation
- ☁️ Secure cloud upload with retry mechanism
- 📁 Project/folder-based organization
- 🔐 Role-based access control (Admin, User, Viewer)
- 📊 Upload queue management
- 🔄 Offline support with sync
- 🎯 Clean architecture with Riverpod

## Project Structure

```
lib/
├── app/                    # App configuration
│   ├── router.dart        # GoRouter setup
│   └── theme/             # App theming
├── core/                   # Core utilities
│   ├── constants/         # App constants and endpoints
│   ├── errors/            # Exception handling
│   ├── network/           # Dio HTTP client
│   └── storage/           # Secure storage
├── features/              # Feature modules
│   ├── auth/             # Authentication
│   ├── scanner/          # Document scanning
│   ├── documents/        # Document management
│   ├── upload_queue/     # Upload management
│   ├── projects/         # Project organization
│   └── settings/         # App settings
└── shared/               # Shared widgets and models
```

## Documentation

Comprehensive documentation is available in the `/docs` folder:

### 📱 Visual Guides
- **[Screenshots & UI Guide](docs/SCREENSHOTS.md)** - Detailed mockups of all app screens
- **[UI Wireframes](docs/UI_WIREFRAMES.md)** - Complete wireframes with design specifications

### 📚 Technical Documentation
- [Technical Specification](docs/TECHNICAL_SPECIFICATION.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Features](docs/FEATURES.md)
- [Technology Stack](docs/TECH_STACK.md)
- [Data Models](docs/DATA_MODELS.md)
- [API Specification](docs/API_SPECIFICATION.md)
- [User Flows](docs/USER_FLOWS.md)
- [Development Plan](docs/DEVELOPMENT_PLAN.md)
- [Security](docs/SECURITY.md)
- [UI Screens](docs/UI_SCREENS.md)
- [Implementation Status](docs/IMPLEMENTATION_STATUS.md)

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android device or emulator

### Mock Mode (No Backend Required)

**The app is currently configured to run in MOCK MODE**, which means you can test all functionality without a backend server.

#### Mock Credentials

Use these credentials to test the app:

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin123` | Admin |
| `user` | `user123` | User |
| `viewer` | `viewer123` | Viewer |

Any other credentials will be rejected.

#### Enabling/Disabling Mock Mode

Mock mode is controlled in `lib/core/constants/app_constants.dart`:

```dart
static const bool useMockApi = true; // true = mock mode, false = real backend
```

### Installation

1. Clone the repository:
```bash
git clone https://github.com/md-riaz/flutter-doc-scanner.git
cd flutter-doc-scanner
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app (Mock Mode - No Backend Required):
```bash
flutter run
```

4. Login with mock credentials (see Mock Mode section above)

### When Backend is Available

1. Set `useMockApi = false` in `lib/core/constants/app_constants.dart`
2. Update `baseUrl` with your backend URL
3. Ensure backend implements the API contract from `/docs/API_SPECIFICATION.md`

## Configuration

### Mock Mode (Current Default)

The app runs in mock mode by default. See [AGENTS.md](AGENTS.md) for detailed documentation about:
- Mock authentication
- Test credentials
- Mock data providers
- Switching to real backend

### Backend API (When Available)

Update the API base URL in `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-api.example.com';
```

### Permissions

The app requires the following Android permissions:
- Camera (for document scanning)
- Storage (for saving PDFs)
- Internet (for API communication)
- Network State (for connectivity detection)

All permissions are declared in `android/app/src/main/AndroidManifest.xml`.

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Routing**: GoRouter
- **HTTP Client**: Dio
- **Local Database**: Drift (SQLite)
- **Secure Storage**: flutter_secure_storage
- **Camera**: camera package
- **PDF Generation**: pdf package
- **Background Tasks**: workmanager

## Architecture

The app follows **Clean Architecture** principles with three layers:

1. **Presentation Layer**: UI, screens, and state management
2. **Domain Layer**: Business logic and entities
3. **Data Layer**: API clients, repositories, and local storage

## Current Status

**Overall Progress: ~80% of MVP Complete** ✅

### ✅ Completed Features
- ✅ Authentication module (login, logout, session management)
- ✅ Camera & scanning with live preview
- ✅ Multi-page document capture
- ✅ Image enhancement and processing
- ✅ PDF generation with metadata
- ✅ Local database (Drift/SQLite)
- ✅ Document management (list, search, delete, share)
- ✅ Upload queue with retry logic
- ✅ Project organization with color coding
- ✅ Complete UI for all core screens

### 🔄 Next Steps
- Advanced features (better edge detection, filters, background upload)
- Testing & polish
- Performance optimization

See **[Implementation Status](docs/IMPLEMENTATION_STATUS.md)** for detailed progress and **[Screenshots](docs/SCREENSHOTS.md)** to see how the app looks.

## Development Roadmap

1. **Phase 1**: Foundation ✅ Complete
2. **Phase 2**: Camera & Scanning (2 weeks)
3. **Phase 3**: PDF Generation (1 week)
4. **Phase 4**: Upload System (2 weeks)
5. **Phase 5**: Document Management (1.5 weeks)
6. **Phase 6**: Testing & Polish (1.5 weeks)

Total: ~12-14 weeks for production-ready MVP

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary software. All rights reserved.

## Support

For issues and questions:
- Create an issue in the GitHub repository
- Contact: [Your Contact Information]

## Acknowledgments

Built following the technical specification and requirements outlined in the project documentation.