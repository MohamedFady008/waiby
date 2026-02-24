import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../core/config/app_config.dart';

class TopupCheckoutSession {
  final String orderId;
  final String checkoutSessionId;
  final Uri checkoutUrl;

  const TopupCheckoutSession({
    required this.orderId,
    required this.checkoutSessionId,
    required this.checkoutUrl,
  });
}

class TopupCheckoutConfirmation {
  final bool fulfilled;
  final String status;
  final double balanceBuds;
  final double totalBuds;
  final TopupWalletSnapshot? wallet;

  const TopupCheckoutConfirmation({
    required this.fulfilled,
    required this.status,
    required this.balanceBuds,
    required this.totalBuds,
    this.wallet,
  });
}

class TopupWalletSnapshot {
  final double budsBalance;
  final double incomeBalanceUsd;
  final double onHoldUsd;
  final double gemsBalance;
  final double gemDustBalance;

  const TopupWalletSnapshot({
    required this.budsBalance,
    required this.incomeBalanceUsd,
    required this.onHoldUsd,
    required this.gemsBalance,
    required this.gemDustBalance,
  });
}

class WalletWithdrawalRequestResult {
  final String withdrawalRequestId;
  final double feeUsd;
  final double payoutUsd;
  final TopupWalletSnapshot wallet;

  const WalletWithdrawalRequestResult({
    required this.withdrawalRequestId,
    required this.feeUsd,
    required this.payoutUsd,
    required this.wallet,
  });
}

class TopupCheckoutException implements Exception {
  final String message;

  const TopupCheckoutException(this.message);

  @override
  String toString() => message;
}

class TopupCheckoutService {
  TopupCheckoutService({FirebaseAuth? auth, http.Client? httpClient})
    : _auth = auth ?? FirebaseAuth.instance,
      _httpClient = httpClient ?? http.Client();

  final FirebaseAuth _auth;
  final http.Client _httpClient;

  Future<TopupCheckoutSession> createCheckoutSession({
    required String packId,
    Uri? successUrl,
    Uri? cancelUrl,
  }) async {
    final endpoint = Uri.parse(
      '${_resolvePaymentsApiBaseUrl()}/createTopupCheckoutSession',
    );

    final payload = <String, dynamic>{
      'packId': packId,
      if (successUrl != null) 'successUrl': successUrl.toString(),
      if (cancelUrl != null) 'cancelUrl': cancelUrl.toString(),
    };

    final response = await _postJson(endpoint: endpoint, payload: payload);

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const TopupCheckoutException(
        'Payment service returned an invalid response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TopupCheckoutException(
        body['error']?.toString() ?? 'Could not start checkout.',
      );
    }

    final checkoutUrlRaw = body['checkoutUrl']?.toString();
    final orderId = body['orderId']?.toString() ?? '';
    final checkoutSessionId = body['checkoutSessionId']?.toString() ?? '';

    if (checkoutUrlRaw == null || checkoutUrlRaw.isEmpty) {
      throw const TopupCheckoutException(
        'Checkout URL was not returned by payment service.',
      );
    }

    final checkoutUrl = Uri.tryParse(checkoutUrlRaw);
    if (checkoutUrl == null || !checkoutUrl.hasScheme) {
      throw const TopupCheckoutException('Checkout URL is invalid.');
    }

