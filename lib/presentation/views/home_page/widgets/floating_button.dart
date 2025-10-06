import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:sistem_pengaduan/presentation/controllers/user_controller.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/form_pengaduan_page/form_pengaduan_screen.dart';
import 'package:sistem_pengaduan/presentation/views/home_page/home_screen.dart';
import 'package:sistem_pengaduan/presentation/views/menubyid_page/menubyid_screen.dart';
import 'package:sistem_pengaduan/presentation/views/user_profile.dart/user_profile_screen.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_confirm_dialog.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

class FloatingButton extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onNavigationChanged;

  const FloatingButton({
    super.key,
    this.currentIndex = 0,
    this.onNavigationChanged,
  });

  @override
  _FloatingButtonState createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> {
  final UserController userController = UserController();

  Future<void> _onItemTapped(int index) async {
    // Jika user tap tab yang sama dengan halaman aktif, tidak perlu navigasi
    if (widget.currentIndex == index) {
      return;
    }

    // Special case: Logout
    if (index == 1) {
      _showLogoutConfirmationDialog();
      return;
    }

    // If callback is provided (from MainNavigationScreen), use it
    if (widget.onNavigationChanged != null) {
      widget.onNavigationChanged!(index);
    } else {
      // Fallback: Legacy navigation for standalone usage
      _navigateToPage(index);
    }
  }

  void _navigateToPage(int index) {
    Widget destination;
    switch (index) {
      case 0:
        destination = const HomeView();
        break;
      case 2:
        destination = const FormPengaduan();
        break;
      case 3:
        destination = const MyPengaduanPage();
        break;
      case 4:
        destination = UserProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  // Method to show the logout confirmation dialog
  void _showLogoutConfirmationDialog() async {
    bool? confirm = await ModernConfirmDialog.show(
      context: context,
      title: 'Konfirmasi Logout',
      content: 'Apakah Anda yakin ingin logout?',
      confirmText: 'Logout',
      cancelText: 'Batal',
    );

    if (confirm == true) {
      _logout(); // Call the logout method
    }
  }

  // Method to handle logout
  Future<void> _logout() async {
    try {
      await userController.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        // Menghapus semua route dari stack
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle logout error
      print('Error during logout: $e');
      ModernSnackBar.showError(
        context,
        'Logout failed: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(55.0, 0.0, 25.0, 6.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26.0),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.62),
                    borderRadius: BorderRadius.circular(26.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.home_outlined),
                        color: widget.currentIndex == 0
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF9AA0A6),
                        onPressed: () => _onItemTapped(0),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_outlined),
                        color: const Color(0xFF9AA0A6),
                        onPressed: () => _onItemTapped(1),
                      ),
                      const SizedBox(width: 60),
                      IconButton(
                        icon: const Icon(Icons.notes_outlined),
                        color: widget.currentIndex == 3
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF9AA0A6),
                        onPressed: () => _onItemTapped(3),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline),
                        color: widget.currentIndex == 4
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF9AA0A6),
                        onPressed: () => _onItemTapped(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8, // Adjust the position of the floating action button
          left: 30,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: () => _onItemTapped(2),
                backgroundColor: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
