import 'package:catalog/core/services/dio_clients.dart';
import 'package:catalog/features/cart/data/models/checkout_model.dart';

class CartRepositoryImpl {
  Future<bool> processCheckout(CheckoutRequestModel data) async {
    try {
      // Asumsi endpoint dari dosen adalah /orders atau /checkout
      // Ganti '/orders' di bawah ini kalau endpoint Golang-nya beda ya!
      final response = await DioClient.instance.post(
        '/orders',
        data: data.toJson(),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      rethrow;
    }
  }
}
