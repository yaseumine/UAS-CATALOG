import 'package:catalog/core/services/dio_clients.dart';
import 'package:catalog/features/cart/data/models/checkout_model.dart';
import 'package:catalog/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  @override
  Future<bool> processCheckout(CheckoutRequestModel data) async {
    try {
      final response = await DioClient.instance.post(
        'orders/checkout',
        data: data.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> addToCartBackend(int productId, int quantity) async {
    try {
      final response = await DioClient.instance.post(
        'cart',
        data: {'product_id': productId, 'quantity': quantity},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
