import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/jember_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.5;

  @override
  void initState() {
    super.initState();
    // Start animation on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    // Navigate after 2500ms
    Timer(const Duration(milliseconds: 2500), () async {
      if (mounted) {
        final provider = Provider.of<JemberProvider>(context, listen: false);
        final isLoggedIn = await provider.checkLoginSession();
        if (mounted) {
          if (isLoggedIn) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8F4C38), // PrimaryGreen (Terracotta)
              Color(0xFF003D2A), // Dark Green
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Entrance Logo
                AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 1000),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.landscape,
                        size: 80,
                        color: Color(0xFFE57E22), // SecondaryAmber
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'JemberGuide',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aplikasi Pencarian Wisata Terbaik di Jember',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Color(0xFFE57E22), // SecondaryAmber
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 32,
              child: Text(
                'Uji Kompetensi Keahlian • v1.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
