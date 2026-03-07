# Supabase to Firebase Migration Guide

This app runtime uses:

- Firebase Auth for sign-in/sign-up
- Cloud Firestore for app data
- GetX for client-side state management

## 1. Runtime Setup

1. Copy `.env.firebase.example.json` to `.env.firebase.json`.
2. Fill values from your Firebase project settings.
3. Run with:

```bash
flutter run --dart-define-from-file=.env.firebase.json
```

You can also build with:

```bash
flutter build web --dart-define-from-file=.env.firebase.json
flutter build apk --dart-define-from-file=.env.firebase.json
```

## 2. Firestore Security

This repo includes:

- `firestore.rules`
- `firestore.indexes.json`

Deploy with:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## 3. Data Migration Strategy

This repository does not ship a production migration script. Use your own
Admin SDK pipeline to export from Supabase and write to Firestore collections.

Recommended process:

1. Export source tables (CSV/JSON).
2. Transform rows into Firestore document shapes.
3. Run a dry-run migration and compare source/target counts.
4. Run live migration after validation.
5. Keep logs for duplicate IDs and failed writes.

## 4. Auth Migration Notes

For existing users, choose one approach:

1. Import users if password hashes can be migrated in a supported format.
2. Bulk-create users by email and require password reset on first login.

## 5. Verification Checklist

Validate after migration:

1. Sign-up and login flow (email/password).
2. Google and Facebook sign-in.
3. Password reset flow.
4. Profile read/write in `users/{uid}`.
5. Data counts against source snapshots.

## 6. Rollout Strategy

Recommended rollout:

1. Freeze writes on Supabase.
2. Run migration dry-run and resolve issues.
3. Run live migration.
4. Smoke-test Firebase auth and Firestore CRUD.
5. Switch production app config.
6. Keep Supabase read-only for rollback window.
