# MyResolve — Feature Deep Dive (Viva Guide)

This document is a practical, end-to-end walkthrough of the MyResolve Flutter app for viva. It explains the architecture, core features, important flows, key files, and reasoning behind technical choices. File paths reference this repository.

---

## 1) What the app does (1-minute overview)

MyResolve helps users create and stick to “pacts” (commitments/habits) with accountability through check-ins, a social feed, and notifications. Users can create pacts, invite others via QR codes or links, join pacts, track progress, and manage their profile. Push notifications remind and re-engage users.

---

## 2) Tech stack and architecture

- Client: Flutter (Dart) — cross-platform (Android/iOS/web/desktop)
- State management: Provider
- Networking: `http`
- Local storage: Hive + SharedPreferences + Secure Storage (available packages)
- Notifications: Firebase Cloud Messaging (FCM)
- QR features: `qr_flutter` (generate), `mobile_scanner` (scan), `share_plus` (share), `path_provider` (temp image saving)
- UI: Sizer (responsive), Flutter SVG, Shimmer, Awesome Snackbar Content

Key packages in `pubspec.yaml` (subset):

- `provider`, `http`, `hive`, `hive_flutter`, `flutter_secure_storage`, `shared_preferences`
- `firebase_core`, `firebase_messaging`, `flutter_local_notifications`
- `qr_flutter`, `mobile_scanner`, `share_plus`, `path_provider`
- `sizer`, `flutter_svg`, `shimmer`, `awesome_snackbar_content`

Project layout highlights:

- Screens: `lib/Screens/Main/` (Dashboard, Feed, Create, Notification, Profile, PactDetail, Invite/Scan QR)
- Utilities/Providers/Models: `lib/Utils/` (providers, models, helpers, API endpoints)
- Platform: `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`

---

## 3) Navigation and shell

- Entry shell: `lib/Screens/Main/HomeScreen.dart`
     - Uses `PageView` + bottom navigation (`awesome_bottom_bar`) to switch between:
          1. `DashboardScreen`
          2. `FeedScreen`
          3. `CreateScreen`
          4. `NotificationScreen`
          5. `ProfileScreen`
     - Adds a Floating Action Button to open QR scanner (`ScanInviteScreen`)
     - Keeps `_selected` page index in sync with the PageView

---

## 4) Core features (with file references)

### 4.1 Pacts lifecycle

- Create pacts: `lib/Screens/Main/Create.dart`
- List and filter pacts: `DashboardScreen` (`lib/Screens/Main/Dashboard.dart`)
- Pact details and actions (share invite, check-ins, members): `lib/Screens/Main/PactDetail.dart`
- Data flows through `PactProvider` (`lib/Utils/pact_provider.dart`) using `http` calls to backend URLs from `lib/Utils/api_endpoints.dart`.

What happens when user joins a pact:

- User scans a QR / enters a join code
- `PactProvider.joinPact(joinCode)` is called
- Backend endpoint used: `ApiEndpoints.baseUrl + '/api/pacts/join/$joinCode'`
- On success, UI shows snackbar and returns to previous screen

### 4.2 Invite via QR code (Generate + Scan)

- Generate QR: `InviteQrScreen` (`lib/Screens/Main/InviteQrScreen.dart`)
     - Encodes: `ApiEndpoints.baseUrl + '/api/pacts/join/<joinCode>'`
     - Renders QR using `qr_flutter`
     - Share as image: captures the QR widget (`RepaintBoundary`) → saves PNG to temp directory (`path_provider`) → shares it with `share_plus`
- Scan QR: `ScanInviteScreen` (`lib/Screens/Main/ScanInviteScreen.dart`)
     - Uses `mobile_scanner` to detect QR codes
     - Parses join code from URL path or query string; also supports raw codes
     - Calls `PactProvider.joinPact(joinCode)`; shows success/error snackbars
     - Manual entry fallback (dialog)

Why we chose `mobile_scanner`:

- Compatible with modern Android Gradle plugins and stable on iOS
- Hardware-accelerated and actively maintained

### 4.3 Notifications (FCM)

- Packages: `firebase_core`, `firebase_messaging`, `flutter_local_notifications`
- Service: `lib/Utils/firebase_notification_service.dart` (initialization, token retrieval, foreground display)
- Entry-point integration: `main.dart` triggers initialization on app start
- Typical flows:
     - Request permission (iOS)
     - Get FCM token via `FirebaseMessaging.instance.getToken()`
     - Register token to backend (if implemented in providers)
     - Show local notifications for foreground messages

Common issue you may mention in viva (and mitigation):

- Error: `MISSING_INSTANCEID_SERVICE` or `MISSING_INSTANCE...` while calling `getToken()`
     - Causes: Old or misconfigured Google Play services / invalid `google-services.json` / device emulator without Play Services / wrong Firebase project setup
     - Fixes: Ensure correct `google-services.json`, update Play Services, re-add Firebase to app via console, validate `applicationId` matches Firebase settings

### 4.4 Profile and user data

- Screen: `lib/Screens/Main/Profile.dart`
- Provider: `lib/Utils/user_profile_provider.dart`
- Model: `lib/Utils/user_model.dart`
- In dashboard header, profile avatar is now clickable and opens `ProfileScreen`

### 4.5 Feed and activity

- `lib/Screens/Main/Feed.dart` shows updates (implementation details may vary)

