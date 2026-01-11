import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AppConstants {
  static final Dio dio = _createDio();
  static const String baseFileUrl = "https://hipster-api.fr";

  // Stream controller to broadcast unauthorized events
  static final StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();

  static Stream<void> get onUnauthorized => _unauthorizedController.stream;

  static String resolveFileUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return baseFileUrl + path;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://hipster-api.fr/api/',
        persistentConnection: true,
        connectTimeout: const Duration(seconds: apiTimeout),
        receiveTimeout: const Duration(seconds: apiTimeout),
      ),
    );

    // Connectivity check interceptor - prevents requests when offline
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check network connectivity before allowing request
          final connectivityResult = await Connectivity().checkConnectivity();
          final isOffline = connectivityResult.contains(
            ConnectivityResult.none,
          );

          if (isOffline) {
            print(
              '🔴 Dio Interceptor: Network offline, blocking request to ${options.path}',
            );
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error:
                    'Pas de connexion Internet. Veuillez vérifier votre connexion.',
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );

    // Authentication interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null && token.isNotEmpty) {
            print(
              'Dio Interceptor: Adding Token: ${token.substring(0, 10)}...',
            );
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print('Dio Interceptor: No Token found in storage');
            // Log all available keys to see if we missed something
            final allKeys = prefs.getKeys();
            print(
              'Dio Interceptor: Available SharedPreferences keys: $allKeys',
            );
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            print(
              '🔴 Dio Interceptor: 401 Unauthorized at ${e.requestOptions.path}',
            );
            print('🔍 Headers Sent: ${e.requestOptions.headers}');
            print('🔍 Response Body: ${e.response?.data}');

            // Si on est déjà en train de rafraîchir pas la peine de boucler
            if (e.requestOptions.path.contains('refresh') ||
                e.requestOptions.path.contains('login')) {
              print('⚠️ Stopping loop: 401 on refresh/login endpoint.');
              return handler.next(e);
            }

            try {
              final prefs = await SharedPreferences.getInstance();
              final refreshToken = prefs.getString('refresh_token');

              if (refreshToken != null) {
                print('Dio Interceptor: Attempting token refresh...');

                // Le backend attend le Refresh Token dans le header Authorization
                // (Guard: AuthGuard('jwt-refresh'))
                final refreshResponse = await dio.post(
                  'refresh',
                  options: Options(
                    headers: {'Authorization': 'Bearer $refreshToken'},
                  ),
                );

                if (refreshResponse.statusCode == 200 ||
                    refreshResponse.statusCode == 201) {
                  // Le backend doit renvoyer les nouveaux tokens.
                  // Adaptez selon la réponse exacte : { accessToken: "...", refreshToken: "..." } ou { data: ... }
                  final data =
                      refreshResponse.data['data'] ?? refreshResponse.data;

                  // Vérifier la structure exacte renvoyée par AuthService.refreshToken
                  final newAccessToken =
                      data['access_token'] ?? data['accessToken'];
                  final newRefreshToken =
                      data['refresh_token'] ?? data['refreshToken'];

                  if (newAccessToken != null) {
                    await prefs.setString('token', newAccessToken);
                    if (newRefreshToken != null) {
                      await prefs.setString('refresh_token', newRefreshToken);
                    }

                    print('Dio Interceptor: Refresh successful, retrying...');

                    // Réessayer la requête originale avec le nouveau token
                    final opts = e.requestOptions;
                    opts.headers['Authorization'] = 'Bearer $newAccessToken';
                    return handler.resolve(await dio.fetch(opts));
                  }
                }
              }
            } catch (refreshError) {
              print('Dio Interceptor: Refresh failed: $refreshError');
            }

            // If we reach here, refresh failed or was not possible
            // Trigger logout flow
            print(
              'Dio Interceptor: Refresh failed or not possible. Triggering global logout.',
            );
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            await prefs.remove('refresh_token');
            await prefs.remove('user_data');
            _unauthorizedController.add(null);
          }
          return handler.next(e);
        },
      ),
    );

    // Ajout d'un logger propre pour voir les requêtes/réponses dans la console
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (log) => print('DIO_LOG: $log'),
      ),
    );

    return dio;
  }

  static const int apiTimeout = 10;
}
