import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistem_pengaduan/presentation/views/auth_pages/welcome_page/welcome_page.dart';

class OnboardingScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const OnboardingScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;

  final pages = [
    {
      'title': 'Laporan lebih mudah',
      'subtitle': 'Buat dan pantau laporan publik secara cepat dan terstruktur',
      'lottie': 'https://assets10.lottiefiles.com/packages/lf20_x62chJ.json'
    },
    {
      'title': 'Pantau perkembangan',
      'subtitle': 'Terima update dan notifikasi status secara real-time',
      'lottie': 'https://assets10.lottiefiles.com/packages/lf20_0yfsb3a1.json'
    }
  ];

  void _next() async {
    if (_index < pages.length - 1) {
      setState(() => _index++);
    } else {
      await widget.prefs.setBool('onboarding_seen', true);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => WelcomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[_index];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 260,
                      child: Lottie.network(page['lottie'] as String),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      page['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      page['subtitle'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      await widget.prefs.setBool('onboarding_seen', true);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomePage()));
                    },
                    child: const Text('Skip'),
                  ),
                  Row(
                    children: List.generate(
                      pages.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _index == i ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _index == i
                              ? Color(0xFF6366F1)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                    ),
                    child: const Text('Next'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
