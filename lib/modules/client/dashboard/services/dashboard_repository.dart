import 'package:dio/dio.dart';
import '../../../../shared/models/project_model.dart';
import '../../../../shared/models/ticket_model.dart';
import '../../../../shared/models/invoice_model.dart';
import '../../../../shared/models/loyalty_model.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';

class DashboardRepository {
  // Use shared Dio instance which handles tokens
  final Dio _dio = AppConstants.dio;

  DashboardRepository();

  Future<List<ProjectModel>> getProjects() async {
    print('DEBUG: Fetching /projects');
    try {
      final response = await _dio.get('/projects');
      print('DEBUG: /projects status: ${response.statusCode}');
      print('DEBUG: /projects raw response: ${response.data}');

      if (response.statusCode == 200) {
        final rawData = response.data['data'];
        final List listData = (rawData is Map)
            ? (rawData['data'] ?? [])
            : (rawData ?? []);

        final projects = listData
            .map((json) => ProjectModel.fromJson(json))
            .toList();
        print('DEBUG: Parsed ${projects.length} projects');
        return projects;
      }
      return [];
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  Future<List<TicketModel>> getTickets() async {
    try {
      final response = await _dio.get('/tickets');
      if (response.statusCode == 200) {
        final rawData = response.data['data'];
        final List listData = (rawData is Map)
            ? (rawData['data'] ?? [])
            : (rawData ?? []);
        return listData.map((json) => TicketModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }

  Future<List<InvoiceModel>> getInvoices() async {
    try {
      final response = await _dio.get('/invoices');
      if (response.statusCode == 200) {
        final rawData = response.data['data'];
        final List listData = (rawData is Map)
            ? (rawData['data'] ?? [])
            : (rawData ?? []);
        return listData.map((json) => InvoiceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching invoices: $e');
      return [];
    }
  }

  Future<LoyaltyModel?> getLoyaltyStatus(int clientId) async {
    print('DEBUG: Fetching /loyalty/$clientId');
    try {
      final response = await _dio.get('/loyalty/$clientId');
      print('DEBUG: /loyalty/$clientId status: ${response.statusCode}');
      print('DEBUG: /loyalty/$clientId raw response: ${response.data}');

      if (response.statusCode == 200) {
        final loyalty = LoyaltyModel.fromJson(response.data);
        print('DEBUG: Parsed loyalty: projectCount=${loyalty.projectCount}');
        return loyalty;
      }
      return null;
    } catch (e) {
      print('Error fetching loyalty: $e');
      return null;
    }
  }
}
