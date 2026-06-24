import 'package:catalog/core/services/dio_clients.dart';
import 'package:catalog/features/cart/data/models/checkout_model.dart';
import 'package:catalog/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  @override
  Future<CheckoutResultModel> processCheckout(CheckoutRequestModel data) async {
    try {
      final response = await DioClient.instance.post(
        'orders/checkout',
        data: data.toJson(),
      );

      final responseData = response.data;
      if ((response.statusCode != 200 && response.statusCode != 201) ||
          responseData is! Map<String, dynamic> ||
          responseData['data'] is! Map<String, dynamic>) {
        throw const FormatException(
          'Respons checkout dari server tidak valid.',
        );
      }

      return CheckoutResultModel.fromJson(
        responseData['data'] as Map<String, dynamic>,
      );
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
