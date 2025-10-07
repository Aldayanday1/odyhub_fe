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
    if (widget.currentIndex == index) return;

    if (index == 1) {
      _showLogoutConfirmationDialog();
      return;
    }

    if (widget.onNavigationChanged != null) {
      widget.onNavigationChanged!(index);
    } else {
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

  void _showLogoutConfirmationDialog() async {
    bool? confirm = await ModernConfirmDialog.show(
      context: context,
      title: 'Konfirmasi Logout',
      content: 'Apakah Anda yakin ingin logout?',
      confirmText: 'Logout',
      cancelText: 'Batal',
    );

    if (confirm == true) {
      _logout();
    }
  }

  Future<void> _logout() async {
    try {
      await userController.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ModernSnackBar.showError(context, 'Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter, // nempel di bawah layar
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom, // safe area aware
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Navigation bar container
            Container(
              height: 72,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.68),
                borderRadius: BorderRadius.circular(26.0),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26.0),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
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
                      const SizedBox(width: 60), // space for the fab
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

            // Floating action button (tengah)
            Positioned(
              bottom: 8, // Adjust the position of the floating action button
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'main_fab',
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
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
