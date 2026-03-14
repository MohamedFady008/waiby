# Waiby

Waiby is a social gaming platform where users can discover creators, chat, and book private gaming sessions.
This repository contains the client app and backend functions that power user auth, profiles, chat gifts, wallet top-ups, and creator workflows.

## What Is Waiby

Waiby focuses on connecting players with creators for interactive, paid experiences.

- User accounts with email/social sign-in
- Creator onboarding and review flows
- Real-time profile/chat data backed by Firebase
- Wallet and top-up flow using Stripe Checkout
- Multi-platform Flutter app (web, Android, iOS, desktop)

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

If you launch from VS Code, use the bundled `Waiby (Chrome)` launch profile so the same dart-defines are passed automatically.

## Firebase Setup Notes

- `android/app/google-services.json` and iOS plist files are intentionally not committed.
- This repo uses runtime `--dart-define` values from `.env.firebase.json` via [`lib/firebase_options.dart`](lib/firebase_options.dart).
- If any required Firebase define is missing, app startup will fail fast with a clear error.

## Functions and Stripe

See [`docs/stripe_topup_setup.md`](docs/stripe_topup_setup.md) for end-to-end Stripe setup and webhook configuration.

## Live Rooms

Realtime live rooms now depend on LiveKit for shared audio, camera, and screen sharing.

1. Copy `functions/.env.example` to `functions/.env`.
2. Fill `LIVEKIT_URL`, `LIVEKIT_API_KEY`, and `LIVEKIT_API_SECRET`.
   `LIVEKIT_URL` can be pasted directly from LiveKit Cloud. Both `wss://...` and `https://...` are accepted by this repo.
3. Deploy updated Firestore rules and Functions before testing live rooms:

```bash
firebase deploy --only firestore:rules
firebase deploy --only functions
```

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

## Community

[Start a new discussion](https://github.com/MohamedFady008/waiby/discussions/new/choose?title=Discussion%3A%20%5BTopic%5D&body=%23%23%23%20Summary%0ADescribe%20your%20discussion%20topic.%0A%0A%23%23%23%20Context%0AWhy%20this%20matters%20for%20Waiby.%0A%0A%23%23%23%20Proposed%20Direction%0AShare%20ideas%2C%20examples%2C%20or%20code%20snippets.)

## License

Non-commercial custom license. See [`LICENSE`](LICENSE).
