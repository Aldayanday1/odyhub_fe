import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern confirmation dialog with consistent styling
/// Based on the design pattern from custom_drawer logout dialog
class ModernConfirmDialog {
  /// Show a modern styled confirmation dialog
  ///
  /// [context] - BuildContext
  /// [title] - Dialog title (e.g., "Konfirmasi Logout")
  /// [content] - Dialog content/message (e.g., "Apakah Anda yakin ingin keluar?")
  /// [confirmText] - Text for confirm button (default: "Ya")
  /// [cancelText] - Text for cancel button (default: "Batal")
  /// [isDanger] - If true, uses red accent for confirm button (default: false)
  ///
  /// Returns [bool] - true if confirmed, false if cancelled, null if dismissed
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    bool isDanger = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20.5,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800],
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.roboto(
              fontSize: 12.5,
              color: Colors.blueGrey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: GoogleFonts.roboto(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDanger
                    ? Colors.red[400]
                    : Color.fromARGB(255, 58, 58, 58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                confirmText,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
