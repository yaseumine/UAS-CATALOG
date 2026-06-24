import 'package:catalog/features/dashboard/data/models/product_models.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});
}
