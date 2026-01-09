import 'package:dio/dio.dart';
import 'package:tiko_tiko/modules/client/loyality/models/loyalty_model.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';

class LoyaltyRepository {
  final Dio _dio = AppConstants.dio;

  LoyaltyRepository();

  Future<LoyaltyDetailModel> getLoyaltyMine() async {
    try {
      final response = await _dio.get('/loyalty/mine');
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle the wrapper data: { "status": "success", "data": { ... } }
        final data = response.data['data'] ?? response.data;
        return LoyaltyDetailModel.fromJson(data);
      }
      throw Exception('Failed to load loyalty details');
    } catch (e) {
      print('Error fetching loyalty details: $e');
      rethrow;
    }
  }
}
