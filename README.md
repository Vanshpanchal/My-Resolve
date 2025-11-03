# MyResolve

![Build](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-Flutter-blueviolet)
![Dart](https://img.shields.io/badge/dart-3.8%2B-blue)
![Flutter](https://img.shields.io/badge/flutter-3.0%2B-blue)

> **Build better habits together.** Create, share, and join accountability pacts with a vibrant community. MyResolve helps you turn commitments into lasting change through social accountability and timely reminders.

---

## ✨ Features

### 🎯 Core Features

- **Create Pacts**: Set personal or group commitments with clear goals and timelines
- **Join via QR Code**: Scan a generated QR code or enter a join code to instantly join pacts
- **Share Invites**: Share high-quality QR images (not just links) via WhatsApp, Telegram, email, etc.
- **Check-ins**: Track progress with daily or custom check-in intervals
- **Social Feed**: See updates from your pacts and celebrate wins together
- **Push Notifications**: Stay accountable with timely reminders via Firebase Cloud Messaging (FCM)
- **User Profiles**: Customize your profile and track personal stats

### 🏗️ Technical Highlights

- **Cross-platform**: Android, iOS, Web, macOS, Windows, Linux (Flutter framework)
- **State Management**: Provider pattern for clean, testable code
- **Local Storage**: Hive for fast caching + SharedPreferences for settings
- **Real-time Notifications**: Firebase Cloud Messaging + local notifications
- **Responsive UI**: Sizer for adaptive layouts across screen sizes
- **Secure Auth**: Firebase Authentication with flutter_secure_storage for tokens

---

## 📸 Previews

![Preview-1](https://github.com/Vanshpanchal/My-Resolve/blob/cc81e7188944f4d40c9dd28f09c882b8209bb08b/previews/preview%20(1).png)
![Preview-1](https://github.com/Vanshpanchal/My-Resolve/blob/cc81e7188944f4d40c9dd28f09c882b8209bb08b/previews/preview%20(2).png)
![Preview-1](https://github.com/Vanshpanchal/My-Resolve/blob/cc81e7188944f4d40c9dd28f09c882b8209bb08b/previews/preview%20(3).png)
![Preview-1](https://github.com/Vanshpanchal/My-Resolve/blob/cc81e7188944f4d40c9dd28f09c882b8209bb08b/previews/preview%20(4).png)

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0+) — [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK (3.8+) — comes with Flutter
- Android Studio / Xcode — for device/emulator setup
- Git

### Installation

1. **Clone the repository**

      ```bash
      git clone https://github.com/Vanshpanchal/My-Resolve.git
      cd My-Resolve
      ```

2. **Install dependencies**

      ```powershell
      flutter pub get
      ```

3. **Configure Firebase** (required for notifications)

      - Download `google-services.json` from Firebase Console
      - Place it in `android/app/`
      - For iOS, download `GoogleService-Info.plist` and add to `ios/Runner/`
      - Ensure your Firebase project has Cloud Messaging enabled

4. **Run the app**

      ```powershell
      # On a connected device or emulator
      flutter run

      # Or specify a target device
      flutter run -d windows
      flutter run -d emulator-5554
      ```

---

## 📱 Usage

### Create a Pact

1. Open the app and tap the **Create** tab
2. Enter pact title, description, and members
3. Set a start date and check-in frequency
4. Tap **Create Pact**

### Invite Others

1. Open a pact → Tap the **Share** icon
2. Select **Share QR Code** to send a high-quality image
3. Share via your favorite messaging app
4. Others can scan the QR or tap the link to join instantly

### Join a Pact

1. Tap the **QR Scanner** FAB (floating action button) on the home screen
2. Point at a QR code and let it scan
3. Confirm to join the pact
4. **Alternative**: Tap "Enter Code Manually" and paste the join code

### Enable Notifications

1. Open the app — you'll be prompted for notification permission
2. Grant permission to receive reminders and updates
3. Adjust reminder times in Settings (if available)

---

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── Screens/Main/
│   ├── HomeScreen.dart               # Navigation shell (PageView + bottom bar)
│   ├── Dashboard.dart                # Landing page with pact overview
│   ├── PactDetail.dart               # Pact details & member check-ins
│   ├── InviteQrScreen.dart           # Generate & share QR code
│   ├── ScanInviteScreen.dart         # Scan QR or enter join code
│   ├── Profile.dart                  # User profile management
│   ├── Feed.dart                     # Social feed of pact updates
│   ├── Create.dart                   # Create new pacts
│   └── Notification.dart             # Notification center
├── Utils/
│   ├── pact_provider.dart            # Pact API & state management
│   ├── user_profile_provider.dart    # User data & profile management
│   ├── firebase_notification_service.dart  # FCM initialization & handlers
│   ├── api_endpoints.dart            # Centralized API URLs
│   ├── auth_provider.dart            # Authentication state
│   ├── Colors.dart                   # App color palette
│   ├── StatsCard.dart                # Reusable stats widget
│   └── FilterBar.dart                # Pact filtering UI
├── firebase_options.dart             # Firebase config (auto-generated)
└── assets/
    ├── images/                       # App logos, illustrations
    └── icons/                        # Icon assets

android/, ios/, web/, windows/, linux/, macos/
    # Platform-specific configurations and native code
```

---

## 🔧 Configuration

### Firebase Setup (Required for Notifications)

1. **Create a Firebase Project**

      - Go to [Firebase Console](https://console.firebase.google.com)
      - Create a new project or use existing
      - Enable Cloud Messaging

2. **Android Configuration**

      - Download `google-services.json` and place in `android/app/`
      - Verify `android/app/build.gradle.kts` has:
           ```gradle
           id("com.google.gms.google-services")
           ```

3. **iOS Configuration**

      - Download `GoogleService-Info.plist` and add to `ios/Runner/`
      - In Xcode, ensure the file is added to the Build Phases Copy Bundle Resources

4. **Verify Setup**
      - Run: `flutter run` and check device logs
      - Look for: `"FCM Token obtained: ..."`
      - If you see `MISSING_INSTANCE` error, see [Troubleshooting](#troubleshooting)

### API Endpoint Configuration

- Edit `lib/Utils/api_endpoints.dart` to point to your backend
- Example:
     ```dart
     static const String baseUrl = 'https://api.myresolve.com';
     ```

---

## 📚 Architecture & Tech Stack

### State Management

- **Provider**: Reactive state container for pacts, user profile, notifications
- Key providers: `PactProvider`, `UserProfileProvider`, `NotificationProvider`

### Networking

- **http**: REST API calls to backend
- **firebase_messaging**: FCM token retrieval and message handling

### Local Storage

- **Hive**: Type-safe local database for caching pacts, profiles
- **SharedPreferences**: App settings and simple key-value storage
- **flutter_secure_storage**: Encrypted storage for auth tokens

### UI & Animations

- **Sizer**: Responsive sizing for adaptive layouts
- **Flutter Animate**: Smooth animations and transitions
- **Shimmer**: Loading skeleton screens
- **awesome_snackbar_content**: Polished notifications

### Notifications

- **firebase_messaging**: Cloud messaging backend
- **flutter_local_notifications**: Local notification display and handling
- **timezone**: Scheduled notifications support

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m 'Add YourFeature'`
4. Push to the branch: `git push origin feature/YourFeature`
5. Open a Pull Request

