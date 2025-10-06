// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:sistem_pengaduan/presentation/controllers/user_controller.dart';
// import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/token_page.dart';
// import 'package:sistem_pengaduan/presentation/views/auth_pages/register_page/register_page.dart';
// import 'package:sistem_pengaduan/presentation/views/auth_pages/welcome_page/welcome_page.dart';
// import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final UserController _userController = UserController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool _obscurePassword = true;

//   // -------------------- INITIALIZE ARGUMENT --------------------

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Periksa jika ada pesan dari navigasi sebelumnya
//       if (ModalRoute.of(context)!.settings.arguments != null) {
//         final String message =
//             ModalRoute.of(context)!.settings.arguments as String;
//         ModernSnackBar.showWarning(context, message);
//       }
//     });
//   }

//   // -------------------- LOGIN USER --------------------

// // vaidasi login user
//   void _loginUser() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         String email = _emailController.text;
//         String password = _passwordController.text;
//         // message dari hasil login
//         String message = await _userController.loginUser(email, password);

//         // Show success message
//         ModernSnackBar.showSuccess(context, message);

//         // Navigate to token page after short delay
//         Future.delayed(const Duration(milliseconds: 600), () {
//           if (context.mounted) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => TokenInputPageLogin(email: email),
//               ),
//             );
//           }
//         });
//       } catch (e) {
//         ModernSnackBar.showError(context, e.toString());
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               const Color(0xFFF8F9FF),
//               Colors.white,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 // Back Button
//                 Row(
//                   children: [
//                     Container(
//                       width: 42,
//                       height: 42,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: IconButton(
//                         icon: const Icon(Icons.arrow_back_ios_new, size: 18),
//                         color: const Color(0xFF6366F1),
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => WelcomePage()),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),

//                 // Logo and Title
//                 Hero(
//                   tag: 'app_logo',
//                   child: Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF6366F1).withOpacity(0.1),
//                           blurRadius: 16,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     padding: const EdgeInsets.all(14),
//                     child:
//                         Image.asset('assets/odyblack.png', fit: BoxFit.contain),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 ShaderMask(
//                   shaderCallback: (bounds) => const LinearGradient(
//                     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                   ).createShader(bounds),
//                   child: Text(
//                     'Welcome Back',
//                     style: GoogleFonts.poppins(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Sign in to continue',
//                   style: GoogleFonts.roboto(
//                     fontSize: 15,
//                     color: const Color(0xFF6B7280),
//                   ),
//                 ),
//                 const SizedBox(height: 40),

//                 // Form Card
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.06),
//                         blurRadius: 20,
//                         offset: const Offset(0, 6),
//                       ),
//                     ],
//                   ),
//                   padding: const EdgeInsets.all(28),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         // Email Field
//                         TextFormField(
//                           controller: _emailController,
//                           style: GoogleFonts.roboto(fontSize: 15),
//                           decoration: InputDecoration(
//                             labelText: 'Email',
//                             labelStyle: GoogleFonts.roboto(
//                                 color: const Color(0xFF6B7280)),
//                             filled: true,
//                             fillColor: const Color(0xFFF8F9FF),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(14),
//                               borderSide: BorderSide.none,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(14),
//                               borderSide:
//                                   BorderSide(color: const Color(0xFFF1F3F5)),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(14),
//                               borderSide: const BorderSide(
//                                   color: Color(0xFF6366F1), width: 2),
//                             ),
//                             prefixIcon: const Icon(Icons.email_outlined,
//                                 color: Color(0xFF6366F1), size: 20),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Email tidak boleh kosong';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 20),

//                         // Password Field
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: _obscurePassword,
//                           style: GoogleFonts.roboto(fontSize: 15),
//                           decoration: InputDecoration(
//                             labelText: 'Password',
//                             labelStyle: GoogleFonts.roboto(
//                                 color: const Color(0xFF6B7280)),
//                             filled: true,
//                             fillColor: const Color(0xFFF8F9FF),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(14),
//                               borderSide: BorderSide.none,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(14),
//                               borderSide:
//                                   BorderSide(color: const Color(0xFFF1F3F5)),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(14),
//                               borderSide: const BorderSide(
//                                   color: Color(0xFF6366F1), width: 2),
//                             ),
//                             prefixIcon: const Icon(Icons.lock_outline,
//                                 color: Color(0xFF6366F1), size: 20),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscurePassword
//                                     ? Icons.visibility_off_outlined
//                                     : Icons.visibility_outlined,
//                                 color: const Color(0xFF9AA0A6),
//                                 size: 20,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _obscurePassword = !_obscurePassword;
//                                 });
//                               },
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Password tidak boleh kosong';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 28),

