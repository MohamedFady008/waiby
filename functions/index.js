const admin = require("firebase-admin");
const { logger } = require("firebase-functions");
const { onRequest } = require("firebase-functions/v2/https");
const Stripe = require("stripe");

admin.initializeApp();

const db = admin.firestore();

const TOPUP_PACKS = Object.freeze({
  mini: Object.freeze({
    id: "mini",
    buds: 9.99,
    bonusBuds: 0,
    totalBuds: 9.99,
    unitAmountCents: 999,
    currency: "usd",
    displayName: "Mini Buds Pack",
  }),
  small: Object.freeze({
    id: "small",
    buds: 30,
    bonusBuds: 0,
    totalBuds: 30,
    unitAmountCents: 3000,
    currency: "usd",
    displayName: "Small Buds Pack",
  }),
  medium: Object.freeze({
    id: "medium",
    buds: 250,
    bonusBuds: 5,
    totalBuds: 255,
    unitAmountCents: 25000,
    currency: "usd",
    displayName: "Medium Buds Pack",
  }),
  large: Object.freeze({
    id: "large",
    buds: 500,
    bonusBuds: 10,
    totalBuds: 510,
    unitAmountCents: 50000,
    currency: "usd",
    displayName: "Large Buds Pack",
  }),
  featured: Object.freeze({
    id: "featured",
    buds: 100,
    bonusBuds: 2,
    totalBuds: 102,
    unitAmountCents: 10000,
    currency: "usd",
    displayName: "Featured Buds Pack",
  }),
});

const STORE_FRAMES = Object.freeze({
  nautic_ring: Object.freeze({
    id: "nautic_ring",
    name: "Nautic Ring",
    asset_path: "assets/medals/nautic_ring.png",
    price_buds: 9.99,
    giftable: true,
  }),
  goldbutterfly: Object.freeze({
    id: "goldbutterfly",
    name: "Gold Butterfly",
    asset_path: "assets/medals/goldbutterfly.png",
    price_buds: 9.99,
    giftable: true,
  }),
  happy_sprinkles: Object.freeze({
    id: "happy_sprinkles",
    name: "Happy Sprinkles",
    asset_path: "assets/medals/happy_sprinkles.png",
    price_buds: 9.99,
    giftable: false,
  }),
  lotus_aura: Object.freeze({
    id: "lotus_aura",
    name: "Lotus Aura",
    asset_path: "assets/medals/lotus_aura.png",
    price_buds: 15.99,
    giftable: true,
  }),
  lolita_pearl: Object.freeze({
    id: "lolita_pearl",
    name: "Lolita Pearl",
    asset_path: "assets/medals/lolita_pearl.png",
    price_buds: 9.99,
    giftable: true,
  }),
  steam_pipe: Object.freeze({
    id: "steam_pipe",
    name: "Steam Pipe",
    asset_path: "assets/medals/steam_pipe.png",
    price_buds: 9.99,
    giftable: false,
  }),
  golden: Object.freeze({
    id: "golden",
    name: "Golden",
    asset_path: "assets/medals/golden.png",
    price_buds: 9.99,
    giftable: false,
  }),
  aqua_ring: Object.freeze({
    id: "aqua_ring",
    name: "Aqua Ring",
    asset_path: "assets/medals/aqua_ring.png",
    price_buds: 9.99,
    giftable: false,
  }),
  luminova: Object.freeze({
    id: "luminova",
    name: "Luminova",
    asset_path: "assets/medals/luminova.png",
    price_buds: 9.99,
    giftable: false,
  }),
  kittybloom: Object.freeze({
    id: "kittybloom",
    name: "Kittybloom",
    asset_path: "assets/medals/kittybloom.png",
    price_buds: 15.99,
    giftable: true,
  }),
  aurealux_emblem: Object.freeze({
    id: "aurealux_emblem",
    name: "Aurealux Emblem",
    asset_path: "assets/medals/aurealux_emblem.png",
    price_buds: 15.99,
    giftable: false,
  }),
  moumou: Object.freeze({
    id: "moumou",
    name: "Moumou",
    asset_path: "assets/medals/moumou.png",
    price_buds: 9.99,
    giftable: true,
  }),
  boblin_treasure: Object.freeze({
    id: "boblin_treasure",
    name: "Boblin Treasure",
    asset_path: "assets/medals/boblin_treasure.png",
    price_buds: 9.99,
    giftable: true,
  }),
  demon1: Object.freeze({
    id: "demon1",
    name: "Demon",
    asset_path: "assets/medals/demon1.png",
    price_buds: 9.99,
    giftable: true,
  }),
  sugarland: Object.freeze({
    id: "sugarland",
    name: "Sugarland",
    asset_path: "assets/medals/sugarland.png",
    price_buds: 15.99,
    giftable: true,
  }),
});

const TOPUP_CHECKOUT_PATH = "/wallet/topup";
const CORS_HEADERS = "Authorization, Content-Type";
const WITHDRAWAL_FEE_RATE = 0.15;

let stripeClient = null;

function getStripeClient() {
  if (stripeClient != null) {
    return stripeClient;
  }

  const stripeSecretKey = process.env.STRIPE_SECRET_KEY;
  if (!stripeSecretKey) {
    throw new Error("STRIPE_SECRET_KEY is not configured.");
  }

  stripeClient = new Stripe(stripeSecretKey);
  return stripeClient;
}

