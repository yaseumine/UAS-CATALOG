class CheckoutItemModel {
  final int productId;
  final int quantity;
  final double price;

  CheckoutItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'price': price,
  };
}

class CheckoutRequestModel {
  final List<CheckoutItemModel> items;
  final double totalAmount;
  final String shippingAddress;
  final String notes;

  CheckoutRequestModel({
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'total_amount': totalAmount,
    'shipping_address': shippingAddress,
    'notes': notes,
  };
}
