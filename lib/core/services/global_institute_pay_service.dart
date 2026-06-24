import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

@immutable
class PaymentCallbackData {
  final String status;
  final String? reference;
  final String? transactionId;
  final String? error;

  const PaymentCallbackData({
    required this.status,
    this.reference,
    this.transactionId,
    this.error,
  });

  factory PaymentCallbackData.fromUri(Uri uri) {
    if (!GlobalInstitutePayService.isCallbackUri(uri)) {
      throw const FormatException('URI callback pembayaran tidak valid.');
    }

    return PaymentCallbackData(
      status: (uri.queryParameters['status'] ?? 'unknown').toLowerCase(),
      reference: uri.queryParameters['reference'],
      transactionId: uri.queryParameters['transaction_id'],
      error: uri.queryParameters['error'],
    );
  }

  bool get isSuccess => status == 'success';
  bool get isCancelled => status == 'cancelled';
}

@immutable
class PaymentRequestData {
  final int orderId;
  final double amount;
  final String description;

  const PaymentRequestData({
    required this.orderId,
    required this.amount,
    required this.description,
  });

  String get reference => 'INV-$orderId';
}

class GlobalInstitutePayService {
  static const callbackScheme = 'catalog';
  static const callbackHost = 'payment-callback';
  static const merchantId = 'MCH_CATALOG';
  static const merchantName = 'Toko Tani Pierre';

  static final GlobalInstitutePayService _instance =
      GlobalInstitutePayService._();

  factory GlobalInstitutePayService() => _instance;

  GlobalInstitutePayService._();

  final AppLinks _appLinks = AppLinks();
  final StreamController<PaymentCallbackData> _callbackController =
      StreamController<PaymentCallbackData>.broadcast();

  StreamSubscription<Uri>? _subscription;
  PaymentCallbackData? _pendingCallback;
  bool _initialized = false;

  Stream<PaymentCallbackData> get onCallback => _callbackController.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri, isColdStart: true);
      }
    } catch (error) {
      debugPrint('[GlobalInstitutePay] initial link gagal: $error');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error) {
        debugPrint('[GlobalInstitutePay] stream deeplink gagal: $error');
      },
    );
  }

  PaymentCallbackData? consumePendingCallback({String? expectedReference}) {
    final callback = _pendingCallback;
    if (callback == null) return null;
    if (expectedReference != null && callback.reference != expectedReference) {
      return null;
    }

    _pendingCallback = null;
    return callback;
  }

  void _handleUri(Uri uri, {bool isColdStart = false}) {
    if (!isCallbackUri(uri)) return;

    final callback = PaymentCallbackData.fromUri(uri);
    debugPrint(
      '[GlobalInstitutePay] callback ${callback.status} '
      'untuk ${callback.reference ?? '-'}',
    );

    if (isColdStart) {
      _pendingCallback = callback;
      return;
    }

    _callbackController.add(callback);
  }

  static bool isCallbackUri(Uri uri) =>
      uri.scheme == callbackScheme && uri.host == callbackHost;

  static Uri buildPaymentUri({
    required int orderId,
    required double amount,
    String? description,
  }) {
    return Uri(
      scheme: 'dompetkampus',
      host: 'pay',
      queryParameters: {
        'merchant_id': merchantId,
        'merchant_name': merchantName,
        'amount': amount.round().toString(),
        'description': description?.trim().isNotEmpty == true
            ? description!.trim()
            : 'Order #$orderId',
        'reference': 'INV-$orderId',
        'callback': '$callbackScheme://$callbackHost',
      },
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _callbackController.close();
  }
}
