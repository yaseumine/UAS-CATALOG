import 'package:catalog/features/cart/data/models/checkout_model.dart';

abstract class CartRepository {
  Future<bool> processCheckout(CheckoutRequestModel data);

  // WAJIB DITAMBAHIN DI SINI JUGA BOS!
  Future<bool> addToCartBackend(int productId, int quantity);
}
