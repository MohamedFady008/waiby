# Supabase -> Firebase Migration Guide

This project now runs on:
- `Firebase Auth` for authentication
- `Cloud Firestore` for app data (user profile documents under `users/{uid}`)
- `GetX` state flow remains unchanged at UI layer

## 1. Runtime Setup

1. Copy `.env.firebase.example.json` to `.env.firebase.json`.
2. Fill real Firebase values from your Firebase project settings.
3. Run the app with:

```bash
flutter run --dart-define-from-file=.env.firebase.json
```

You can also build with:

```bash
flutter build web --dart-define-from-file=.env.firebase.json
flutter build apk --dart-define-from-file=.env.firebase.json
```

## 2. Firestore Security

The project now includes:
- `firestore.rules`
- `firestore.indexes.json`

Deploy them:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Rules are locked down to owner-only access for `users/{uid}`.

## 3. Data Migration (Tables -> Collections)

Use the migration script:

```bash
dart run tool/migrate_supabase_to_firestore.dart \
  --supabase-url=https://YOUR_PROJECT.supabase.co \
  --supabase-service-role-key=YOUR_SUPABASE_SERVICE_ROLE_KEY \
  --project-id=waiby-89732 \
  --firebase-service-account=./service-account.json \
  --tables=profiles,orders,tickets \
  --table-map=profiles:users,orders:orders,tickets:tickets
```

Recommended first run:

```bash
dart run tool/migrate_supabase_to_firestore.dart ... --dry-run
```

The script generates a JSON report:
- source count vs fetched count
- duplicate document-id collisions
- firestore count before/after
- integrity pass/fail flag per table

## 4. Auth Migration Notes

App authentication has been migrated from Supabase to Firebase Auth in runtime code.

For existing production users, choose one of these:
1. Import users with an admin pipeline (if you can export/import password hashes in supported format).
2. Safer fallback: create Firebase users by email and force password reset on first login.

If you choose option 2, use Firebase Auth bulk account creation from backend/admin side, then notify users to reset passwords.

## 5. Verification Checklist

Run these checks after migration:
1. Sign up (email/password) -> verify email -> login.
2. Google login (web + mobile).
3. Facebook login (web + mobile).
4. Password reset flow.
5. Profile update flow (name/photo) and confirm in Firestore `users/{uid}`.
6. Compare migration report counts with source DB snapshots.

## 6. Rollout Strategy

Recommended rollout:
1. Freeze writes on Supabase.
2. Run migration in dry-run, fix issues.
3. Run live migration.
4. Smoke-test Firebase auth + Firestore CRUD.
5. Switch production app config.
6. Keep Supabase read-only temporarily for rollback window.