//                         // Login Button
//                         Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                             ),
//                             borderRadius: BorderRadius.circular(14),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF6366F1).withOpacity(0.3),
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 6),
//                               ),
//                             ],
//                           ),
//                           child: ElevatedButton(
//                             onPressed: _loginUser,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               shadowColor: Colors.transparent,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                             ),
//                             child: Text(
//                               'Login',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Sign Up Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Don't have an account? ",
//                       style: GoogleFonts.roboto(
//                         color: const Color(0xFF6B7280),
//                         fontSize: 14,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const RegisterPage()),
//                         );
//                       },
//                       child: Text(
//                         'Sign Up',
//                         style: GoogleFonts.roboto(
//                           color: const Color(0xFF6366F1),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// ---

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistem_pengaduan/presentation/controllers/user_controller.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/login_user_page/token_page.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/register_page/register_page.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/welcome_page/welcome_page.dart';
import 'package:sistem_pengaduan/presentation/views/widgets/modern_snackbar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  late final AnimationController _pulseController;

  // -------------------- INITIALIZE ARGUMENT --------------------

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
        lowerBound: 0.96,
        upperBound: 1.02)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _pulseController.reverse();
        if (status == AnimationStatus.dismissed) _pulseController.forward();
      });
    _pulseController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Periksa jika ada pesan dari navigasi sebelumnya
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final String message =
            ModalRoute.of(context)!.settings.arguments as String;
        ModernSnackBar.showWarning(context, message);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // -------------------- LOGIN USER --------------------

// vaidasi login user
  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        String email = _emailController.text;
        String password = _passwordController.text;
        // message dari hasil login
        String message = await _userController.loginUser(email, password);

        // Show success message
        ModernSnackBar.showSuccess(context, message);

        // Navigate to token page after short delay
        Future.delayed(const Duration(milliseconds: 600), () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TokenInputPageLogin(email: email),
              ),
            );
          }
        });
      } catch (e) {
        ModernSnackBar.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient mesh background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8F9FF),
                  Colors.white,
                  Color(0xFFFFF8FB),
                  Colors.white,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Floating gradient orbs with rotation
          Positioned(
            left: -100,
            top: -80,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF6366F1).withOpacity(0.15),
                      Color(0xFF8B5CF6).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            right: -90,
            top: MediaQuery.of(context).size.height * 0.2,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFEC4899).withOpacity(0.12),
                      Color(0xFFF59E0B).withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.15,
            bottom: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF8B5CF6).withOpacity(0.1),
                    Color(0xFF6366F1).withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            // Keep this container transparent so the Stack background (gradient mesh + orbs)
            // remains visible and consistent with the token page design.
            color: Colors.transparent,
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (c) => WelcomePage())),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: Offset(0, 2))
                              ],
                            ),
                            child: Icon(Icons.arrow_back_ios_new,
                                color: Color(0xFF6366F1), size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/ody2.png',
                        width: 106,
                        height: 106,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 36),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ).createShader(bounds),
                      child: Text('Sign in to your account',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    const SizedBox(height: 6),
                    Text('Welcome back — please login to continue',
                        style: GoogleFonts.roboto(
                            color: Color(0xFF6B7280), fontSize: 13)),
                    const SizedBox(height: 22),

                    // Enhanced glassmorphism form card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF6366F1).withOpacity(0.08),
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email field with modern styling
                                TextFormField(
                                  controller: _emailController,
                                  style: GoogleFonts.roboto(fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    labelStyle: GoogleFonts.roboto(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                    hintText: 'Enter your email',
                                    hintStyle: GoogleFonts.roboto(
                                      color: Color(0xFF9AA0A6),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.email_outlined,
                                        color: Color(0xFF6366F1),
                                        size: 20,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Color(0xFFF8F9FF).withOpacity(0.6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Color(0xFF6366F1),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Color(0xFFEF4444),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Email tidak boleh kosong'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Password field with modern styling
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: GoogleFonts.roboto(fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: GoogleFonts.roboto(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                    hintText: 'Enter your password',
                                    hintStyle: GoogleFonts.roboto(
                                      color: Color(0xFF9AA0A6),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.lock_outline_rounded,
                                        color: Color(0xFF6366F1),
                                        size: 20,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Color(0xFFF8F9FF).withOpacity(0.6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Color(0xFF6366F1),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Color(0xFFEF4444),
                                        width: 1,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Color(0xFF9AA0A6),
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Password tidak boleh kosong'
                                      : null,
                                ),
                                const SizedBox(height: 24),

                                // Enhanced gradient button with shadow
                                Container(
                                  width: double.infinity,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFF6366F1).withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color:
                                            Color(0xFF8B5CF6).withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _loginUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Sign In',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Don't have an account? ",
                          style: GoogleFonts.roboto(color: Color(0xFF6B7280))),
                      GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => RegisterPage())),
                          child: Text('Sign Up',
                              style: GoogleFonts.roboto(
                                  color: Color(0xFF6366F1),
                                  fontWeight: FontWeight.w600)))
                    ]),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
