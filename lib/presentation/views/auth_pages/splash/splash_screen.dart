import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/splash/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const SplashScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), () async {
      final seen = widget.prefs.getBool('onboarding_seen') ?? false;
      if (seen) {
        Navigator.pushReplacementNamed(context, '/welcome');
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => OnboardingScreen(prefs: widget.prefs)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              child: Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_x62chJ.json',
                repeat: false,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'OdyHub',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