function applyCors(req, res) {
  const configured = process.env.CORS_ALLOW_ORIGIN;
  const allowOrigin = configured && configured.trim() !== ""
    ? configured.trim()
    : "*";
  res.set("Access-Control-Allow-Origin", allowOrigin);
  res.set("Access-Control-Allow-Headers", CORS_HEADERS);
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Vary", "Origin");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return true;
  }
  return false;
}

function toPositiveNumber(value) {
  const number = Number(value);
  if (!Number.isFinite(number) || number <= 0) {
    return null;
  }
  return number;
}

function roundTo2(value) {
  return Math.round(value * 100) / 100;
}

function toFiniteNumber(value, fallback = 0) {
  const number = Number(value);
  if (!Number.isFinite(number)) {
    return fallback;
  }
  return number;
}

function normalizeWalletData(uid, walletData = {}) {
  const budsBalance = roundTo2(
    toFiniteNumber(walletData.buds_balance ?? walletData.balance_buds, 0),
  );
  const incomeBalanceUsd = roundTo2(
    toFiniteNumber(
      walletData.income_balance_usd ?? walletData.wallet_income_usd,
      0,
    ),
  );
  const onHoldUsd = roundTo2(
    toFiniteNumber(walletData.on_hold_usd ?? walletData.buds_on_hold, 0),
  );

  return {
    user_id: uid,
    buds_balance: budsBalance,
    balance_buds: budsBalance, // legacy compatibility
    currency: String(walletData.currency || "usd").toLowerCase(),
    income_balance_usd: incomeBalanceUsd,
    wallet_income_usd: incomeBalanceUsd, // legacy compatibility
    on_hold_usd: onHoldUsd,
    buds_on_hold: onHoldUsd, // legacy compatibility
    gems_balance: roundTo2(toFiniteNumber(walletData.gems_balance, 0)),
    gem_dust_balance: roundTo2(toFiniteNumber(walletData.gem_dust_balance, 0)),
  };
}

function resolveStoreFrame(frameId) {
  if (typeof frameId !== "string") {
    return null;
  }
  const normalized = frameId.trim();
  if (normalized === "") {
    return null;
  }
  return STORE_FRAMES[normalized] || null;
}

function resolveStoreFrameAssetPath(frameId) {
  const frame = resolveStoreFrame(frameId);
  return frame ? frame.asset_path : null;
}

function parseOwnedFrameIds(value) {
  if (!Array.isArray(value)) {
    return [];
  }
  return [...new Set(value
    .map((item) => String(item || "").trim())
    .filter((item) => item !== "" && resolveStoreFrame(item) != null))];
}

function parseActiveFrameId(assetsData = {}, userData = {}) {
  const candidates = [
    assetsData.active_frame_id,
    userData.active_frame_id,
    userData.profile_frame_id,
    userData.metadata?.active_frame_id,
    userData.metadata?.profile_frame_id,
  ];

  for (const candidate of candidates) {
    const frame = resolveStoreFrame(String(candidate || ""));
    if (frame) {
      return frame.id;
    }
  }
  return null;
}

function buildFrameProfileFields(activeFrameId) {
  const activeFrameAsset = resolveStoreFrameAssetPath(activeFrameId);
  return {
    active_frame_id: activeFrameId,
    profile_frame_id: activeFrameId,
    profile_frame_asset: activeFrameAsset,
    active_frame_asset: activeFrameAsset,
    "metadata.active_frame_id": activeFrameId,
    "metadata.profile_frame_id": activeFrameId,
    "metadata.profile_frame_asset": activeFrameAsset,
    "metadata.active_frame_asset": activeFrameAsset,
  };
}

function buildFrameStoreState(uid, walletData = {}, assetsData = {}, userData = {}) {
  const wallet = normalizeWalletData(uid, walletData);
  const ownedFrameIds = parseOwnedFrameIds(assetsData.owned_frame_ids);
  const activeFrameId = parseActiveFrameId(assetsData, userData);

  if (activeFrameId && !ownedFrameIds.includes(activeFrameId)) {
    ownedFrameIds.push(activeFrameId);
  }

  const frames = Object.values(STORE_FRAMES).map((frame) => ({
    id: frame.id,
    name: frame.name,
    asset_path: frame.asset_path,
    price_buds: frame.price_buds,
    giftable: frame.giftable,
    owned: ownedFrameIds.includes(frame.id),
    active: frame.id === activeFrameId,
  }));

  return {
    wallet,
    frames,
    ownedFrameIds,
    activeFrameId,
  };
}

function sanitizeReturnUrl(candidateUrl, fallbackUrl) {
  if (typeof candidateUrl !== "string" || candidateUrl.trim() === "") {
    return fallbackUrl;
  }

  try {
    const parsed = new URL(candidateUrl);
    const isLocalhost = parsed.hostname === "localhost" ||
      parsed.hostname === "127.0.0.1";
    const protocolAllowed = parsed.protocol === "https:" ||
      (parsed.protocol === "http:" && isLocalhost);

    if (!protocolAllowed) {
      return fallbackUrl;
    }

    return parsed.toString();
  } catch (_) {
    return fallbackUrl;
  }
}

function withQuery(baseUrl, query) {
  const parsed = new URL(baseUrl);
  for (const [key, value] of Object.entries(query)) {
    parsed.searchParams.set(key, value);
  }
  return parsed.toString();
}

