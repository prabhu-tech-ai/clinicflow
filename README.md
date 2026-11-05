# clinicflow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Realtime Database

ClinicFlow always saves records locally in Drift/SQLite. When configured, local
changes are also uploaded to Realtime Database and queued locally while offline.
Existing local records are queued for an initial upload. Firebase data is written
under `clinics/<clinic-id>/data/<entity>/<record-id>`.

Run the app with your Firebase app configuration and clinic identifier:

```powershell
flutter run `
  --dart-define=FIREBASE_API_KEY=<api-key> `
  --dart-define=FIREBASE_APP_ID=<app-id> `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=<sender-id> `
  --dart-define=FIREBASE_PROJECT_ID=<project-id> `
  --dart-define=FIREBASE_DATABASE_URL=<realtime-database-url> `
  --dart-define=FIREBASE_CLINIC_ID=<clinic-id>
```

Provide the same defines when building/releasing the app. If Firebase is not
configured or cannot be reached, local saving remains available and queued writes
are retained. The **Sync & Backup** setting shows sync status and retries failed
writes. This integration uploads local data; it does not download cloud changes.
Passwords are never uploaded. Configure Realtime Database security rules and
Firebase Authentication for your clinic before using real patient data. The
current local login screen does not authenticate with Firebase, so Firebase
sign-in and membership-based database rules must be connected before enabling
cloud access. Do not enable public read/write rules.
