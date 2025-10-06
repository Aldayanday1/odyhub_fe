import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_admin_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/login_page.dart';

class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.88,
      upperBound: 1.02,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _logoController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _logoController.forward();
        }
      });
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient mesh background (shared with other auth pages)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.3, 0.6, 1.0],
                colors: [
                  Color(0xFFF8F9FF),
                  Colors.white,
                  Color(0xFFFFF8FB),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Floating Orb 1 - Top Left (subtle)
          Positioned(
            top: -100,
            left: -80,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF6366F1).withOpacity(0.12),
                      Color(0xFF8B5CF6).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Orb 2 - Right
          Positioned(
            top: MediaQuery.of(context).size.height * 0.28,
            right: -60,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFEC4899).withOpacity(0.10),
                      Color(0xFFF59E0B).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Orb 3 - Bottom Left
          Positioned(
            bottom: -100,
            left: MediaQuery.of(context).size.height * 0.15,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF8B5CF6).withOpacity(0.08),
                    Color(0xFF6366F1).withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Decorative gradient blobs (kept from previous design)
          Positioned(
            top: -60,
            left: -80,
            child: _buildBlob(
                220, 220, const [Color(0xFFB9C6FF), Color(0xFF7C81F3)], 0.15),
          ),
          Positioned(
            bottom: -80,
            right: -100,
            child: _buildBlob(
                300, 300, const [Color(0xFFF1C6FF), Color(0xFFB08CFF)], 0.12),
          ),

          // Full screen content
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: MediaQuery.of(context).padding.top + 14,
            ),
            child: Column(
              children: [
                // subtle header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (c) => LoginPage()));
                        },
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.roboto(
                              color: const Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/ody2.png',
                              width: 106,
                              height: 106,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Welcome to',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ).createShader(bounds),
                            child: Text(
                              'OdyHub',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 36.0),
                            child: Text(
                              'Public service enhancement reporting — report, track and collaborate',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // CTA
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF6366F1).withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Color(0xFF8B5CF6).withOpacity(0.18),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => LoginPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Center(
                                child: Text(
                                  'Get Started',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: BackdropFilter(
                              filter:
                                  ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.6)),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (c) => AdminLoginPage()),
                                    );
                                  },
                                  child: Text(
                                    'Admin',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF6366F1),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Decorative gradient blob used in background
  Widget _buildBlob(double w, double h, List<Color> colors, double opacity) {
    return Transform.rotate(
      angle: -0.3,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: colors,
              center: Alignment.center,
              radius: 0.9,
            ),
            borderRadius: BorderRadius.circular(w),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  )
                : null,
            color: isPrimary ? null : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary
                  ? Colors.transparent
                  : const Color(0xFF6366F1).withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isPrimary
                    ? const Color(0xFF6366F1).withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isPrimary ? 16 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isPrimary ? Colors.white : const Color(0xFF6366F1),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isPrimary ? Colors.white : const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


          // Positioned.fill(
          //   child: Center(
          //     child: Lottie.network(
          //       'https://lottie.host/9d0bbb96-6a35-4baf-88ea-ceaa80ae9b07/uldMBV0vzi.json',
          //       width: 200,
          //       height: 200,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),