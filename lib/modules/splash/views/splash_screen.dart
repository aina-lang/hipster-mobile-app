import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/images/logo.png', width: 150, height: 150)
                .animate()
                .fade(duration: 800.ms)
                .scale(
                  delay: 300.ms,
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 24),

            // Animated Text
            Text(
                  "Hipster Marketing",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontFamily:
                        'Outfit', // Assuming you use this font or default
                    letterSpacing: 1.2,
                  ),
                )
                .animate()
                .fadeIn(delay: 800.ms, duration: 800.ms)
                .shimmer(delay: 1500.ms, duration: 1500.ms)
                .moveY(
                  begin: 10,
                  end: 0,
                  delay: 800.ms,
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}
