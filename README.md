# Waiby

Waiby is a Flutter + GetX app backed by Firebase Auth, Firestore, Storage, and Cloud Functions.

## Stack

- Flutter (mobile, web, desktop)
- Firebase Auth + Firestore + Storage
- Firebase Cloud Functions (Node.js 22)
- Stripe Checkout for wallet top-ups

## Quick Start

1. Install prerequisites:
   - Flutter SDK (stable)
   - Firebase CLI
   - Node.js 22+
2. Create local env files:

```bash
cp .env.firebase.example.json .env.firebase.json
cp functions/.env.example functions/.env
```

3. Fill both files with your project values.
4. Install dependencies:

```bash
flutter pub get
cd functions && npm install && cd ..
```

5. Run app:

```bash
flutter run --dart-define-from-file=.env.firebase.json
```

## Firebase Setup Notes

- `android/app/google-services.json` and iOS plist files are intentionally not committed.
- This repo uses runtime `--dart-define` values from `.env.firebase.json` via [`lib/firebase_options.dart`](lib/firebase_options.dart).
- If any required Firebase define is missing, app startup will fail fast with a clear error.

## Functions and Stripe

See [`docs/stripe_topup_setup.md`](docs/stripe_topup_setup.md) for end-to-end Stripe setup and webhook configuration.

## Deploy

- Deploy Firestore rules/indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

- Deploy Functions:

```bash
firebase deploy --only functions
```

- Build and deploy web:

```bash
flutter build web --release --dart-define-from-file=.env.firebase.json
firebase deploy --only hosting
```

## Documentation

- Firebase migration notes: [`docs/firebase_migration.md`](docs/firebase_migration.md)
- Stripe top-up backend setup: [`docs/stripe_topup_setup.md`](docs/stripe_topup_setup.md)
- Contribution guide: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Security policy: [`SECURITY.md`](SECURITY.md)

## License

MIT. See [`LICENSE`](LICENSE).
