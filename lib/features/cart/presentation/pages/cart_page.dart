import 'package:catalog/core/constants/app_colors.dart';
import 'package:catalog/features/auth/presentation/widgets/custom_button.dart';
import 'package:catalog/features/cart/presentation/providers/cart_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: AppColors.background, // Background kertas krem
      appBar: AppBar(
        title: const Text(
          'Tas Ransel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 64, color: AppColors.border),
                  const SizedBox(height: 16),
                  Text(
                    'Tas ranselmu masih kosong!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, i) {
                final item = cartItems[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface, // Warna kertas
                    borderRadius: BorderRadius.circular(4.0), // Kotak kaku
                    border: Border.all(
                      color: AppColors.primaryDark,
                      width: 2.0,
                    ), // Border kayu tebal
                    boxShadow: const [
                      // Bayangan 3D retro tanpa blur
                      BoxShadow(
                        color: AppColors.primaryDark,
                        offset: Offset(4, 4),
                        blurRadius: 0.0,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryDark,
                          width: 2.0,
                        ), // Border foto kayu
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.0),
                        child: Image.network(
                          item.product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, color: AppColors.border),
                        ),
                      ),
                    ),
                    title: Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Rp ${item.product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Kurang (Warna bata)
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.error,
                          ),
                          onPressed: () =>
                              cart.decreaseQuantity(item.product.id),
                        ),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        // Tombol Tambah (Warna hijau)
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.accent,
                          ),
                          onPressed: () => cart.addToCart(item.product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      // Bagian Bawah: Total Harga & Tombol Lanjut (Bentuk Meja Kasir)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.primary, // Warna kayu tua buat meja kasir
          border: Border(
            top: BorderSide(
              color: AppColors.primaryDark,
              width: 4.0,
            ), // Garis pembatas tebal di atas meja
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rp ${cart.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Teks putih biar kontras
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 140, // Batasin lebar tombolnya
              child: CustomButton(
                label: 'Bayar',
                variant: ButtonVariant.primary,
                onPressed: cartItems.isEmpty
                    ? null
                    : () => Navigator.pushNamed(context, '/checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
