import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:catalog/features/auth/presentation/providers/theme_provider.dart';

class AccountDialog extends StatelessWidget {
  const AccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return AlertDialog(
      title: const Text('Pengaturan Tampilan'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // KODE SWITCH TEMA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    size: 20,
                    color: isDark ? Colors.amber : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isDark ? 'Mode Gelap' : 'Mode Terang',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Switch(
                value: isDark,
                onChanged: (_) => context.read<ThemeProvider>().toggle(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
