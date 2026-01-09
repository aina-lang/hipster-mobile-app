import 'package:dio/dio.dart';
import 'package:tiko_tiko/shared/models/invoice_model.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';

class InvoiceRepository {
  final Dio _dio = AppConstants.dio;

  InvoiceRepository();

  Future<List<InvoiceModel>> getInvoices({int? projectId}) async {
    try {
      final response = await _dio.get(
        '/invoices',
        queryParameters: projectId != null ? {'projectId': projectId} : null,
      );
      if (response.statusCode == 200) {
        final List listData =
            response.data['data']?['data'] ?? response.data['data'] ?? [];
        return listData.map((json) => InvoiceModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching invoices: $e');
      rethrow;
    }
  }

  Future<InvoiceModel> getInvoice(int id) async {
    try {
      final response = await _dio.get('/invoices/$id');
      if (response.statusCode == 200) {
        final data = response.data['data']?['data'] ?? response.data['data'];
        if (data == null) throw Exception('Data not found in response');
        return InvoiceModel.fromJson(data);
      }
      throw Exception('Failed to load invoice');
    } catch (e) {
      print('Error fetching invoice details: $e');
      rethrow;
    }
  }

  Future<InvoiceModel> updateStatus(int id, String status) async {
    try {
      final response = await _dio.patch(
        '/invoices/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        final data = response.data['data']?['data'] ?? response.data['data'];
        if (data == null) throw Exception('Data not found in response');
        return InvoiceModel.fromJson(data);
      }
      throw Exception('Failed to update status');
    } catch (e) {
      print('Error updating invoice status: $e');
      rethrow;
    }
  }

  Future<String> getPaymentLink(int id) async {
    try {
      final response = await _dio.post(
        '/payments/create-checkout',
        data: {'invoiceId': id},
      );
      if (response.statusCode == 201) {
        return response.data['url'];
      }
      throw Exception('Failed to get payment link');
    } catch (e) {
      print('Error getting payment link: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(int id) async {
    try {
      final response = await _dio.post(
        '/payments/create-payment-intent',
        data: {'invoiceId': id},
      );
      if (response.statusCode == 201) {
        return response.data['data'];
      }
      throw Exception('Failed to create payment intent');
    } catch (e) {
      print('Error creating payment intent: $e');
      rethrow;
    }
  }
}
