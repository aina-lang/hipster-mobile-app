import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  static final Dio dio = _createDio();
 static const String baseFileUrl = "https://hipster-api.fr";
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
              'Dio Interceptor: 401 Unauthorized at ${e.requestOptions.path}',
            );

            final prefs = await SharedPreferences.getInstance();
            print(
              'Dio Interceptor: 401 Debug - token key: ${prefs.getString('token') != null}, refresh_token key: ${prefs.getString('refresh_token') != null}',
            );
            print('Dio Interceptor: 401 Debug - all keys: ${prefs.getKeys()}');

            // Si on est déjà en train de rafraîchir ou si c'est déjà l'URL de login/refresh, on évite la boucle
            if (e.requestOptions.path.contains('refresh') ||
                e.requestOptions.path.contains('login')) {
              return handler.next(e);
            }

            // Tentative de refresh
            try {
              final prefs = await SharedPreferences.getInstance();
              final refreshToken = prefs.getString('refresh_token');

              if (refreshToken != null) {
                print('Dio Interceptor: Attempting token refresh...');
                // Utilisation d'une instance DIO séparée ou appel direct pour éviter les intercepteurs en boucle sur le /refresh si besoin
                // Mais ici on utilise le même dio, d'où le check .contains('refresh') au dessus.
                final response = await dio.post(
                  'refresh',
                  data: {'refreshToken': refreshToken},
                );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  // Le backend renvoie { data: { access_token: "...", refresh_token: "..." } }
                  final data = response.data['data'] ?? response.data;
                  final newAccessToken = data['access_token'];
                  final newRefreshToken = data['refresh_token'];

                  await prefs.setString('token', newAccessToken);
                  await prefs.setString('refresh_token', newRefreshToken);

                  print(
                    'Dio Interceptor: Refresh successful, retrying original request',
                  );

                  // Réessayer la requête originale avec le nouveau token
                  final opts = e.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';
                  return handler.resolve(await dio.fetch(opts));
                }
              }
            } catch (refreshError) {
              print('Dio Interceptor: Refresh failed: $refreshError');
              // On pourrait ici notifier le bloc pour déconnecter l'utilisateur
            }
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
