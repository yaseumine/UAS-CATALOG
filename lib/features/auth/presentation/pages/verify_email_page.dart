import 'dart:async';

import 'package:catalog/core/constants/app_colors.dart';
import 'package:catalog/core/routes/app_routes.dart';
import 'package:catalog/features/auth/presentation/providers/auth_provider.dart';
import 'package:catalog/features/auth/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_header.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  bool _resendCooldown = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Polling: cek setiap 5 detik apakah email sudah diverifikasi
  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();

      final success = await auth.checkEmailVerified();

      if (success && mounted) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      } else if (auth.status == AuthStatus.error && mounted) {
        // TANGKAP ERROR: Kalau Golang mati/gagal konek, hentikan timer & kasih notif!
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              auth.errorMessage ?? 'Gagal menghubungi server Backend',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.error, // Pakai merah bata
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: const BorderSide(color: AppColors.primaryDark, width: 2.0),
            ),
          ),
        );
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;
    await context.read<AuthProvider>().resendVerificationEmail();

    // Cooldown 60 detik sebelum bisa kirim lagi
    setState(() {
      _resendCooldown = true;
      _countdown = 60;
    });
    Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        t.cancel();
        setState(() => _resendCooldown = false);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Email verifikasi sudah dikirim ulang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.accent, // Pakai hijau sukses
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: const BorderSide(color: AppColors.primaryDark, width: 2.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().firebaseUser;

    return Scaffold(
      backgroundColor: AppColors.background, // Background kertas krem
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Widget reusable: AuthHeader
              const AuthHeader(
                icon: Icons.mark_email_unread_outlined,
                title:
                    'Surat Menyurat', // Diganti biar lebih nyambung sama game
                subtitle:
                    'Pak Pos sudah mengirim surat ke alamat di bawah ini.',
                iconColor: AppColors.primary, // Icon coklat kayu
              ),
              const SizedBox(height: 24),

              // Kotak penampil email (Diubah jadi gaya Plang Kayu)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface, // Kertas terang
                  borderRadius: BorderRadius.circular(4.0), // Sudut kaku
                  border: Border.all(
                    color: AppColors.primaryDark,
                    width: 2.0,
                  ), // Border kayu
                  boxShadow: const [
                    // Efek shadow 3D
                    BoxShadow(
                      color: AppColors.primaryDark,
                      offset: Offset(4, 4),
                      blurRadius: 0.0,
                    ),
                  ],
                ),
                child: Text(
                  user?.email ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary, // Teks coklat tua
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Indikator polling
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      color: AppColors.primary, // Loading coklat
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Menunggu balasan Pak Pos...',
                    style: TextStyle(
                      color: AppColors.textSecondary, // Teks coklat pudar
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Tombol kirim ulang dengan cooldown (Otomatis dapet tema dari CustomButton)
              CustomButton(
                label: _resendCooldown
                    ? 'Kirim Ulang ($_countdown detik)'
                    : 'Kirim Ulang Surat',
                variant: ButtonVariant.outlined,
                onPressed: _resendCooldown ? null : _resendEmail,
              ),
              const SizedBox(height: 16),

              // Tombol logout
              CustomButton(
                label: 'Ganti Akun / Keluar',
                variant: ButtonVariant.text,
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
