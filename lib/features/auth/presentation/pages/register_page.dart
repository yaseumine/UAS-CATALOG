import 'package:catalog/core/constants/app_colors.dart';
import 'package:catalog/features/auth/presentation/providers/auth_provider.dart';
import 'package:catalog/features/auth/presentation/widgets/auth_header.dart';
import 'package:catalog/features/auth/presentation/widgets/custom_button.dart';
import 'package:catalog/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:catalog/features/auth/presentation/widgets/loading_overlay.dart';
import 'package:catalog/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      // Navigasi ke halaman instruksi verifikasi email
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ?? 'Pendaftaran gagal',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.error, // Merah bata ala game
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: const BorderSide(
              color: AppColors.primaryDark,
              width: 2.0,
            ), // Border kayu
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Mendaftarkan akun...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const AuthHeader(
                    icon: Icons.badge_outlined, // Icon ID card biar pas
                    title: 'Warga Baru',
                    subtitle: 'Buat kartu pelanggan Pierre\'s Store',
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    controller: _nameCtrl,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ), // Icon coklat
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    hint: 'contoh@email.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primary,
                    ),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Email wajib diisi';
                      if (!EmailValidator.validate(v!)) {
                        return 'Format email salah';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Minimal 8 karakter',
                    controller: _passCtrl,
                    obscureText: !_showPass,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPass ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.primary,
                      ),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                    validator: (v) => (v?.length ?? 0) < 8
                        ? 'Password minimal 8 karakter'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Konfirmasi Password',
                    hint: 'Ulangi password',
                    controller: _pass2Ctrl,
                    obscureText: !_showPass,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                    ),
                    validator: (v) =>
                        v != _passCtrl.text ? 'Password tidak cocok' : null,
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    label: 'Daftar Sekarang',
                    onPressed: _register,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRouter.login,
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
