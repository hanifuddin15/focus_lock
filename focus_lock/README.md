# Deep Focus App Closer

> **Unbreakable focus lock with friction-based challenges**

A production-grade Flutter app that blocks distracting apps during timed focus sessions. Breaking the lock early requires completing a physical challenge — scanning a barcode from another room or typing a 200-word paragraph with zero typos.

---

## Architecture

```
lib/
├── core/          → Theme, constants, reusable widgets (glassmorphism, neon buttons)
├── data/          → Hive models, repositories, local storage
├── domain/        → Clean entities, use cases (start/end session, validate challenge)
├── presentation/  → Screens & controllers (onboarding, home, lock, challenge, stats, settings)
├── routes/        → GetX routing (app_routes.dart, app_pages.dart)
├── services/      → Platform channels, lock service, notifications, logger, license manager
├── app.dart       → GetMaterialApp configuration
└── main.dart      → Entry point with service initialization
```

**State Management:** GetX (routing, DI, reactive state)  
**Local Storage:** Hive (sessions, settings, app cache)  
**Native Enforcement:** Platform Channels (MethodChannel + EventChannel)

---

## Platform Enforcement

### Android
- **UsageStatsManager** polls foreground app every 500ms
- **Foreground Service** (`FocusLockService`) survives app kills
- **BroadcastReceiver** (`BootReceiver`) restores sessions after reboot
- **System Alert Window** overlay brings app to front when blocked app detected

### iOS
- **FamilyControls + DeviceActivity** frameworks (iOS 15+, requires Apple entitlement)
- **Guided Access** fallback for development and older iOS versions
- Camera permission for barcode scanning

---

## Required Permissions

### Android
| Permission | Purpose |
|---|---|
| `PACKAGE_USAGE_STATS` | Detect which app is in foreground |
| `SYSTEM_ALERT_WINDOW` | Display lock overlay above other apps |
| `FOREGROUND_SERVICE` | Keep monitoring running in background |
| `RECEIVE_BOOT_COMPLETED` | Restore session after device reboot |
| `CAMERA` | Barcode scanning challenge |
| `POST_NOTIFICATIONS` | Session start/complete notifications |
| `QUERY_ALL_PACKAGES` | List installed apps for selection |

### iOS
| Permission | Purpose |
|---|---|
| Camera (`NSCameraUsageDescription`) | Barcode scanning challenge |
| FamilyControls (requires Apple entitlement) | OS-level app blocking |

---

## Build Instructions

### Prerequisites
- Flutter SDK 3.12+
- Dart SDK 3.12+
- Android SDK (min API 23)
- Xcode 15+ (for iOS)

### Setup
```bash
# Clone and navigate to project
cd focus_lock

# Get dependencies
flutter pub get

# Run on connected device
flutter run
```

### Android-specific
```bash
# Build APK
flutter build apk --debug

# Build release
flutter build apk --release
```

**Important:** After first install, the app will guide you through granting:
1. **Usage Stats** access (Settings → Apps → Special access → Usage access)
2. **Display over other apps** (Settings → Apps → Special access → Display over other apps)
3. **Notifications** permission

### iOS-specific
```bash
# Run on iOS device
flutter run -d ios
```

**Note:** iOS app blocking via FamilyControls requires the `com.apple.developer.family-controls` entitlement, which must be requested from Apple. Without it, the app falls back to Guided Access mode instructions.

---

## Test Barcode for Development

Use any QR code generator to create a QR code with the following value:

```
DEEP_FOCUS_TEST_BARCODE_2024
```

1. Generate this QR code and print it (or display on another device)
2. In the app, go to **Settings → Scan & Save Barcode**
3. Scan the QR code to save it
4. Place the QR code in another room
5. During a focus session, select "Early Break Lock" → scan the barcode to unlock

---

## Features

- ✅ Timer dial with 1-180 min range (drag-to-set + presets)
- ✅ App blocking with installed app detection
- ✅ Full-screen immersive lock screen
- ✅ Barcode scan challenge (all formats supported)
- ✅ Typing test challenge (200 words, zero typos, no copy-paste)
- ✅ Real-time character-by-character error highlighting
- ✅ Statistics with weekly bar chart
- ✅ Session history with streaks
- ✅ Settings with challenge type toggle, barcode save, whitelist
- ✅ Dark mode with neon glassmorphism UI
- ✅ 3-screen onboarding
- ✅ Haptic feedback
- ✅ Foreground service (Android) for app kill survival
- ✅ Boot receiver (Android) for reboot survival
- ✅ Local notifications
- ✅ Offline-first (Hive storage)
- ✅ Pro tier placeholder (LicenseManager)

---

## Tech Stack

| Component | Technology |
|---|---|
| Framework | Flutter 3.12+ |
| State Management | GetX |
| Local Storage | Hive |
| Charts | fl_chart |
| Barcode Scanning | mobile_scanner |
| Notifications | flutter_local_notifications |
| Permissions | permission_handler |
| Font | Poppins (bundled) |
| Android Native | Kotlin |
| iOS Native | Swift |

---

## License

Private — All rights reserved.