### 4.6 Reminders and UX helpers

- Reminder helper: `lib/Utils/reminder_helper.dart`
- Snackbar UX: `awesome_snackbar_content` for consistent success/error visuals
- Sizer for responsive paddings, font sizes

---

## 5) Networking and API endpoints

- Centralized endpoints: `lib/Utils/api_endpoints.dart`
     - `ApiEndpoints.baseUrl` is the base for all REST calls
     - Example join endpoint: `/api/pacts/join/<joinCode>`
- HTTP client: package `http`
- Providers encapsulate API calls and expose easy methods (e.g., `PactProvider.joinPact`)
- Error handling: Providers set an `error` string; screens read it and show snackbars

---

## 6) Local storage and caching

- Hive (`hive`/`hive_flutter`): structured, typed local storage (boxes) — good for caching pacts/profile
- SharedPreferences: small key-value app settings
- Secure Storage: tokens and secrets (prevents plain-text)

---

## 7) Permissions and platform specifics

- Camera (Android/iOS): required for QR scanning
     - Android: `android/app/src/main/AndroidManifest.xml` → `CAMERA` permission/hardware features
     - iOS: `ios/Runner/Info.plist` → `NSCameraUsageDescription`
- Notifications:
     - Android: `google-services.json` + notification channels (via `flutter_local_notifications`)
     - iOS: `GoogleService-Info.plist`, APNs setup, permission prompts

---

## 8) Error handling strategy

- Provider-driven errors bubble up to UI
- Snackbars (AwesomeSnackbarContent) for immediate feedback
- Defensive parsing in QR flows (supports multiple QR formats; resumes scanner on failure)
- Network errors show user-friendly messages and allow retry

---

## 9) Security and privacy

- Tokens stored using `flutter_secure_storage` (recommended)
- Avoid logging sensitive data (only log non-sensitive identifiers)
- Join links are shareable by design; consider expiring or scoping invites (see Future Work)
- Validate backend HTTPS and certificate correctness; use only `https://` in `ApiEndpoints.baseUrl`

---

## 10) Testing and quality gates

- Unit/UI tests can live in `test/` (example: `test/widget_test.dart`)
- Manual test matrix:
     - QR generate → share → scan on another device
     - Manual join code input
     - Notifications (foreground, background)
     - Network failures (airplane mode)
     - Permissions denied paths (camera/notifications)

---

## 11) How to run (developer quickstart)

Prereqs: Flutter SDK, Android Studio/Xcode; Firebase configured (if using notifications)

```powershell
# Install dependencies
flutter pub get

# Run on a connected device/emulator
flutter run -d chrome   # or: -d windows / -d android / -d ios
```

If using FCM, ensure platform-specific Firebase files are present:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

---

## 12) Key user flows (script for viva)

1. Create and share a pact

- Open Create tab → set title/details → create
- In Pact Detail, tap Share → open `InviteQrScreen` → share QR image via WhatsApp

2. Join a pact via QR

- From Home, tap the QR FAB → `ScanInviteScreen`
- Scan the received QR → app extracts `joinCode` → calls backend → success snackbar

3. Manual join

- In scanner, tap “Enter Code Manually” → paste code → Join

4. Notifications overview

- App initializes `FirebaseNotificationService` on launch
- Demonstrate pushing a test notification from Firebase Console

5. Profile access

- In Dashboard, tap profile avatar → navigates to `ProfileScreen`

---

## 13) Performance considerations

- Mobile scanner is efficient and pauses when processing to avoid duplicate joins
- Heavy lists (pacts/feed) can use shimmer placeholders and pagination (if implemented)
- Provider minimizes rebuilds via `listen: false` where appropriate

---

## 14) Future enhancements (good viva talking points)

- Expiring/time-bound invites or one-time join tokens
- Pact roles (owner/admin) with moderation (approve requests)
- Analytics for invite conversion (how many scans/joins)
- Offline caching of pacts and optimistic updates
- Deep links: open app directly from invite URL
- In-app profile editing & image upload with cache busting

---

## 15) Appendix — file map (most referenced)

Screens:

- `lib/Screens/Main/HomeScreen.dart` — navigation shell, FAB for scanner
- `lib/Screens/Main/Dashboard.dart` — landing, profile avatar tap → Profile
- `lib/Screens/Main/PactDetail.dart` — show pact details; share invite action
- `lib/Screens/Main/InviteQrScreen.dart` — generate + share QR as image
- `lib/Screens/Main/ScanInviteScreen.dart` — scan QR; manual join
- `lib/Screens/Main/Profile.dart`, `Feed.dart`, `Create.dart`, `Notification.dart`

Providers/Utils:

- `lib/Utils/pact_provider.dart` — pact API calls incl. `joinPact`
- `lib/Utils/user_profile_provider.dart` — user data fetching
- `lib/Utils/api_endpoints.dart` — base URL and endpoints
- `lib/Utils/firebase_notification_service.dart` — FCM init & handling
- `lib/Utils/StatsCard.dart`, `FilterBar.dart` — UI components

Assets:

- `assets/images`, `assets/icons` — used across UI

---

If the viva panel wants a short demo, start at Dashboard → share invite → scan invite → show pact joined → show notification → open profile. This covers architecture, networking, state, platform APIs, and UX in under 5 minutes.
