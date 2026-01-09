import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/shared/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      image: 'assets/images/logo.png',
      title: 'Bienvenue sur Hipster Marketing',
      description:
          'Suivez facilement vos projets et restez informé à chaque étape, tout en centralisant vos interactions avec notre équipe.',
    ),
    OnboardingItem(
      image: 'assets/images/logo.png',
      title: 'Tickets et Support',
      description:
          'Créez et suivez vos tickets directement dans l’application. Recevez des notifications push et des emails à chaque mise à jour.',
    ),
    OnboardingItem(
      image: 'assets/images/logo.png',
      title: 'Factures et Paiements',
      description:
          'Consultez vos devis et factures, payez en toute sécurité via Stripe ou PayPal, et recevez un reçu automatique par email.',
    ),
    OnboardingItem(
      image: 'assets/images/logo.png',
      title: 'Fidélité et Récompenses',
      description:
          'Profitez de notre programme de fidélité et de parrainage : réductions, mois offerts et avantages VIP pour vos projets signés.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xfffefdfb),
        body: Stack(
          children: [
            // 🔹 PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemCount: _items.length,
              itemBuilder: (context, index) =>
                  OnboardingPage(item: _items[index]),
            ),

            // 🔹 Overlay: boutons + indicateurs
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        TextButton(
                          child: Text(
                            'Passer',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              AuthOnboardingCompletedRequested(),
                            );
                            context.go('/login');
                          },
                        ),
                      ],
                    ),

                    const Spacer(),

                    // 🔥 INDICATEURS EFFET GOUTTE D’EAU
                    WaterDropIndicator(
                      count: _items.length,
                      currentIndex: _currentPage,
                    ),

                    const SizedBox(height: 30),

                    // 🔹 Bouton principal
                    CustomButton(
                      text: _currentPage == _items.length - 1
                          ? 'Commencer'
                          : 'Suivant',
                      onPressed: () {
                        if (_currentPage == _items.length - 1) {
                          context.read<AuthBloc>().add(
                            AuthOnboardingCompletedRequested(),
                          );
                          context.go('/login');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 🔹 MODELE OnboardingItem
// ---------------------------------------------------------------------------

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

// ---------------------------------------------------------------------------
// 🔹 PAGE Onboarding avec animations
// ---------------------------------------------------------------------------

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return Opacity(
              opacity: scale,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxHeight * 0.4,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(item.image),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TweenAnimationBuilder<Offset>(
                  tween: Tween(begin: const Offset(0, 0.2), end: Offset.zero),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: offset * constraints.maxHeight,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 600),
                        opacity: 1,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 🔥 WaterDropIndicator (effet goutte d’eau)
// ---------------------------------------------------------------------------

class WaterDropIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const WaterDropIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 22 : 10, // ← goutte qui s’étire
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(50),
          ),
        );
      }),
    );
  }
}
