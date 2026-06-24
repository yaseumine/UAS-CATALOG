import 'package:catalog/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 2.0)),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Expanded(child: Divider(color: AppColors.border, thickness: 2.0)),
      ],
    );
  }
}

// Penggunaan:
// DividerWithText(text: 'atau')   →   ─────── atau ───────