    return TopupCheckoutSession(
      orderId: orderId,
      checkoutSessionId: checkoutSessionId,
      checkoutUrl: checkoutUrl,
    );
  }

  Future<double> syncMyWalletBalance() async {
    final wallet = await syncMyWallet();
    return wallet.budsBalance;
  }

  Future<TopupWalletSnapshot> syncMyWallet() async {
    final endpoint = Uri.parse(
      '${_resolvePaymentsApiBaseUrl()}/syncMyWalletBalance',
    );
    final response = await _postJson(
      endpoint: endpoint,
      payload: const <String, dynamic>{},
    );

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const TopupCheckoutException(
        'Payment service returned an invalid response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TopupCheckoutException(
        body['error']?.toString() ?? 'Could not sync wallet balance.',
      );
    }

    final walletData = body['wallet'];
    if (walletData is Map<String, dynamic>) {
      return _walletFromMap(walletData);
    }
    if (walletData is Map) {
      return _walletFromMap(walletData.cast<String, dynamic>());
    }

    return TopupWalletSnapshot(
      budsBalance: _toDouble(body['balanceBuds']),
      incomeBalanceUsd: 0,
      onHoldUsd: 0,
      gemsBalance: 0,
      gemDustBalance: 0,
    );
  }

  Future<TopupCheckoutConfirmation> confirmCheckoutSession({
    required String checkoutSessionId,
  }) async {
    final endpoint = Uri.parse(
      '${_resolvePaymentsApiBaseUrl()}/confirmTopupCheckoutSession',
    );
    final response = await _postJson(
      endpoint: endpoint,
      payload: <String, dynamic>{'checkoutSessionId': checkoutSessionId},
    );

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const TopupCheckoutException(
        'Payment service returned an invalid response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TopupCheckoutException(
        body['error']?.toString() ?? 'Could not confirm checkout session.',
      );
    }

    final status = (body['status']?.toString() ?? 'pending')
        .trim()
        .toLowerCase();
    TopupWalletSnapshot? wallet;
    final walletData = body['wallet'];
    if (walletData is Map<String, dynamic>) {
      wallet = _walletFromMap(walletData);
    } else if (walletData is Map) {
      wallet = _walletFromMap(walletData.cast<String, dynamic>());
    }

    return TopupCheckoutConfirmation(
      fulfilled: body['fulfilled'] == true,
      status: status,
      balanceBuds: _toDouble(body['balanceBuds']),
      totalBuds: _toDouble(body['totalBuds']),
      wallet: wallet,
    );
  }

  Future<WalletWithdrawalRequestResult> requestWalletWithdrawal({
    required double amountUsd,
    String method = 'bank_transfer',
  }) async {
    final endpoint = Uri.parse(
      '${_resolvePaymentsApiBaseUrl()}/requestWalletWithdrawal',
    );
    final response = await _postJson(
      endpoint: endpoint,
      payload: <String, dynamic>{'amountUsd': amountUsd, 'method': method},
    );

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const TopupCheckoutException(
        'Payment service returned an invalid response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TopupCheckoutException(
        body['error']?.toString() ?? 'Could not create withdrawal request.',
      );
    }

    final walletData = body['wallet'];
    TopupWalletSnapshot wallet;
    if (walletData is Map<String, dynamic>) {
      wallet = _walletFromMap(walletData);
    } else if (walletData is Map) {
      wallet = _walletFromMap(walletData.cast<String, dynamic>());
    } else {
      throw const TopupCheckoutException(
        'Withdrawal response is missing wallet balance.',
      );
    }

    return WalletWithdrawalRequestResult(
      withdrawalRequestId: body['withdrawalRequestId']?.toString() ?? '',
      feeUsd: _toDouble(body['feeUsd']),
      payoutUsd: _toDouble(body['payoutUsd']),
      wallet: wallet,
    );
  }

  Future<void> openCheckout(Uri checkoutUrl) async {
    final launched = await launchUrl(checkoutUrl, webOnlyWindowName: '_self');
    if (!launched) {
      throw const TopupCheckoutException('Could not open Stripe checkout.');
    }
  }

  String _resolvePaymentsApiBaseUrl() {
    final configured = AppConfig.paymentsApiBaseUrl.trim();
    if (configured.isNotEmpty) {
      return configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
    }

    final projectId = Firebase.app().options.projectId;
    if (projectId.isEmpty) {
      throw const TopupCheckoutException(
        'Payments API base URL is not configured.',
      );
    }

    final region = AppConfig.paymentsRegion.trim().isEmpty
        ? 'us-central1'
        : AppConfig.paymentsRegion.trim();
    return 'https://$region-$projectId.cloudfunctions.net';
  }

  Future<http.Response> _postJson({
    required Uri endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final idToken = await _requireIdToken();

    try {
      return await _httpClient.post(
        endpoint,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(payload),
      );
    } catch (_) {
      throw const TopupCheckoutException(
        'Payment service is unavailable. Please try again.',
      );
    }
  }

  Future<String> _requireIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const TopupCheckoutException('Please sign in to buy Buds.');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw const TopupCheckoutException(
        'Unable to authenticate payment request. Please sign in again.',
      );
    }
    return idToken;
  }

  TopupWalletSnapshot _walletFromMap(Map<String, dynamic> data) {
    return TopupWalletSnapshot(
      budsBalance: _toDouble(data['buds_balance'] ?? data['balance_buds']),
      incomeBalanceUsd: _toDouble(
        data['income_balance_usd'] ?? data['wallet_income_usd'],
      ),
      onHoldUsd: _toDouble(data['on_hold_usd'] ?? data['buds_on_hold']),
      gemsBalance: _toDouble(data['gems_balance'] ?? data['gems']),
      gemDustBalance: _toDouble(data['gem_dust_balance'] ?? data['gem_dust']),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
