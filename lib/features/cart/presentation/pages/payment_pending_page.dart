import 'dart:async';

import 'package:catalog/core/constants/app_colors.dart';
import 'package:catalog/core/routes/app_routes.dart';
import 'package:catalog/core/services/global_institute_pay_service.dart';
import 'package:catalog/features/auth/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_biometric_kit/flutter_biometric_kit.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPendingPage extends StatefulWidget {
  const PaymentPendingPage({super.key});

  @override
  State<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends State<PaymentPendingPage>
    with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService();
  final GlobalInstitutePayService _paymentService = GlobalInstitutePayService();

  StreamSubscription<PaymentCallbackData>? _callbackSubscription;
  PaymentRequestData? _request;
  bool _didInitialize = false;
  bool _isAuthenticating = false;
  bool _isLaunching = false;
  bool _payLaunched = false;
  bool _callbackHandled = false;
  String _statusMessage =
      'Siapkan sidik jari atau wajah untuk mengamankan pembayaran.';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is! PaymentRequestData) {
      setState(() {
        _errorMessage = 'Data pembayaran tidak ditemukan.';
      });
      return;
    }

    _request = arguments;
    _callbackSubscription = _paymentService.onCallback.listen(_onCallback);

    final pending = _paymentService.consumePendingCallback(
      expectedReference: arguments.reference,
    );
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onCallback(pending));
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyAndLaunch());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        !_payLaunched ||
        _isAuthenticating ||
        _callbackHandled ||
        !mounted) {
      return;
    }

    setState(() {
      _statusMessage =
          'Kembali dari e-Money. Menunggu konfirmasi hasil pembayaran...';
    });
  }

  Future<void> _verifyAndLaunch() async {
    final request = _request;
    if (request == null || _isAuthenticating || _isLaunching) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
      _statusMessage = 'Memverifikasi identitas dengan biometrik...';
    });

    try {
      final verified = await _biometricService.authenticate(
        reason: 'Verifikasi pembayaran ke Dompet Kampus Global',
      );
      if (!verified || !mounted) return;

      setState(() {
        _isAuthenticating = false;
        _isLaunching = true;
        _statusMessage = 'Membuka aplikasi e-Money...';
      });

      final uri = GlobalInstitutePayService.buildPaymentUri(
        orderId: request.orderId,
        amount: request.amount,
        description: request.description,
      );

      // Langsung coba launch untuk menghindari false-negative canLaunchUrl
      // pada beberapa perangkat Android 11+.
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;
      if (!launched) {
        throw StateError('Aplikasi Dompet Kampus Global tidak ditemukan.');
      }

      setState(() {
        _payLaunched = true;
        _statusMessage =
            'Selesaikan PIN dan 2FA di e-Money. Halaman ini akan menerima hasilnya otomatis.';
      });
    } on BiometricException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.userMessage;
        _statusMessage = 'Verifikasi biometrik diperlukan sebelum pembayaran.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is StateError
            ? error.message.toString()
            : 'Gagal membuka aplikasi e-Money. Silakan coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _isLaunching = false;
        });
      }
    }
  }

  void _onCallback(PaymentCallbackData callback) {
    final request = _request;
    if (!mounted || _callbackHandled || request == null) return;
    if (callback.reference != null && callback.reference != request.reference) {
      return;
    }

    _callbackHandled = true;
    Navigator.pushReplacementNamed(
      context,
      AppRouter.paymentResult,
      arguments: callback,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_callbackSubscription?.cancel());
    unawaited(_biometricService.stopAuthentication());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;
    final busy = _isAuthenticating || _isLaunching;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pembayaran e-Money')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.primaryDark, width: 2),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryDark,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _payLaunched
                          ? Icons.account_balance_wallet
                          : Icons.fingerprint,
                      size: 72,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _payLaunched
                          ? 'Menunggu Konfirmasi'
                          : 'Verifikasi Pembayaran',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    if (request != null) ...[
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 16),
                      _DetailRow(label: 'Referensi', value: request.reference),
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: 'Total',
                        value: 'Rp ${request.amount.toStringAsFixed(0)}',
                      ),
                    ],
                    if (busy) ...[
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(color: AppColors.accent),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        color: AppColors.error.withValues(alpha: 0.1),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: _payLaunched ? 'Buka Kembali e-Money' : 'Coba Lagi',
                isLoading: busy,
                icon: Icon(
                  _payLaunched ? Icons.open_in_new : Icons.fingerprint,
                ),
                onPressed: request == null || busy ? null : _verifyAndLaunch,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Kembali ke Dashboard',
                variant: ButtonVariant.outlined,
                onPressed: busy
                    ? null
                    : () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.dashboard,
                        (_) => false,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
