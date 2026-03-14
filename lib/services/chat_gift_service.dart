import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';

class ChatGiftException implements Exception {
  final String message;

  const ChatGiftException(this.message);

  @override
  String toString() => message;
}

class ChatGiftSendResult {
  final double senderBudsBalance;
  final double chargedBuds;
  final double receiverIncomeUsd;

  const ChatGiftSendResult({
    required this.senderBudsBalance,
    required this.chargedBuds,
    required this.receiverIncomeUsd,
  });
}

class ChatGiftService {
  ChatGiftService({FirebaseAuth? auth, http.Client? httpClient})
    : _auth = auth ?? FirebaseAuth.instance,
      _httpClient = httpClient ?? http.Client();

  final FirebaseAuth _auth;
  final http.Client _httpClient;

  Future<ChatGiftSendResult> sendGift({
    required String conversationId,
    required String giftId,
    required int multiplier,
  }) async {
    final endpoint = Uri.parse('${_resolvePaymentsApiBaseUrl()}/sendChatGift');
    final response = await _postJson(
      endpoint: endpoint,
      payload: <String, dynamic>{
        'conversationId': conversationId,
        'giftId': giftId,
        'multiplier': multiplier,
      },
    );

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ChatGiftException(
        'Gift service returned an invalid response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatGiftException(
        body['error']?.toString() ?? 'Could not send gift right now.',
      );
    }

    final senderWalletData = body['senderWallet'];
    final senderWallet = senderWalletData is Map
        ? senderWalletData.cast<String, dynamic>()
        : const <String, dynamic>{};

    return ChatGiftSendResult(
      senderBudsBalance: _toDouble(
        senderWallet['buds_balance'] ?? senderWallet['balance_buds'],
      ),
      chargedBuds: _toDouble(body['chargedBuds']),
      receiverIncomeUsd: _toDouble(body['receiverIncomeUsd']),
    );
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
      throw const ChatGiftException('Payments API base URL is not configured.');
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
      throw const ChatGiftException(
        'Gift service is unavailable. Please try again.',
      );
    }
  }

  Future<String> _requireIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ChatGiftException('Please sign in to send gifts.');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw const ChatGiftException(
        'Unable to authenticate gift request. Please sign in again.',
      );
    }
    return idToken;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
