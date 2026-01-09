import 'dart:async';
import 'package:flutter/material.dart';
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
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(context.read<AuthBloc>());
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
      routerConfig: _appRouter.router,
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
