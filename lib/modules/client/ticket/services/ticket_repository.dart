import 'package:dio/dio.dart';
import '../../../../shared/models/ticket_model.dart';
import '../../../../shared/utils/constants.dart';

class TicketRepository {
  final Dio _dio = AppConstants.dio;

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

  Future<TicketModel?> createTicket({
    required String subject,
    required String description,
    required int clientId,
    String? priority,
    int? projectId,
  }) async {
    try {
      final response = await _dio.post(
        '/tickets',
        data: {
          'subject': subject,
          'description': description,
          'clientId': clientId,
          if (priority != null) 'priority': priority,
          if (projectId != null) 'projectId': projectId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return TicketModel.fromJson(response.data['data'] ?? response.data);
      }
      return null;
    } catch (e) {
      print('Error creating ticket: $e');
      return null;
    }
  }

  Future<bool> deleteTicket(int id) async {
    try {
      final response = await _dio.delete('/tickets/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting ticket: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getTicketMessages(int ticketId) async {
    try {
      final response = await _dio.get('/tickets/$ticketId/messages');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('Error fetching ticket messages: $e');
      return [];
    }
  }

  Future<bool> sendTicketMessage(int ticketId, String content) async {
    try {
      final response = await _dio.post(
        '/tickets/$ticketId/messages',
        data: {'content': content},
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error sending ticket message: $e');
      return false;
    }
  }
}
