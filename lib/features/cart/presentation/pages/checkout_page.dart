import 'package:catalog/core/constants/app_colors.dart';
import 'package:catalog/features/auth/presentation/widgets/custom_button.dart';
import 'package:catalog/features/cart/presentation/providers/cart_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items.values.toList();
    final isCartEmpty = cartItems.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.primaryDark, // Background meja kayu gelap
      appBar: AppBar(
        title: const Text(
          'Kasir Pierre',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          // Bikin kontainer bentuk nota kertas perkamen
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background, // Warna kertas krem
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: AppColors.primary, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45, // Bayangan di atas meja
                offset: Offset(6, 6),
                blurRadius: 0.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER NOTA
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'NOTA PEMBELIAN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "Pierre's General Store",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(
                color: AppColors.border,
                thickness: 2.0,
                height: 1,
              ), // Garis putus-putus
              const SizedBox(height: 24),

              // LIST BARANG (RINGKASAN)
              ...cartItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x  ${item.product.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        'Rp ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.border, thickness: 2.0, height: 1),
              const SizedBox(height: 16),

              // TOTAL PEMBAYARAN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Rp ${cart.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.error, // Merah bata
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // TOMBOL BAYAR (Pakai CustomButton tema Stardew)
              CustomButton(
                label: isCartEmpty ? 'Keranjang Kosong' : 'Bayar Sekarang',
                variant: ButtonVariant.primary,
                isLoading: cart.isLoading,
                onPressed: cart.isLoading || isCartEmpty
                    ? null
                    : () async {
                        final success = await context.read<CartProvider>().checkout(
                          address:
                              'Pelican Town, Farmhouse', // Ganti alamat default
                          notes: 'Tolong kirim ke kotak depan rumah ya.',
                        );

                        if (!context.mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Transaksi Berhasil! Barang akan dikirim ke ladangmu.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: AppColors.accent, // Hijau sukses
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                side: const BorderSide(
                                  color: AppColors.primaryDark,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          );

                          Navigator.popUntil(
                            context,
                            ModalRoute.withName('/dashboard'),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.read<CartProvider>().errorMessage ??
                                    'Transaksi Gagal',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: AppColors.error, // Merah bata
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                side: const BorderSide(
                                  color: AppColors.primaryDark,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
