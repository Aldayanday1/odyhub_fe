import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern SnackBar Helper
/// Provides stylish, minimalist SnackBar notifications with consistent design
class ModernSnackBar {
  // Design constants
  static const Color kDarkGrey = Color(0xFF2D3748);
  static const Color kMediumGrey = Color(0xFF4A5568);
  static const Color kLightGrey = Color(0xFF6B7280);
  static const Color kAccentPrimary = Color(0xFF6366F1);
  static const Color kAccentSecondary = Color(0xFF8B5CF6);
  static const Color kSuccessGreen = Color(0xFF10B981);
  static const Color kWarningOrange = Color(0xFFF59E0B);
  static const Color kErrorRed = Color(0xFFEF4444);

  /// Show a success SnackBar with modern styling
  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message,
      icon: Icons.check_circle_rounded,
      iconColor: kSuccessGreen,
      accentColor: kSuccessGreen,
    );
  }

  /// Show an error SnackBar with modern styling
  static void showError(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message,
      icon: Icons.error_rounded,
      iconColor: kErrorRed,
      accentColor: kErrorRed,
    );
  }

  /// Show a warning SnackBar with modern styling
  static void showWarning(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message,
      icon: Icons.warning_rounded,
      iconColor: kWarningOrange,
      accentColor: kWarningOrange,
    );
  }

  /// Show an info SnackBar with modern styling
  static void showInfo(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message,
      icon: Icons.info_rounded,
      iconColor: kAccentPrimary,
      accentColor: kAccentPrimary,
    );
  }

  /// Show a custom SnackBar with full control
  static void showCustom(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? iconColor,
    Color? accentColor,
  }) {
    _showCustomSnackBar(
      context,
      message,
      icon: icon ?? Icons.notifications_rounded,
      iconColor: iconColor ?? kAccentPrimary,
      accentColor: accentColor ?? kAccentPrimary,
    );
  }

  /// Internal method to build and show the custom SnackBar
  static void _showCustomSnackBar(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
  }) {
    final snackBar = SnackBar(
      content: Container(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // Icon container with gradient background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Message text
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            // Accent bar indicator
            const SizedBox(width: 12),
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: kDarkGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: accentColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.horizontal,
      action: SnackBarAction(
        label: '✕',
        textColor: Colors.white.withOpacity(0.8),
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show a SnackBar with custom gradient background
  static void showGradient(
    BuildContext context,
    String message, {
    IconData? icon,
    List<Color>? gradientColors,
  }) {
    final gradient = gradientColors ??
        [
          kAccentPrimary,
          kAccentSecondary,
        ];

    // Wrap with gradient container
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon ?? Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
        action: SnackBarAction(
          label: '✕',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
