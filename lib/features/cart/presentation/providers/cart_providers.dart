import 'package:catalog/features/cart/data/models/cart_item_model.dart';
import 'package:catalog/features/cart/data/models/checkout_model.dart';
import 'package:catalog/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:catalog/features/dashboard/data/models/product_models.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItemModel> _items = {};
  final CartRepositoryImpl _repository = CartRepositoryImpl();

  bool _isLoading = false;
  String? _errorMessage;

  Map<int, CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. Fitur Tambah Barang (LOGIKA DIPERBAIKI)
  Future<void> addToCart(ProductModel product) async {
    // Tembak ke Backend Golang dulu!
    final success = await _repository.addToCartBackend(product.id, 1);

    // Kalau Golang bilang OKE (sukses masuk database), baru update UI di layar
    if (success) {
      if (_items.containsKey(product.id)) {
        _items[product.id]!.quantity += 1;
      } else {
        _items[product.id] = CartItemModel(product: product);
      }
      notifyListeners();
    } else {
      // Print error di terminal kalau gagal
      debugPrint("Gagal menambahkan ${product.name} ke database Golang!");
    }
  }

  // 2. Fitur Hapus Barang
  void removeFromCart(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // 3. Fitur Total Harga
  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  int get totalItems {
    int count = 0;
    _items.forEach((key, cartItem) {
      count += cartItem.quantity;
    });
    return count;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // 4. Fitur Checkout
  Future<bool> checkout({required String address, String notes = ''}) async {
    if (_items.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requestData = CheckoutRequestModel(
        items: _items.values
            .map(
              (item) => CheckoutItemModel(
                productId: item.product.id,
                quantity: item.quantity,
                price: item.product.price,
              ),
            )
            .toList(),
        totalAmount: totalPrice,
        shippingAddress: address,
        notes: notes,
      );

      final success = await _repository.processCheckout(requestData);

      if (success) {
        _items.clear();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      throw Exception('Gagal memproses pesanan di server');
    } catch (_) {
      _errorMessage =
          'Gagal checkout: periksa koneksi atau pastikan backend menyala';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
