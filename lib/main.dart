import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tiko_tiko/app_router.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/shared/blocs/network/network_bloc.dart';
import 'package:tiko_tiko/shared/blocs/notification/notification_bloc.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_service.dart';
import 'package:tiko_tiko/shared/blocs/network/network_service.dart';
import 'package:tiko_tiko/shared/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tiko_tiko/shared/blocs/network/network_state.dart';
import 'package:tiko_tiko/modules/client/project/services/project_repository.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_bloc.dart';
import 'package:tiko_tiko/modules/client/ticket/services/ticket_repository.dart';
import 'package:tiko_tiko/modules/client/ticket/bloc/ticket_bloc.dart';
import 'package:tiko_tiko/shared/blocs/ui/ui_cubit.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);

  // Initialize Stripe
  Stripe.publishableKey =
      "pk_test_51SCdoeFivno0gXseuoYu1NyiROIxnSsMt7XYpOFnFdSt1twAvlCkTHOfCZSDTqPI5XDpIDupOsTTKvX62anb3cLb00gl5ceTPP";
  await Stripe.instance.applySettings();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.manual,
    //   overlays: [SystemUiOverlay.top],
    // );
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(AuthService())..add(AuthStartupChecked()),
        ),
        BlocProvider(create: (_) => NetworkBloc(NetworkService())),
        BlocProvider(create: (_) => NotificationBloc()),
        BlocProvider(create: (_) => ProjectBloc(ProjectRepository())),
        BlocProvider(create: (_) => TicketBloc(TicketRepository())),
        BlocProvider(create: (_) => UiCubit()),
      ],
      child: const AuthListenerWrapper(),
    );
  }
}

class AuthListenerWrapper extends StatefulWidget {
  const AuthListenerWrapper({super.key});

  @override
  State<AuthListenerWrapper> createState() => _AuthListenerWrapperState();
}

class _AuthListenerWrapperState extends State<AuthListenerWrapper> {
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = AppConstants.onUnauthorized.listen((_) {
      if (mounted) {
        context.read<AuthBloc>().add(AuthLogoutRequested());
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hipster Marketing',
      theme: AppTheme.zincLight,
      routerConfig: AppRouter().getRouter(context),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            BlocBuilder<NetworkBloc, NetworkState>(
              builder: (context, state) {
                final isOffline = state.connectionStatus.contains(
                  ConnectivityResult.none,
                );
                if (!isOffline) return const SizedBox.shrink();

                return Positioned.fill(
                  child: Stack(
                    children: [
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                        child: Container(color: Colors.black.withOpacity(0.4)),
                      ),
                      Center(
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 48,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Connexion Perdue",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Veuillez vérifier votre connexion internet\npour continuer.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
