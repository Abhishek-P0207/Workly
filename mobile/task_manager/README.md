# 📱 Task Manager Mobile App

> Cross-platform Flutter app for intelligent task management with intelligent classification.

## ✨ Features

- **Task Preview**: Real-time classification preview before saving
- **Smart Forms**: Auto-fill category, priority, and entities from description
- **Beautiful UI**: Material Design 3 with modern aesthetics
- **Task Management**: Create, view, update, and delete tasks
- **Advanced Filtering**: Filter by category, status, and priority
- **History Tracking**: View complete task change history
- **Cross-Platform**: Single codebase for iOS, Android, and Web

## 🛠 Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **UI**: Material Design 3
- **HTTP Client**: http package
- **Backend**: RESTful API integration

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.x or higher
- Dart SDK
- Android Studio / Xcode (for mobile)
- Chrome (for web)

### Installation

```bash
# Get dependencies
flutter pub get

# Run on your preferred platform
flutter run                    # Default device
flutter run -d chrome          # Web
flutter run -d android         # Android
flutter run -d ios             # iOS
```

### Backend Configuration

By default, the backend API is the deployed version hosted on Render.

Update the API base URL in your app:
```dart
// lib/core/constants/api_constants.dart
const String baseUrl = 'http://localhost:3000/api';
```

## 📱 App Structure

```
lib/
├── core/
│   ├── constants/       # API URLs, app constants
│   └── theme/           # App theme configuration
├── features/
│   └── tasks/
│       ├── data/        # Models, repositories
│       ├── domain/      # Business logic
│       └── presentation/
│           ├── pages/   # Screens
│           ├── widgets/ # Reusable components
│           └── providers/ # State management
└── main.dart            # App entry point
```

## 🎨 Key Screens

- **Dashboard**: Task overview showing the pending and in-progress tasks with filters and statistics
- **Create Task**: Form with preview and auto-fill
- **Task List**: Filterable, paginated task list

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## 📦 Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🔧 Development

```bash
flutter analyze          # Static analysis
flutter format .         # Format code
flutter clean           # Clean build files
```