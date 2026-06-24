import 'package:catalog/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, outlined, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == ButtonVariant.primary;
    final contentColor = isPrimary ? Colors.white : AppColors.textPrimary;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: contentColor,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: contentColor),
                  child: icon!,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                ),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: switch (variant) {
        ButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side: const BorderSide(color: AppColors.primaryDark, width: 2.0),
            ),
            elevation: 0.0,
          ),
          child: child,
        ),

        ButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.primaryDark, width: 2.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          child: child,
        ),

        ButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: child,
        ),
      },
    );
  }
}

// Contoh penggunaan:
// CustomButton(label: 'Daftar', onPressed: _register, isLoading: isLoading)
// CustomButton(label: 'Batal', variant: ButtonVariant.outlined, onPressed: () {})