function defaultTopupReturnUrl(req) {
  const configured = process.env.DEFAULT_TOPUP_RETURN_URL;
  if (configured && configured.trim() !== "") {
    return configured.trim();
  }

  const origin = req.headers.origin;
  if (typeof origin === "string" && origin.trim() !== "") {
    return `${origin.replace(/\/$/, "")}${TOPUP_CHECKOUT_PATH}`;
  }

  return `https://waiby.web.app${TOPUP_CHECKOUT_PATH}`;
}

async function extractUidFromAuthorization(req) {
  const authHeader = req.headers.authorization;
  if (typeof authHeader !== "string" || !authHeader.startsWith("Bearer ")) {
    return null;
  }

  const idToken = authHeader.substring("Bearer ".length).trim();
  if (idToken.length === 0) {
    return null;
  }

  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    return decoded.uid || null;
  } catch (error) {
    logger.warn("Invalid Firebase ID token.", error);
    return null;
  }
}

async function fulfillTopupOrderFromSession(session, eventId) {
  const metadata = session.metadata || {};
  if (metadata.flow !== "topup") {
    return;
  }

  const orderId = metadata.order_id;
  let userId = metadata.user_id || session.client_reference_id || null;
  let totalBuds = toPositiveNumber(metadata.total_buds);
  let buds = toPositiveNumber(metadata.buds);
  let bonusBuds = Number(metadata.bonus_buds || 0);
  let packId = metadata.pack_id || null;
  let alreadyFulfilled = false;
  const amountCents = Number(session.amount_total || 0);
  const currency = String(session.currency || "usd").toLowerCase();

  if (!orderId || !userId) {
    logger.error("Missing top-up metadata in Stripe session.", {
      sessionId: session.id,
      orderId,
      userId,
    });
    return;
  }

  const orderRef = db.collection("topup_orders").doc(orderId);
  await db.runTransaction(async (transaction) => {
    const orderSnapshot = await transaction.get(orderRef);
    if (orderSnapshot.exists) {
      const orderData = orderSnapshot.data() || {};
      alreadyFulfilled = orderData.status === "fulfilled";

      userId = String(orderData.user_id || userId);
      packId = String(orderData.pack_id || packId || "");
      totalBuds = toPositiveNumber(orderData.total_buds) || totalBuds;
      buds = toPositiveNumber(orderData.buds) || buds;
      bonusBuds = Number(orderData.bonus_buds || bonusBuds || 0);
    }

    if (!userId || !totalBuds) {
      throw new Error("Order does not have a valid user_id or total_buds.");
    }

    const currentWalletRef = db.collection("wallets").doc(userId);
    const userProfileRef = db.collection("users").doc(userId);
    const walletSnapshot = await transaction.get(currentWalletRef);
    const userProfileSnapshot = await transaction.get(userProfileRef);
    const walletData = walletSnapshot.data() || {};
    const currentBudsBalance = Number(
      walletData.buds_balance ?? walletData.balance_buds ?? 0,
    );
    const nextBudsBalance = alreadyFulfilled
      ? roundTo2(currentBudsBalance)
      : roundTo2(currentBudsBalance + totalBuds);

    if (!alreadyFulfilled) {
      transaction.set(
        currentWalletRef,
        {
          user_id: userId,
          buds_balance: nextBudsBalance,
          balance_buds: nextBudsBalance, // legacy compatibility
          currency: "usd",
          income_balance_usd: Number(walletData.income_balance_usd || 0),
          on_hold_usd: Number(walletData.on_hold_usd || 0),
          gems_balance: Number(walletData.gems_balance || 0),
          gem_dust_balance: Number(walletData.gem_dust_balance || 0),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
    if (userProfileSnapshot.exists) {
      transaction.update(userProfileRef, {
        buds_balance: nextBudsBalance,
        balance_buds: nextBudsBalance, // legacy compatibility
        "metadata.wallet_balance_buds": nextBudsBalance,
        "metadata.buds_balance": nextBudsBalance,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      transaction.set(
        userProfileRef,
        {
          buds_balance: nextBudsBalance,
          balance_buds: nextBudsBalance, // legacy compatibility
          metadata: {
            wallet_balance_buds: nextBudsBalance,
            buds_balance: nextBudsBalance,
          },
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    if (!alreadyFulfilled) {
      transaction.set(
        orderRef,
        {
          flow: "topup",
          user_id: userId,
          pack_id: packId,
          buds: buds,
          bonus_buds: bonusBuds,
          total_buds: totalBuds,
          amount_cents: amountCents,
          amount_usd: roundTo2(amountCents / 100),
          exchange_rate_usd_to_bud: 1,
          currency: currency,
          status: "fulfilled",
          stripe_checkout_session_id: session.id,
          stripe_payment_intent_id: session.payment_intent || null,
          stripe_payment_status: session.payment_status || "paid",
          stripe_event_id: eventId,
          fulfilled_at: admin.firestore.FieldValue.serverTimestamp(),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      const walletTransactionRef = db.collection("wallet_transactions").doc();
      const walletTransactionData = {
        user_id: userId,
        flow: "topup",
        type: "credit",
        status: "completed",
        source: "stripe_checkout",
        amount_buds: totalBuds,
        amount_usd: roundTo2(amountCents / 100),
        buds_balance_after: nextBudsBalance,
        exchange_rate_usd_to_bud: 1,
        order_id: orderId,
        pack_id: packId,
        stripe_checkout_session_id: session.id,
        stripe_event_id: eventId,
        description: `Top-up ${totalBuds} Buds`,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      };
      transaction.set(walletTransactionRef, walletTransactionData);
      const userWalletTransactionRef = currentWalletRef
        .collection("transactions")
        .doc(walletTransactionRef.id);
      transaction.set(userWalletTransactionRef, walletTransactionData);
    }
  });

  logger.info(
    alreadyFulfilled
      ? "Top-up order already fulfilled; synced user profile balance."
      : "Top-up order fulfilled.",
    {
    sessionId: session.id,
    orderId,
    userId,
    totalBuds,
    },
  );
}

async function markOrderStatusFromSession(session, nextStatus, eventId) {
  const metadata = session.metadata || {};
  const orderId = metadata.order_id;
  if (!orderId) {
    return;
  }

  const orderRef = db.collection("topup_orders").doc(orderId);
  await db.runTransaction(async (transaction) => {
    const orderSnapshot = await transaction.get(orderRef);
    const orderData = orderSnapshot.data();
    if (orderData?.status === "fulfilled") {
      return;
    }

    transaction.set(
      orderRef,
      {
        status: nextStatus,
        stripe_checkout_session_id: session.id,
        stripe_payment_status: session.payment_status || nextStatus,
        stripe_event_id: eventId,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });
}

function deriveOrderStatusFromStripeSession(session) {
  if (session.payment_status === "paid") {
    return "fulfilled";
  }
  if (session.status === "expired") {
    return "expired";
  }
  if (session.status === "complete") {
    return "processing";
  }
  return "pending";
}

exports.createTopupCheckoutSession = onRequest(
  { region: "us-central1" },
  async (req, res) => {
    if (applyCors(req, res)) {
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const uid = await extractUidFromAuthorization(req);
    if (!uid) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    let body;
    try {
      body = typeof req.body === "string" ? JSON.parse(req.body) : req.body;
    } catch (_) {
      res.status(400).json({ error: "Invalid JSON body" });
      return;
    }

    const packId = String(body?.packId || "").trim();
    if (!TOPUP_PACKS[packId]) {
      res.status(400).json({ error: "Invalid top-up pack" });
      return;
    }

    const pack = TOPUP_PACKS[packId];
    const fallbackUrl = defaultTopupReturnUrl(req);
    const requestedSuccessUrl = sanitizeReturnUrl(body?.successUrl, fallbackUrl);
    const requestedCancelUrl = sanitizeReturnUrl(body?.cancelUrl, fallbackUrl);
    const successUrl = withQuery(requestedSuccessUrl, {
      status: "success",
      session_id: "{CHECKOUT_SESSION_ID}",
    });
    const cancelUrl = withQuery(requestedCancelUrl, { status: "cancelled" });

    const orderRef = db.collection("topup_orders").doc();
    const orderBase = {
      flow: "topup",
      user_id: uid,
      pack_id: pack.id,
      buds: pack.buds,
      bonus_buds: pack.bonusBuds,
      total_buds: pack.totalBuds,
      amount_cents: pack.unitAmountCents,
      amount_usd: roundTo2(pack.unitAmountCents / 100),
      exchange_rate_usd_to_bud: 1,
      currency: pack.currency,
      status: "pending",
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    };

    await orderRef.set(orderBase, { merge: true });

    try {
      const stripe = getStripeClient();
      const session = await stripe.checkout.sessions.create({
        mode: "payment",
        client_reference_id: uid,
        success_url: successUrl,
        cancel_url: cancelUrl,
        payment_method_types: ["card"],
        line_items: [
          {
            quantity: 1,
            price_data: {
              currency: pack.currency,
              unit_amount: pack.unitAmountCents,
              product_data: {
                name: `${pack.totalBuds} Buds`,
                description: `${pack.buds} Buds + ${pack.bonusBuds} Bonus`,
              },
            },
          },
        ],
        metadata: {
          flow: "topup",
          order_id: orderRef.id,
          user_id: uid,
          pack_id: pack.id,
          buds: String(pack.buds),
          bonus_buds: String(pack.bonusBuds),
          total_buds: String(pack.totalBuds),
        },
      });

      await orderRef.set(
        {
          stripe_checkout_session_id: session.id,
          stripe_payment_status: session.payment_status || "unpaid",
          checkout_url: session.url || null,
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      if (!session.url) {
        res.status(500).json({ error: "Stripe checkout URL was not returned" });
        return;
      }

      res.status(200).json({
        orderId: orderRef.id,
        checkoutSessionId: session.id,
        checkoutUrl: session.url,
      });
    } catch (error) {
      logger.error("Failed to create Stripe checkout session.", error);
      await orderRef.set(
        {
          status: "failed",
          failure_reason: String(error),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      res.status(500).json({ error: "Unable to create checkout session" });
    }
  },
);

exports.confirmTopupCheckoutSession = onRequest(
  { region: "us-central1" },
  async (req, res) => {
    if (applyCors(req, res)) {
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const uid = await extractUidFromAuthorization(req);
    if (!uid) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    let body;
    try {
      body = typeof req.body === "string" ? JSON.parse(req.body) : req.body;
    } catch (_) {
      res.status(400).json({ error: "Invalid JSON body" });
      return;
    }

    const checkoutSessionId = String(
      body?.checkoutSessionId || body?.sessionId || "",
    ).trim();
    if (!checkoutSessionId) {
      res.status(400).json({ error: "checkoutSessionId is required" });
      return;
    }

    try {
      const stripe = getStripeClient();
      const session = await stripe.checkout.sessions.retrieve(checkoutSessionId);

      if (!session || session.object !== "checkout.session") {
        res.status(404).json({ error: "Checkout session not found" });
        return;
      }

      const metadata = session.metadata || {};
      if (metadata.flow !== "topup") {
        res.status(400).json({ error: "Checkout session is not a top-up flow" });
        return;
      }

      const sessionUserId = String(
        metadata.user_id || session.client_reference_id || "",
      ).trim();
      if (!sessionUserId || sessionUserId !== uid) {
        res.status(403).json({ error: "Checkout session does not belong to user" });
        return;
      }

      const eventId = `manual-confirm-${session.id}-${Date.now()}`;
      if (session.payment_status === "paid") {
        await fulfillTopupOrderFromSession(session, eventId);

        const walletSnapshot = await db.collection("wallets").doc(uid).get();
        const wallet = normalizeWalletData(uid, walletSnapshot.data() || {});
        const balanceBuds = wallet.buds_balance;

        logger.info("Top-up checkout session confirmed as paid.", {
          uid,
          checkoutSessionId: session.id,
          balanceBuds,
        });

        res.status(200).json({
          status: "paid",
          fulfilled: true,
          balanceBuds,
          totalBuds: toPositiveNumber(metadata.total_buds) || 0,
          wallet,
        });
        return;
      }

      const nextStatus = deriveOrderStatusFromStripeSession(session);
      await markOrderStatusFromSession(session, nextStatus, eventId);
      logger.info("Top-up checkout session confirmation pending.", {
        uid,
        checkoutSessionId: session.id,
        status: nextStatus,
      });
      res.status(200).json({
        status: nextStatus,
        fulfilled: false,
      });
    } catch (error) {
      logger.error("Failed to confirm Stripe checkout session.", {
        checkoutSessionId,
        uid,
        message: error?.message || String(error),
      });
      res.status(500).json({ error: "Could not confirm checkout session" });
    }
  },
);

exports.syncMyWalletBalance = onRequest(
  { region: "us-central1" },
  async (req, res) => {
    if (applyCors(req, res)) {
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const uid = await extractUidFromAuthorization(req);
    if (!uid) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    const walletRef = db.collection("wallets").doc(uid);
    const userProfileRef = db.collection("users").doc(uid);

    try {
      const wallet = await db.runTransaction(async (transaction) => {
        const walletSnapshot = await transaction.get(walletRef);
        const userSnapshot = await transaction.get(userProfileRef);
        const normalizedWallet = normalizeWalletData(
          uid,
          walletSnapshot.data() || {},
        );
        const balanceBuds = normalizedWallet.buds_balance;

        transaction.set(
          walletRef,
          {
            ...normalizedWallet,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        if (userSnapshot.exists) {
          transaction.update(userProfileRef, {
            buds_balance: balanceBuds,
            balance_buds: balanceBuds,
            "metadata.wallet_balance_buds": balanceBuds,
            "metadata.buds_balance": balanceBuds,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(
            userProfileRef,
            {
              buds_balance: balanceBuds,
              balance_buds: balanceBuds,
              metadata: {
                wallet_balance_buds: balanceBuds,
                buds_balance: balanceBuds,
              },
              created_at: admin.firestore.FieldValue.serverTimestamp(),
              updated_at: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
        }

        return normalizedWallet;
      });

      logger.info("Wallet balance sync completed.", {
        uid,
        balanceBuds: wallet.buds_balance,
      });

      res.status(200).json({
        balanceBuds: wallet.buds_balance,
        wallet,
      });
    } catch (error) {
      logger.error("Failed to sync wallet balance to user profile.", error);
      res.status(500).json({ error: "Could not sync wallet balance" });
    }
  },
);

exports.requestWalletWithdrawal = onRequest(
  { region: "us-central1" },
  async (req, res) => {
    if (applyCors(req, res)) {
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const uid = await extractUidFromAuthorization(req);
    if (!uid) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    let body;
    try {
      body = typeof req.body === "string" ? JSON.parse(req.body) : req.body;
    } catch (_) {
      res.status(400).json({ error: "Invalid JSON body" });
      return;
    }

    const amountUsd = roundTo2(toFiniteNumber(body?.amountUsd, 0));
    if (!Number.isFinite(amountUsd) || amountUsd <= 0) {
      res.status(400).json({ error: "amountUsd must be greater than 0." });
      return;
    }

    const method = String(body?.method || "bank_transfer")
        .trim()
        .toLowerCase();
    if (method.length === 0) {
      res.status(400).json({ error: "method is required." });
      return;
    }

    const walletRef = db.collection("wallets").doc(uid);
    const userProfileRef = db.collection("users").doc(uid);
    const withdrawalRef = db.collection("withdrawal_requests").doc();
    const walletTransactionRef = db.collection("wallet_transactions").doc();

    try {
      const result = await db.runTransaction(async (transaction) => {
        const walletSnapshot = await transaction.get(walletRef);
        const userSnapshot = await transaction.get(userProfileRef);
        const normalizedWallet = normalizeWalletData(uid, walletSnapshot.data() || {});
        const availableIncomeUsd = roundTo2(
          toFiniteNumber(normalizedWallet.income_balance_usd, 0),
        );

        if (amountUsd > availableIncomeUsd) {
          throw new Error("INSUFFICIENT_WITHDRAWABLE_BALANCE");
        }

        const feeUsd = roundTo2(amountUsd * WITHDRAWAL_FEE_RATE);
        const payoutUsd = roundTo2(amountUsd - feeUsd);
        if (payoutUsd <= 0) {
          throw new Error("WITHDRAWAL_AMOUNT_TOO_SMALL");
        }

        const nextIncomeUsd = roundTo2(availableIncomeUsd - amountUsd);
        const currentOnHoldUsd = roundTo2(
          toFiniteNumber(normalizedWallet.on_hold_usd, 0),
        );
        const nextOnHoldUsd = roundTo2(currentOnHoldUsd + amountUsd);

        const updatedWallet = {
          ...normalizedWallet,
          income_balance_usd: nextIncomeUsd,
          wallet_income_usd: nextIncomeUsd, // legacy compatibility
          on_hold_usd: nextOnHoldUsd,
          buds_on_hold: nextOnHoldUsd, // legacy compatibility
        };

        transaction.set(
          walletRef,
          {
            ...updatedWallet,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        const userWalletMetadata = {
          wallet_balance_buds: updatedWallet.buds_balance,
          buds_balance: updatedWallet.buds_balance,
          wallet_income_usd: updatedWallet.income_balance_usd,
          wallet_on_hold_usd: updatedWallet.on_hold_usd,
        };

        if (userSnapshot.exists) {
          transaction.update(userProfileRef, {
            buds_balance: updatedWallet.buds_balance,
            balance_buds: updatedWallet.buds_balance,
            "metadata.wallet_balance_buds": updatedWallet.buds_balance,
            "metadata.buds_balance": updatedWallet.buds_balance,
            "metadata.wallet_income_usd": updatedWallet.income_balance_usd,
            "metadata.wallet_on_hold_usd": updatedWallet.on_hold_usd,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(
            userProfileRef,
            {
              buds_balance: updatedWallet.buds_balance,
              balance_buds: updatedWallet.buds_balance,
              metadata: userWalletMetadata,
              created_at: admin.firestore.FieldValue.serverTimestamp(),
              updated_at: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
        }

        const withdrawalData = {
          user_id: uid,
          status: "pending",
          method: method,
          currency: "usd",
          amount_usd: amountUsd,
          fee_rate: WITHDRAWAL_FEE_RATE,
          fee_usd: feeUsd,
          payout_usd: payoutUsd,
          source_balance: "income_balance_usd",
          on_hold_usd_before: currentOnHoldUsd,
          on_hold_usd_after: nextOnHoldUsd,
          income_balance_usd_before: availableIncomeUsd,
          income_balance_usd_after: nextIncomeUsd,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        };
        transaction.set(withdrawalRef, withdrawalData);

        const walletTransactionData = {
          user_id: uid,
          flow: "withdrawal",
          type: "debit",
          status: "pending",
          source: "withdrawal_request",
          amount_usd: amountUsd,
          fee_usd: feeUsd,
          payout_usd: payoutUsd,
          order_id: withdrawalRef.id,
          description: `Withdrawal request ${amountUsd.toFixed(2)} USD`,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        };
        transaction.set(walletTransactionRef, walletTransactionData);
        transaction.set(
          walletRef.collection("transactions").doc(walletTransactionRef.id),
          walletTransactionData,
        );

        return {
          withdrawalRequestId: withdrawalRef.id,
          feeUsd,
          payoutUsd,
          wallet: updatedWallet,
        };
      });

      logger.info("Wallet withdrawal request created.", {
        uid,
        withdrawalRequestId: result.withdrawalRequestId,
        amountUsd,
      });

      res.status(200).json(result);
    } catch (error) {
      if (error?.message === "INSUFFICIENT_WITHDRAWABLE_BALANCE") {
        res.status(400).json({
          error: "Insufficient withdrawable balance.",
        });
        return;
      }

      if (error?.message === "WITHDRAWAL_AMOUNT_TOO_SMALL") {
        res.status(400).json({
          error: "Withdrawal amount is too small after fee deduction.",
        });
        return;
      }

      logger.error("Failed to create wallet withdrawal request.", {
        uid,
        amountUsd,
        message: error?.message || String(error),
      });
      res.status(500).json({ error: "Could not create withdrawal request" });
    }
  },
);

exports.getMyFrameStoreState = onRequest(
  { region: "us-central1" },
  async (req, res) => {
    if (applyCors(req, res)) {
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const uid = await extractUidFromAuthorization(req);
    if (!uid) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    try {
      const [walletSnapshot, userAssetsSnapshot, userSnapshot] = await Promise.all([
        db.collection("wallets").doc(uid).get(),
        db.collection("user_assets").doc(uid).get(),
        db.collection("users").doc(uid).get(),
      ]);

      const state = buildFrameStoreState(
        uid,
        walletSnapshot.data() || {},
        userAssetsSnapshot.data() || {},
        userSnapshot.data() || {},
      );

      res.status(200).json(state);
    } catch (error) {
      logger.error("Failed to load frame store state.", {
        uid,
        message: error?.message || String(error),
      });
      res.status(500).json({ error: "Could not load frame store state" });
    }
  },
);

exports.purchaseStoreFrame = onRequest(
  { region: "us-central1" },
  async (req, res) => {
    if (applyCors(req, res)) {
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const uid = await extractUidFromAuthorization(req);
    if (!uid) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    let body;
    try {
      body = typeof req.body === "string" ? JSON.parse(req.body) : req.body;
    } catch (_) {
      res.status(400).json({ error: "Invalid JSON body" });
      return;
    }

    const frameId = String(body?.frameId || "").trim();
    const frame = resolveStoreFrame(frameId);
    if (!frame) {
      res.status(400).json({ error: "Invalid frameId." });
      return;
    }

    const walletRef = db.collection("wallets").doc(uid);
    const userAssetsRef = db.collection("user_assets").doc(uid);
    const userProfileRef = db.collection("users").doc(uid);
    const purchaseRef = db.collection("store_frame_purchases").doc();
    const walletTransactionRef = db.collection("wallet_transactions").doc();

    try {
      const state = await db.runTransaction(async (transaction) => {
        const [walletSnapshot, assetsSnapshot, userSnapshot] = await Promise.all([
          transaction.get(walletRef),
          transaction.get(userAssetsRef),
          transaction.get(userProfileRef),
        ]);

        const wallet = normalizeWalletData(uid, walletSnapshot.data() || {});
        const assetsData = assetsSnapshot.data() || {};
        const userData = userSnapshot.data() || {};
        const ownedFrameIds = parseOwnedFrameIds(assetsData.owned_frame_ids);

        const alreadyOwned = ownedFrameIds.includes(frame.id);
        const priceBuds = roundTo2(toFiniteNumber(frame.price_buds, 0));
        if (priceBuds <= 0) {
          throw new Error("FRAME_PRICE_INVALID");
        }

        let nextWallet = { ...wallet };
        if (!alreadyOwned) {
          if (wallet.buds_balance < priceBuds) {
            throw new Error("INSUFFICIENT_BUDS_BALANCE");
          }
          const nextBudsBalance = roundTo2(wallet.buds_balance - priceBuds);
          nextWallet = {
            ...wallet,
            buds_balance: nextBudsBalance,
            balance_buds: nextBudsBalance,
          };
        }

        const nextOwnedFrameIds = alreadyOwned
          ? ownedFrameIds
          : [...ownedFrameIds, frame.id];
        const nextActiveFrameId = frame.id;
        const frameProfileFields = buildFrameProfileFields(nextActiveFrameId);

        transaction.set(
          walletRef,
          {
            ...nextWallet,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        transaction.set(
          userAssetsRef,
          {
            user_id: uid,
            owned_frame_ids: nextOwnedFrameIds,
            active_frame_id: nextActiveFrameId,
            created_at: assetsSnapshot.exists
              ? assetsData.created_at || admin.firestore.FieldValue.serverTimestamp()
              : admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        const userProfileWalletFields = {
          buds_balance: nextWallet.buds_balance,
          balance_buds: nextWallet.buds_balance,
          "metadata.wallet_balance_buds": nextWallet.buds_balance,
          "metadata.buds_balance": nextWallet.buds_balance,
        };

        if (userSnapshot.exists) {
          transaction.update(userProfileRef, {
            ...userProfileWalletFields,
            ...frameProfileFields,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(
            userProfileRef,
            {
              ...userProfileWalletFields,
              ...frameProfileFields,
              created_at: admin.firestore.FieldValue.serverTimestamp(),
              updated_at: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
        }

        if (!alreadyOwned) {
          const purchaseData = {
            user_id: uid,
            frame_id: frame.id,
            frame_name: frame.name,
            frame_asset_path: frame.asset_path,
            amount_buds: priceBuds,
            status: "completed",
            source: "store",
            created_at: admin.firestore.FieldValue.serverTimestamp(),
          };
          transaction.set(purchaseRef, purchaseData);

          const walletTransactionData = {
            user_id: uid,
            flow: "store_frame_purchase",
            type: "debit",
            status: "completed",
            source: "store",
            amount_buds: priceBuds,
            order_id: purchaseRef.id,
            frame_id: frame.id,
            frame_name: frame.name,
            buds_balance_after: nextWallet.buds_balance,
            description: `Purchased frame ${frame.name}`,
            created_at: admin.firestore.FieldValue.serverTimestamp(),
          };
          transaction.set(walletTransactionRef, walletTransactionData);
          transaction.set(
            walletRef.collection("transactions").doc(walletTransactionRef.id),
            walletTransactionData,
          );
        }

        return buildFrameStoreState(
          uid,
          nextWallet,
          {
            ...assetsData,
            owned_frame_ids: nextOwnedFrameIds,
            active_frame_id: nextActiveFrameId,
          },
          {
            ...userData,
            active_frame_id: nextActiveFrameId,
            profile_frame_id: nextActiveFrameId,
            profile_frame_asset: resolveStoreFrameAssetPath(nextActiveFrameId),
            metadata: {
              ...(userData.metadata || {}),
              active_frame_id: nextActiveFrameId,
              profile_frame_id: nextActiveFrameId,
              profile_frame_asset: resolveStoreFrameAssetPath(nextActiveFrameId),
            },
          },
        );
      });

      logger.info("Frame purchased/equipped successfully.", {
        uid,
        frameId: frame.id,
      });
      res.status(200).json(state);
    } catch (error) {
      if (error?.message === "INSUFFICIENT_BUDS_BALANCE") {
        res.status(400).json({ error: "Insufficient Buds balance." });
        return;
      }
      if (error?.message === "FRAME_PRICE_INVALID") {
        res.status(400).json({ error: "Selected frame price is invalid." });
        return;
      }

      logger.error("Failed to purchase frame.", {
        uid,
        frameId,
        message: error?.message || String(error),
      });
      res.status(500).json({ error: "Could not complete frame purchase" });
    }
  },
);

exports.setActiveProfileFrame = onRequest(
  { region: "us-central1" },
  async (req, res) => {
    if (applyCors(req, res)) {
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const uid = await extractUidFromAuthorization(req);
    if (!uid) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    let body;
    try {
      body = typeof req.body === "string" ? JSON.parse(req.body) : req.body;
    } catch (_) {
      res.status(400).json({ error: "Invalid JSON body" });
      return;
    }

    const requestedFrameIdRaw = String(body?.frameId || "").trim();
    const clearFrame = requestedFrameIdRaw === "";
    const frame = clearFrame ? null : resolveStoreFrame(requestedFrameIdRaw);
    if (!clearFrame && !frame) {
      res.status(400).json({ error: "Invalid frameId." });
      return;
    }

    const walletRef = db.collection("wallets").doc(uid);
    const userAssetsRef = db.collection("user_assets").doc(uid);
    const userProfileRef = db.collection("users").doc(uid);

    try {
      const state = await db.runTransaction(async (transaction) => {
        const [walletSnapshot, assetsSnapshot, userSnapshot] = await Promise.all([
          transaction.get(walletRef),
          transaction.get(userAssetsRef),
          transaction.get(userProfileRef),
        ]);

        const wallet = normalizeWalletData(uid, walletSnapshot.data() || {});
        const assetsData = assetsSnapshot.data() || {};
        const userData = userSnapshot.data() || {};
        const ownedFrameIds = parseOwnedFrameIds(assetsData.owned_frame_ids);

        const nextActiveFrameId = clearFrame ? null : frame.id;
        if (nextActiveFrameId && !ownedFrameIds.includes(nextActiveFrameId)) {
          throw new Error("FRAME_NOT_OWNED");
        }

        const frameProfileFields = buildFrameProfileFields(nextActiveFrameId);

        transaction.set(
          userAssetsRef,
          {
            user_id: uid,
            owned_frame_ids: ownedFrameIds,
            active_frame_id: nextActiveFrameId,
            created_at: assetsSnapshot.exists
              ? assetsData.created_at || admin.firestore.FieldValue.serverTimestamp()
              : admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        if (userSnapshot.exists) {
          transaction.update(userProfileRef, {
            ...frameProfileFields,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(
            userProfileRef,
            {
              ...frameProfileFields,
              created_at: admin.firestore.FieldValue.serverTimestamp(),
              updated_at: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
        }

        return buildFrameStoreState(
          uid,
          wallet,
          {
            ...assetsData,
            owned_frame_ids: ownedFrameIds,
            active_frame_id: nextActiveFrameId,
          },
          {
            ...userData,
            active_frame_id: nextActiveFrameId,
            profile_frame_id: nextActiveFrameId,
            profile_frame_asset: resolveStoreFrameAssetPath(nextActiveFrameId),
            metadata: {
              ...(userData.metadata || {}),
              active_frame_id: nextActiveFrameId,
              profile_frame_id: nextActiveFrameId,
              profile_frame_asset: resolveStoreFrameAssetPath(nextActiveFrameId),
            },
          },
        );
      });

      logger.info("Active profile frame updated.", {
        uid,
        activeFrameId: state.activeFrameId,
      });
      res.status(200).json(state);
    } catch (error) {
      if (error?.message === "FRAME_NOT_OWNED") {
        res.status(400).json({ error: "You do not own this frame yet." });
        return;
      }

      logger.error("Failed to update active profile frame.", {
        uid,
        frameId: requestedFrameIdRaw,
        message: error?.message || String(error),
      });
      res.status(500).json({ error: "Could not update active profile frame" });
    }
  },
);

exports.stripeWebhook = onRequest(
  { region: "us-central1" },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method not allowed");
      return;
    }

    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    if (!webhookSecret) {
      logger.error("STRIPE_WEBHOOK_SECRET is not configured.");
      res.status(500).send("Webhook secret is missing");
      return;
    }

    const signature = req.headers["stripe-signature"];
    if (typeof signature !== "string") {
      res.status(400).send("Missing Stripe signature");
      return;
    }

    let event;
    try {
      const stripe = getStripeClient();
      event = stripe.webhooks.constructEvent(req.rawBody, signature, webhookSecret);
    } catch (error) {
      logger.error("Stripe webhook signature verification failed.", error);
      res.status(400).send(`Webhook signature error: ${error.message}`);
      return;
    }

    const session = event.data.object;
    if (!session || session.object !== "checkout.session") {
      res.status(200).send("Ignored");
      return;
    }

    try {
      switch (event.type) {
        case "checkout.session.completed":
          if (session.payment_status === "paid") {
            await fulfillTopupOrderFromSession(session, event.id);
          } else {
            await markOrderStatusFromSession(session, "processing", event.id);
          }
          break;
        case "checkout.session.async_payment_succeeded":
          await fulfillTopupOrderFromSession(session, event.id);
          break;
        case "checkout.session.async_payment_failed":
          await markOrderStatusFromSession(session, "failed", event.id);
          break;
        case "checkout.session.expired":
          await markOrderStatusFromSession(session, "expired", event.id);
          break;
        default:
          logger.info("Unhandled Stripe event type.", { type: event.type });
      }

      res.status(200).json({ received: true });
    } catch (error) {
      logger.error("Error processing Stripe webhook.", error);
      res.status(500).send("Webhook handler failed");
    }
  },
);
