import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/store/frame_catalog.dart';
import 'topup_checkout_service.dart';

class FrameStoreException implements Exception {
  final String message;

  const FrameStoreException(this.message);

  @override
  String toString() => message;
}

class FrameStoreItem {
  final String id;
  final String name;
  final String assetPath;
  final double priceBuds;
  final bool giftable;
  final bool owned;
  final bool active;

  const FrameStoreItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.priceBuds,
    required this.giftable,
    required this.owned,
    required this.active,
  });
}

class FrameStoreState {
  final TopupWalletSnapshot wallet;
  final List<FrameStoreItem> frames;
  final Set<String> ownedFrameIds;
  final String? activeFrameId;

  const FrameStoreState({
    required this.wallet,
    required this.frames,
    required this.ownedFrameIds,
    required this.activeFrameId,
  });
}

class FrameStoreService {
  FrameStoreService({FirebaseAuth? auth, http.Client? httpClient})
    : _auth = auth ?? FirebaseAuth.instance,
      _httpClient = httpClient ?? http.Client();

  final FirebaseAuth _auth;
  final http.Client _httpClient;

  Future<FrameStoreState> getMyFrameStoreState() async {
    final endpoint = Uri.parse(
      '${_resolvePaymentsApiBaseUrl()}/getMyFrameStoreState',
    );
    final response = await _postJson(
      endpoint: endpoint,
      payload: const <String, dynamic>{},
    );
    return _decodeStoreState(
      response: response,
      fallbackError: 'Could not load store state.',
    );
  }

  Future<FrameStoreState> purchaseFrame(String frameId) async {
    final endpoint = Uri.parse(
      '${_resolvePaymentsApiBaseUrl()}/purchaseStoreFrame',
    );
    final response = await _postJson(
      endpoint: endpoint,
      payload: <String, dynamic>{'frameId': frameId},
    );
    return _decodeStoreState(
      response: response,
      fallbackError: 'Could not buy frame.',
    );
  }

  Future<FrameStoreState> setActiveFrame(String? frameId) async {
    final endpoint = Uri.parse(
      '${_resolvePaymentsApiBaseUrl()}/setActiveProfileFrame',
    );
    final response = await _postJson(
      endpoint: endpoint,
      payload: <String, dynamic>{'frameId': frameId ?? ''},
    );
    return _decodeStoreState(
      response: response,
      fallbackError: 'Could not update active frame.',
    );
  }

  FrameStoreState _decodeStoreState({
    required http.Response response,
    required String fallbackError,
  }) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const FrameStoreException(
        'Store service returned an invalid response.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FrameStoreException(body['error']?.toString() ?? fallbackError);
    }

    final walletData = body['wallet'];
    final wallet = _walletFromMap(
      walletData is Map
          ? walletData.cast<String, dynamic>()
          : const <String, dynamic>{},
    );

    final ownedFrameIdsRaw = body['ownedFrameIds'];
    final ownedFrameIds = ownedFrameIdsRaw is Iterable
        ? ownedFrameIdsRaw
              .map((e) => e?.toString() ?? '')
              .where((id) => id.trim().isNotEmpty)
              .map((id) => id.trim())
              .toSet()
        : <String>{};

    final activeFrameId = body['activeFrameId']?.toString().trim();
    final active = (activeFrameId == null || activeFrameId.isEmpty)
        ? null
        : activeFrameId;

    final framesRaw = body['frames'];
    final frames = framesRaw is Iterable
        ? framesRaw
              .whereType<Map>()
              .map((data) => _storeFrameFromMap(data.cast<String, dynamic>()))
              .toList(growable: false)
        : frameCatalog
              .map(
                (frame) => FrameStoreItem(
                  id: frame.id,
                  name: frame.name,
                  assetPath: frame.assetPath,
                  priceBuds: frame.priceBuds,
                  giftable: frame.giftable,
                  owned: ownedFrameIds.contains(frame.id),
                  active: active == frame.id,
                ),
              )
              .toList(growable: false);

    return FrameStoreState(
      wallet: wallet,
      frames: frames,
      ownedFrameIds: ownedFrameIds,
      activeFrameId: active,
    );
  }

  FrameStoreItem _storeFrameFromMap(Map<String, dynamic> data) {
    String parseString(dynamic value, {String fallback = ''}) {
      final parsed = value?.toString().trim() ?? '';
      return parsed.isEmpty ? fallback : parsed;
    }

    final id = parseString(data['id']);
    final catalogItem = frameCatalogById(id);

    return FrameStoreItem(
      id: id,
      name: parseString(data['name'], fallback: catalogItem?.name ?? id),
      assetPath: parseString(
        data['asset_path'],
        fallback: catalogItem?.assetPath ?? '',
      ),
      priceBuds: _toDouble(data['price_buds']),
      giftable: data['giftable'] != false,
      owned: data['owned'] == true,
      active: data['active'] == true,
    );
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

  String _resolvePaymentsApiBaseUrl() {
    final configured = AppConfig.paymentsApiBaseUrl.trim();
    if (configured.isNotEmpty) {
      return configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
    }

    final projectId = Firebase.app().options.projectId;
    if (projectId.isEmpty) {
      throw const FrameStoreException(
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
      return await _httpClient
          .post(
            endpoint,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const FrameStoreException(
        'Store service timed out. Please try again.',
      );
    } catch (_) {
      throw const FrameStoreException(
        'Store service is unavailable. Please try again.',
      );
    }
  }

  Future<String> _requireIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const FrameStoreException('Please sign in to access store.');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw const FrameStoreException(
        'Unable to authenticate store request. Please sign in again.',
      );
    }
    return idToken;
  }
}
