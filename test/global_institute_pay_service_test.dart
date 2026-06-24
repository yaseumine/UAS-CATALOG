import 'package:catalog/core/services/global_institute_pay_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlobalInstitutePayService', () {
    test('membangun deeplink yang diterima Dompet Kampus Global', () {
      final uri = GlobalInstitutePayService.buildPaymentUri(
        orderId: 42,
        amount: 75000,
        description: 'Order #42',
      );

      expect(uri.scheme, 'dompetkampus');
      expect(uri.host, 'pay');
      expect(uri.queryParameters['merchant_id'], 'MCH_CATALOG');
      expect(uri.queryParameters['merchant_name'], 'Toko Tani Pierre');
      expect(uri.queryParameters['amount'], '75000');
      expect(uri.queryParameters['reference'], 'INV-42');
      expect(uri.queryParameters['callback'], 'catalog://payment-callback');
    });

    test('mem-parsing callback sukses dari aplikasi e-Money', () {
      final callback = PaymentCallbackData.fromUri(
        Uri.parse(
          'catalog://payment-callback?status=success&reference=INV-42&transaction_id=TXN789',
        ),
      );

      expect(callback.isSuccess, isTrue);
      expect(callback.reference, 'INV-42');
      expect(callback.transactionId, 'TXN789');
    });

    test('menolak URI yang bukan callback catalog', () {
      expect(
        () => PaymentCallbackData.fromUri(
          Uri.parse('pasarmalam://payment-callback?status=success'),
        ),
        throwsFormatException,
      );
    });
  });
}
