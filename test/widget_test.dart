import 'package:catalog/core/services/global_institute_pay_service.dart';
import 'package:catalog/features/cart/presentation/pages/payment_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('menampilkan hasil callback pembayaran sukses', (tester) async {
    const callback = PaymentCallbackData(
      status: 'success',
      reference: 'INV-42',
      transactionId: 'TXN789',
    );

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: const RouteSettings(arguments: callback),
          builder: (_) => const PaymentResultPage(),
        ),
      ),
    );

    expect(find.text('Pembayaran Berhasil!'), findsOneWidget);
    expect(find.text('INV-42'), findsOneWidget);
    expect(find.text('TXN789'), findsOneWidget);
  });
}
