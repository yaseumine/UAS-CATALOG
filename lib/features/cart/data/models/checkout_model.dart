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

class CheckoutResultModel {
  final int orderId;
  final double totalAmount;
  final String status;

  const CheckoutResultModel({
    required this.orderId,
    required this.totalAmount,
    required this.status,
  });

  factory CheckoutResultModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['ID'];
    final rawAmount = json['total_amount'];

    final orderId = rawId is num ? rawId.toInt() : int.tryParse('$rawId');
    final totalAmount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse('$rawAmount');

    if (orderId == null || totalAmount == null) {
      throw const FormatException(
        'Respons checkout tidak memiliki data order.',
      );
    }

    return CheckoutResultModel(
      orderId: orderId,
      totalAmount: totalAmount,
      status: json['status'] as String? ?? 'pending',
    );
  }
}
