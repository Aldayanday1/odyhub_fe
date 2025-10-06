import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/presentation/controllers/user_controller.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/login_page.dart';
import 'package:sistem_pengaduan/presentation/views/main_navigation/main_navigation_screen.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

class TokenInputPageLogin extends StatefulWidget {
  final String email;
  TokenInputPageLogin({required this.email});

  @override
  _TokenInputPageLoginState createState() => _TokenInputPageLoginState();
}

class _TokenInputPageLoginState extends State<TokenInputPageLogin> {
  // ----------------- VALIDATE FORM & VERIFY OTP -----------------
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();

  // ----------------- OTP CONTROLLER -----------------
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(4, (index) => FocusNode());

  // ----------------- OBSCURE EMAIL -----------------
  String obscureEmail(String email) {
    // Pisahkan email menjadi dua bagian, sebelum dan sesudah '@'
    var parts = email.split('@');

    // Jika bagian sebelum '@' memiliki panjang lebih dari 2 karakter
    if (parts[0].length > 2) {
      // Ambil 2 karakter pertama dari bagian sebelum '@'
      var firstPart = parts[0].substring(0, 2);

      // Ganti semua karakter setelah 2 karakter pertama dengan '*'
      var lastPart = parts[0].substring(2).replaceAll(RegExp(r'.'), '*');

      // Gabungkan kembali bagian yang sudah disamarkan dengan bagian setelah '@'
      return '$firstPart$lastPart@${parts[1]}';
    }

    // Jika bagian sebelum '@' tidak lebih dari 2 karakter, kembalikan email asli
    return email;
  }

  // ----------------- CHECK OTP STATUS -----------------
  late Timer _timer;
  bool _isOtpVerified = false; // Tambahkan flag ini

  @override
  void initState() {
    super.initState();
    _startOtpStatusCheck();
  }

  // cek perubahan pada status otp setiap 1 detik
  void _startOtpStatusCheck() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await _checkOtpStatus();
    });
  }

  // cek status dari otp, apakah masih valid?
  Future<void> _checkOtpStatus() async {
    if (_isOtpVerified) return; // Jangan cek status OTP jika sudah diverifikasi
    try {
      bool isOtpActive = await _userController.checkOtpStatus(widget.email);
      if (!isOtpActive) {
        // Jika OTP tidak aktif, kembali ke halaman Login
        _timer.cancel();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage(),
              settings:
                  RouteSettings(arguments: "Maaf, kode OTP sudah kadaluwarsa")),
          (route) => false, // Hapus semua route sebelumnya
        );
      }
    } catch (e) {
      print('Gagal memeriksa status OTP: $e');
      // Handle error, misalnya dengan menampilkan pesan kesalahan
    }
  }

  // ----------------- VERIFY OTP -----------------
  String _otp = '';

//  validasi otp
  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      _otp = _otpControllers.map((controller) => controller.text).join();
      try {
        await _userController.loginWithOtp(_otp);
        _isOtpVerified = true;
        _timer.cancel();

        // Navigate to home page after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        ).then((_) {
          // Show SnackBar after navigation completes
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              ModernSnackBar.showSuccess(context, 'Login berhasil');
            }
          });
        });
      } catch (e) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        ModernSnackBar.showError(context, errorMessage);
      }
    }
  }

  // ----------------- TIMER FOR DISPOSE -----------------
  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ------ SAMARAN EMAIL -------
    String obfuscatedEmail = obscureEmail(widget.email);
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Mesh Background
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
          // Floating Orb 1 - Top Left
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
                      Color(0xFF6366F1).withOpacity(0.15),
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
            top: MediaQuery.of(context).size.height * 0.3,
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
                      Color(0xFFEC4899).withOpacity(0.12),
                      Color(0xFFF59E0B).withOpacity(0.06),
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
                    Color(0xFF8B5CF6).withOpacity(0.1),
                    Color(0xFF6366F1).withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Simple Logo with Hero
                      Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/ody2.png',
                          width: 106,
                          height: 106,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 48),
                      // Title with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ).createShader(bounds),
                        child: Text(
                          'Verification OTP',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'We sent a code to',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 10),
                      // Email display
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF6366F1).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.email_rounded,
                              color: Color(0xFF6366F1),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              obfuscatedEmail,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      // Helper text
                      Text(
                        'Enter 4-digit code',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Color(0xFF9AA0A6),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 20),
                      // OTP Input Boxes (No Container Wrapper)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 68,
                            height: 68,
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color(0xFF6366F1).withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF6366F1).withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: TextFormField(
                                controller: _otpControllers[index],
                                focusNode: _otpFocusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                maxLength: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF1A1A1A),
                                  height: 1.1,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Color(0xFFEF4444),
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Color(0xFFEF4444),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 18,
                                  ),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  if (value.length == 1 && index < 3) {
                                    FocusScope.of(context).requestFocus(
                                        _otpFocusNodes[index + 1]);
                                  } else if (value.isEmpty && index > 0) {
                                    FocusScope.of(context).requestFocus(
                                        _otpFocusNodes[index - 1]);
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 48),
                      // Verify Button with enhanced styling
                      Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6366F1).withOpacity(0.4),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Color(0xFF8B5CF6).withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Verify Code',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Resend Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement resend code
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Resend",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Additional helper text
                      Text(
                        'Code expires in 5 minutes',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Color(0xFF9AA0A6),
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
