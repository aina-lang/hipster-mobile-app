import 'package:dio/dio.dart';
import 'package:tiko_tiko/shared/models/maintenance_site_model.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';

class MaintenanceService {
  final Dio _dio = AppConstants.dio;

  /// Récupère les sites en maintenance pour un client
  Future<MaintenanceSitesResponse> getClientMaintenanceSites(
    int clientId,
  ) async {
    try {
      final response = await _dio.get('projects/maintenance/client/$clientId');

      print('DEBUG: Maintenance sites response: ${response.data}');

      return MaintenanceSitesResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('ERROR: Failed to fetch maintenance sites: ${e.message}');
      // Retourner une réponse vide en cas d'erreur
      return MaintenanceSitesResponse(
        sites: [],
        message: "Impossible de charger les sites en maintenance",
      );
    }
  }
}
