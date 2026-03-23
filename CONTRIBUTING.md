# Contributing
- Mohamed Fady Fouad Abdel-fattah
- Eslam Magdy Selim Adel-Monam
## Prerequisites

- Flutter SDK (stable channel)
- Firebase CLI
- Node.js 22+ (for Cloud Functions)

## Local Setup

1. Copy `.env.firebase.example.json` to `.env.firebase.json` and fill your values.
2. Copy `functions/.env.example` to `functions/.env` and fill Stripe values.
3. Install dependencies:

```bash
flutter pub get
cd functions && npm install
```

## Development

- Run app:

```bash
flutter run --dart-define-from-file=.env.firebase.json
```

- Run tests:

```bash
flutter test
```

## Pull Requests

1. Keep PRs focused and small.
2. Add or update tests for behavior changes.
3. Do not commit credentials, private keys, or local `.env` files.
