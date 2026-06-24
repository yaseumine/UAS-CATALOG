import 'package:catalog/core/constants/app_colors.dart';
import 'package:catalog/core/routes/app_routes.dart';
import 'package:catalog/core/services/global_institute_pay_service.dart';
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
              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                      size: 34,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dompet Kampus Global',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Aman dengan biometrik, PIN, dan 2FA',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.verified_user, color: AppColors.accent),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // TOMBOL BAYAR (Pakai CustomButton tema Stardew)
              CustomButton(
                label: isCartEmpty
                    ? 'Keranjang Kosong'
                    : 'Bayar dengan e-Money',
                icon: const Icon(Icons.fingerprint),
                variant: ButtonVariant.primary,
                isLoading: cart.isLoading,
                onPressed: cart.isLoading || isCartEmpty
                    ? null
                    : () async {
                        final result = await context
                            .read<CartProvider>()
                            .checkout(
                              address: 'Pelican Town, Farmhouse',
                              notes: 'Tolong kirim ke kotak depan rumah ya.',
                            );

                        if (!context.mounted) return;

                        if (result != null) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouter.paymentPending,
                            arguments: PaymentRequestData(
                              orderId: result.orderId,
                              amount: result.totalAmount,
                              description:
                                  'Belanja di Toko Tani Pierre #${result.orderId}',
                            ),
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
