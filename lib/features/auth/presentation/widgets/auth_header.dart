import 'package:catalog/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.accent;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: AppColors.primaryDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryDark,
                offset: Offset(4, 4),
                blurRadius: 0.0,
              ),
            ],
          ),
          child: Icon(icon, size: 48, color: effectiveIconColor),
        ),
        const SizedBox(height: 24),

        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
