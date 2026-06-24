import 'package:catalog/core/constants/app_colors.dart';
import 'package:catalog/core/routes/app_routes.dart';
import 'package:catalog/features/auth/presentation/providers/auth_provider.dart';
import 'package:catalog/features/auth/presentation/widgets/auth_header.dart';
import 'package:catalog/features/auth/presentation/widgets/custom_button.dart';
import 'package:catalog/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:catalog/features/auth/presentation/widgets/divider_with_text.dart';
import 'package:catalog/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:catalog/features/auth/presentation/widgets/loading_overlay.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Handler untuk login email/password
  Future<void> _loginEmail() async {
    // Jangan lanjut request jika form belum valid.
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    // Hindari akses context setelah widget unmounted.
    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  /// Handler untuk login Google
  Future<void> _loginGoogle() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithGoogle();
    // Hindari akses context setelah widget unmounted.
    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  /// Routing berdasarkan hasil login:
  /// - sukses -> dashboard
  /// - email belum verifikasi -> verify email
  /// - gagal lainnya -> tampilkan snackbar error
  void _handleLoginResult(bool ok, AuthProvider auth) {
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else if (auth.status == AuthStatus.emailNotVerified) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ?? 'Login gagal',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: const BorderSide(color: AppColors.primaryDark, width: 2.0),
          ),
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: const BorderSide(color: AppColors.primaryDark, width: 2.0),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: CustomTextField(
          label: 'Email',
          hint: 'Email terdaftar',
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
                side: const BorderSide(
                  color: AppColors.primaryDark,
                  width: 2.0,
                ),
              ),
              elevation: 0.0,
            ),
            onPressed: () async {
              // Kirim email reset password lalu tutup dialog jika masih mounted.
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: ctrl.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Kirim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Masuk ke akun...',
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
                    icon: Icons.storefront_outlined,
                    title: "Pierre's Store",
                    subtitle:
                        'Beli benih, pupuk, dan penuhi kebutuhan ladangmu',
                  ),
                  const SizedBox(height: 32),
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
                    hint: 'Masukkan password',
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
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    label: 'Masuk',
                    onPressed: _loginEmail,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 20),
                  const DividerWithText(text: 'Atau masuk dengan'),
                  const SizedBox(height: 20),
                  GoogleSignInButton(
                    onPressed: _loginGoogle,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      GestureDetector(
                        // Pakai replacement agar halaman login tidak menumpuk di stack.
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRouter.register,
                        ),
                        child: const Text(
                          'Daftar',
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
