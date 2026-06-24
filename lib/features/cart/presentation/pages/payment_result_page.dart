import 'package:catalog/core/constants/app_colors.dart';
import 'package:catalog/core/routes/app_routes.dart';
import 'package:catalog/core/services/global_institute_pay_service.dart';
import 'package:catalog/features/auth/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class PaymentResultPage extends StatelessWidget {
  const PaymentResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final callback = arguments is PaymentCallbackData ? arguments : null;
    final success = callback?.isSuccess == true;
    final cancelled = callback?.isCancelled == true;
    final color = success
        ? AppColors.accent
        : cancelled
        ? AppColors.primary
        : AppColors.error;
    final icon = success
        ? Icons.check_circle
        : cancelled
        ? Icons.cancel_outlined
        : Icons.error_outline;
    final title = success
        ? 'Pembayaran Berhasil!'
        : cancelled
        ? 'Pembayaran Dibatalkan'
        : 'Pembayaran Belum Berhasil';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.primaryDark, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Icon(icon, size: 82, color: color),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    success
                        ? 'Konfirmasi dari Dompet Kampus Global sudah diterima.'
                        : callback?.error ??
                              'Status dari aplikasi e-Money: ${callback?.status ?? 'tidak diketahui'}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  if (callback?.reference != null ||
                      callback?.transactionId != null) ...[
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.border),
                    if (callback?.reference != null)
                      _ResultLine(
                        label: 'Referensi',
                        value: callback!.reference!,
                      ),
                    if (callback?.transactionId != null)
                      _ResultLine(
                        label: 'Transaksi',
                        value: callback!.transactionId!,
                      ),
                  ],
                  const SizedBox(height: 30),
                  CustomButton(
                    label: 'Kembali ke Dashboard',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.dashboard,
                      (_) => false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  final String label;
  final String value;

  const _ResultLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
