import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/layouts/client_layout.dart';
import 'package:tiko_tiko/modules/client/devis_facture/views/invoice_screen.dart';
import 'package:tiko_tiko/modules/client/loyality/views/loyalty_screen.dart';
import 'package:tiko_tiko/modules/client/notification/views/notification_screen.dart';
import 'package:tiko_tiko/modules/client/ticket/views/ticket_detail_screen.dart';
import 'package:tiko_tiko/modules/client/ticket/views/ticket_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiko_tiko/modules/client/devis_facture/bloc/invoice_bloc.dart';
import 'package:tiko_tiko/modules/client/dashboard/services/dashboard_repository.dart';

// === AUTH & ONBOARDING ===
import 'package:tiko_tiko/modules/auth/views/onboarding_screen.dart';
import 'package:tiko_tiko/modules/auth/views/login_screen.dart';
import 'package:tiko_tiko/modules/auth/views/register_screen.dart';
import 'package:tiko_tiko/modules/auth/views/otp_verification_screen.dart';
import 'package:tiko_tiko/modules/auth/views/forgot_password_screen.dart';
import 'package:tiko_tiko/modules/auth/views/reset_otp_screen.dart';

// === CLIENT ===
import 'package:tiko_tiko/modules/client/dashboard/views/dashboard_screen.dart';
import 'package:tiko_tiko/modules/auth/views/profile_screen.dart';
import 'package:tiko_tiko/modules/client/project/views/project_screen.dart';
import 'package:tiko_tiko/modules/client/project/views/project_detail_screen.dart';
import 'package:tiko_tiko/shared/models/project_model.dart';

class AppRouter {
  AppRouter();

  GoRouter getRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: _GoRouterRefreshStream(
        context.read<AuthBloc>().stream,
      ),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        print(
          'AppRouter: Redirect check - state: $authState, path: ${state.matchedLocation}',
        );

        final bool isPublicPath =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/otp-verification' ||
            state.matchedLocation == '/forgot-password' ||
            state.matchedLocation == '/reset-otp' ||
            state.matchedLocation == '/';

        if (authState is AuthInitial) {
          // Au démarrage, on attend que AuthStartupChecked s'exécute
          return null;
        }

        if (authState is AuthOnboarding) {
          if (state.matchedLocation != '/') {
            return '/';
          }
          return null;
        }

        if (authState is AuthUnauthenticated || authState is AuthFailure) {
          // Onboarding est fini (ou on est en échec), donc '/' n'est plus autorisé.
          // On ne permet que /login, /register, /otp-verification.
          final bool isAllowedPublicPath =
              state.matchedLocation == '/login' ||
              state.matchedLocation == '/register' ||
              state.matchedLocation == '/otp-verification' ||
              state.matchedLocation == '/forgot-password' ||
              state.matchedLocation == '/reset-otp' ||

          if (!isAllowedPublicPath) {
            print('AppRouter: Unauthenticated, redirecting to /login');
            return '/login';
          }
          return null;
        }

        if (authState is AuthNeedsVerification) {
          if (state.matchedLocation != '/otp-verification') {
            print(
              'AppRouter: Needs verification, redirecting to /otp-verification',
            );
            return '/otp-verification';
          }
          return null;
        }

        if (authState is AuthAuthenticated) {
          if (isPublicPath) {
            print('AppRouter: Authenticated, redirecting to /client/dashboard');
            return '/client/dashboard';
          }

          // Force completion du profil client si incomplet
          if (authState.user.isClient &&
              !authState.user.isProfileComplete &&
              state.matchedLocation != '/profile') {
            print(
              'AppRouter: Profile incomplete, forcing redirect to /profile',
            );
            return '/profile';
          }
        }

        return null;
      },
      routes: [
        // === PUBLIC ===
        GoRoute(
          path: '/',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/otp-verification',
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return OtpVerificationScreen(email: email);
          },
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-otp',
          builder: (context, state) {
            final email = state.extra as String? ?? '';
            return ResetOtpScreen(email: email);
          },
        ),

        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // === CLIENT SHELL ===
        ShellRoute(
          builder: (context, state, child) => ClientLayout(child: child),
          routes: [
            GoRoute(
              path: '/client/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/client/projects',
              builder: (context, state) => const ProjectScreen(),
            ),
            GoRoute(
              path: '/client/projects/:id',
              builder: (context, state) {
                final project = state.extra as ProjectModel?;
                final idStr = state.pathParameters['id'];
                final id = idStr != null ? int.tryParse(idStr) : null;
                return ProjectDetailScreen(project: project, projectId: id);
              },
            ),
            GoRoute(
              path: '/client/invoices',
              builder: (context, state) => BlocProvider(
                create: (context) =>
                    InvoiceBloc(DashboardRepository())
                      ..add(InvoiceLoadRequested()),
                child: const InvoiceScreen(),
              ),
            ),
            GoRoute(
              path: '/client/tickets',
              builder: (_, __) => const TicketScreen(),
            ),
            GoRoute(
              path: '/client/ticket/:id',
              builder: (_, state) {
                final id = state.pathParameters['id']!;
                return TicketDetailScreen(id: id);
              },
            ),
            GoRoute(
              path: '/client/loyalty',
              builder: (context, state) => const LoyaltyScreen(),
            ),
            GoRoute(
              path: '/client/notifications',
              builder: (context, state) => const NotificationScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
    // Move notifyListeners AFTER assignment to prevent potential access in dispose() if triggered immediately
    notifyListeners();
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    // Only cancel if initialized to be extra safe
    // Note: late variables can't be checked for initialization easily in some cases,
    // but assignment before notifyListeners should fix the race condition.
    _subscription.cancel();
    super.dispose();
  }
}
