# waiby

Flutter + GetX app migrated to Firebase.

## Migration Docs

- Runtime and environment setup: `docs/firebase_migration.md`
- Supabase table migration script: `tool/migrate_supabase_to_firestore.dart`
- Firebase env sample: `.env.firebase.example.json`
- Stripe top-up setup: `docs/stripe_topup_setup.md`

## Run

```bash
flutter run --dart-define-from-file=.env.firebase.json
```
