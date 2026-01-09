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
    final size = MediaQuery.of(context).size;

    // Logo responsive : entre 28% et 40% de la hauteur de l'écran
    final double logoSize = size.height * 0.28;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// LOGO RESPONSIVE + ANIMATION
            Image.asset(
                  'assets/images/logo.png',
                  width: logoSize,
                  height: logoSize,
                )
                .animate()
                .fade(duration: 800.ms)
                .scale(
                  delay: 300.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 28),

            /// TEXTE ANIMÉ
            Text(
                  "Hipster Marketing",
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Outfit',
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 700.ms, duration: 900.ms)
                .moveY(
                  begin: 12,
                  end: 0,
                  delay: 700.ms,
                  duration: 600.ms,
                  curve: Curves.easeOut,
                )
                .shimmer(delay: 1500.ms, duration: 1500.ms),
          ],
        ),
      ),
    );
  }
}
