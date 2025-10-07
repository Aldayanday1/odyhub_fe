import 'package:flutter/material.dart';
import 'package:sistem_pengaduan/presentation/views/form_pengaduan_page/form_pengaduan_screen.dart';
import 'package:sistem_pengaduan/presentation/views/home_page/home_screen.dart';
import 'package:sistem_pengaduan/presentation/views/menubyid_page/menubyid_screen.dart';
import 'package:sistem_pengaduan/presentation/views/user_profile.dart/user_profile_screen.dart';
import 'package:sistem_pengaduan/presentation/views/home_page/widgets/floating_button.dart';
import 'package:sistem_pengaduan/presentation/views/home_page/widgets/custom_drawer.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

/// MainNavigationScreen - Manages all main app screens with persistent FloatingButton
/// This prevents the "flick" effect by keeping all screens in memory using IndexedStack
/// Drawer is at this level to ensure it appears above FloatingButton
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Check if there's a success message from edit screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        ModernSnackBar.showSuccess(context, args);
      }
    });
  }

  // Callback untuk mengubah halaman dari FloatingButton
  void _onNavigationChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Method untuk membuka drawer dari child screens
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Allow the body to extend behind the scaffold's bottom (so the
      // custom floating button can render flush to the physical screen
      // edge). This enables an 'edge-to-edge' look for the FAB.
      extendBody: true,
      drawer: const CustomDrawer(),
      // Use a Stack so we can absolutely position the custom
      // `FloatingButton` at the exact bottom center of the screen.
      // Keeping `drawer` at Scaffold level ensures the drawer will
      // appear above the FAB when opened.
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeView(onMenuTap: _openDrawer), // Home - index 0
              const HomeView(), // Placeholder for logout (handled in FloatingButton) - index 1
              const FormPengaduan(), // Form Pengaduan - index 2
              const MyPengaduanPage(), // My Pengaduan - index 3
              UserProfilePage(), // Profile - index 4
            ],
          ),

          // Place the custom FloatingButton at the bottom center. The
          // widget itself handles safe-area insets to push the visual
          // FAB into the physical screen edge when desired.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingButton(
              currentIndex: _currentIndex,
              onNavigationChanged: _onNavigationChanged,
            ),
          ),
        ],
      ),
    );
  }
}
