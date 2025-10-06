import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/presentation/controllers/user_controller.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/register_page/email_verified_page.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/register_page/register_page.dart';

class TokenInputPage extends StatefulWidget {
  final String email;
  TokenInputPage({required this.email});

  @override
  _TokenInputPageState createState() => _TokenInputPageState();
}

class _TokenInputPageState extends State<TokenInputPage> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(4, (index) => FocusNode());

  String obscureEmail(String email) {
    var parts = email.split('@');
    if (parts[0].length > 2) {
      var firstPart = parts[0].substring(0, 2);
      var lastPart = parts[0].substring(2).replaceAll(RegExp(r'.'), '*');
      return '$firstPart$lastPart@${parts[1]}';
    }
    return email;
  }

  late Timer _timer;
  bool _isOtpVerified = false;

  @override
  void initState() {
    super.initState();
    _startOtpStatusCheck();
  }

  void _startOtpStatusCheck() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await _checkOtpStatus();
    });
  }

  Future<void> _checkOtpStatus() async {
    if (_isOtpVerified) return;
    try {
      bool isOtpActive = await _userController.checkOtpStatus(widget.email);
      if (!isOtpActive) {
        _timer.cancel();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterPage(),
              settings:
                  RouteSettings(arguments: "Maaf, kode OTP sudah kadaluwarsa")),
          (route) => false,
        );
      }
    } catch (e) {
      print('Gagal memeriksa status OTP: $e');
    }
  }

  String _otp = '';

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      _otp = _otpControllers.map((controller) => controller.text).join();
      try {
        String message = await _userController.verifyOtp(_otp);
        _isOtpVerified = true;
        _timer.cancel();

        ModernSnackBar.showSuccess(context, message);

        Future.delayed(const Duration(milliseconds: 800), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EmailVerifiedPage()),
            );
          }
        });
      } catch (e) {
        ModernSnackBar.showError(context, e.toString());
      }
    }
  }

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
    String obfuscatedEmail = obscureEmail(widget.email);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF8F9FF),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child:
                        Image.asset('assets/odyblack.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 32),

                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ).createShader(bounds),
                  child: Text(
                    'Enter OTP Code',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 18, color: Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      Text(
                        obfuscatedEmail,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // OTP Input Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'We sent a code to your email',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // OTP Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color(0xFF6366F1).withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: TextFormField(
                                controller: _otpControllers[index],
                                focusNode: _otpFocusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6366F1),
                                ),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  if (value.length == 1 && index < 3) {
                                    _otpFocusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _otpFocusNodes[index - 1].requestFocus();
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '';
                                  }
                                  return null;
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),

                        // Verify Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Verify Code',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Resend Code
                TextButton(
                  onPressed: () {
                    // TODO: Implement resend OTP
                  },
                  child: Text(
                    'Didn\'t receive the code? Resend',
                    style: GoogleFonts.roboto(
                      color: const Color(0xFF6366F1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
