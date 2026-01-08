import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:tiko_tiko/shared/blocs/ui/ui_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);

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
        BlocProvider(create: (_) => UiCubit()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Hipster',
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

                      return Positioned(
                        top: MediaQuery.of(context).padding.top,
                        left: 0,
                        right: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.red.withAlpha((0.9 * 255).round()),
                            child: const Center(
                              child: Text(
                                "Non connecté",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
