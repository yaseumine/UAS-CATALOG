import 'package:catalog/core/routes/app_routes.dart';
import 'package:catalog/core/themes/app_theme.dart';
import 'package:catalog/features/auth/presentation/providers/auth_provider.dart';
import 'package:catalog/features/auth/presentation/providers/theme_provider.dart';
import 'package:catalog/features/cart/presentation/providers/cart_providers.dart';
import 'package:catalog/features/dashboard/presentation/providers/product_providers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'core/services/secure_storage.dart';

void main() async {
  // 1. Pastikan binding Flutter sudah siap

  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase sebelum aplikasi dijalankan
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // 3. Daftarkan semua Provider di level paling atas
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Baca ThemeProvider — widget ini rebuild saat toggle()
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Toko Tani Pierre',
      debugShowCheckedModeBanner: false,
      // 4. Gunakan tema yang sudah dibuat di core
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,

      // Tampilkan splash sebagai halaman awal untuk pengecekan token.

      // 6. Daftarkan semua rute dari AppRouter
      routes: AppRouter.routes,
    );
  }
}

// 7. SplashPage: Halaman awal untuk mengecek token tersimpan
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Beri sedikit jeda untuk animasi splash
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Cek apakah ada token di penyimpanan aman
    final token = await SecureStorageService.getToken();

    // Jika token ada, langsung ke Dashboard. Jika tidak, ke Login

    final route = token != null ? AppRouter.dashboard : AppRouter.login;

    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
