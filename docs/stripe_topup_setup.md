# Stripe Top-up Setup

This project now uses a server-side Stripe flow for Buds top-up:

- Flutter app calls `createTopupCheckoutSession`.
- User pays on Stripe Checkout.
- `stripeWebhook` credits Firestore wallet **only** after successful payment.

## 1. Configure Stripe secrets (server only)

1. Create `functions/.env` from `functions/.env.example`.
2. Set values:

```env
STRIPE_SECRET_KEY=sk_live_or_test_key
STRIPE_WEBHOOK_SECRET=whsec_from_stripe_webhook
# Optional for native/desktop callback fallback:
# DEFAULT_TOPUP_RETURN_URL=https://waiby.web.app/wallet/topup
# Optional CORS allow-list value:
# CORS_ALLOW_ORIGIN=https://waiby.web.app
```

Do not put the secret key in Flutter code.

## 2. Install/deploy functions

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

Functions added:

- `createTopupCheckoutSession`
- `stripeWebhook`

## 3. Stripe webhook

In Stripe Dashboard, add webhook endpoint:

`https://us-central1-<your-project-id>.cloudfunctions.net/stripeWebhook`

Subscribe to:

- `checkout.session.completed`
- `checkout.session.async_payment_succeeded`
- `checkout.session.async_payment_failed`
- `checkout.session.expired`

Use the webhook signing secret as `STRIPE_WEBHOOK_SECRET`.

## 4. Flutter runtime defines

Optional but recommended:

```bash
flutter run \
  --dart-define=PAYMENTS_API_BASE_URL=https://us-central1-<your-project-id>.cloudfunctions.net \
  --dart-define=PAYMENTS_REGION=us-central1 \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_or_test_key
```

`STRIPE_PUBLISHABLE_KEY` is reserved for future client-side Stripe features (for example subscriptions). Top-up checkout currently uses server-side session URLs.

## 5. Firestore data created

- `wallets/{uid}` with `balance_buds`
- `topup_orders/{orderId}` with Stripe/order state
- `wallet_transactions/{transactionId}` as immutable credit ledger
