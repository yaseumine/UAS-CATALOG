import 'package:catalog/features/cart/data/models/checkout_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CheckoutResultModel menerima ID bawaan GORM', () {
    final result = CheckoutResultModel.fromJson({
      'ID': 17,
      'total_amount': 32500,
      'status': 'pending',
    });

    expect(result.orderId, 17);
    expect(result.totalAmount, 32500);
    expect(result.status, 'pending');
  });
}
