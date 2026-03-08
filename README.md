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

3. Configure the backend API:
   - Update `baseUrl` in `lib/core/constants/app_constants.dart`

4. Run the app:
```bash
flutter run
```

## Configuration

### Backend API

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

### ✅ Completed
- Project structure and configuration
- Authentication module (login, logout, session management)
- Core services (networking, storage, routing)
- Basic UI screens and navigation
- Role-based access control

### 🔄 In Progress
- Camera integration
- Document scanning
- PDF generation
- Upload queue management
- Document management

See [Implementation Status](docs/IMPLEMENTATION_STATUS.md) for detailed progress.

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