import 'dart:convert';

class NotificationModel {
  final int id;
  final String? type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dataMap;
    if (json['data'] is Map<String, dynamic>) {
      dataMap = json['data'];
    } else if (json['data'] is String) {
      try {
        dataMap = jsonDecode(json['data'] as String) as Map<String, dynamic>;
      } catch (_) {}
    }

    return NotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: dataMap,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // --- Helpers ---
  int? get projectId => _getIntFromData(['projectId', 'project_id', 'project']);
  int? get invoiceId =>
      _getIntFromData(['invoiceId', 'invoice_id', 'quoteId', 'quote_id', 'id']);
  int? get ticketId => _getIntFromData(['ticketId', 'ticket_id', 'ticket']);

  int? _getIntFromData(List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final val = data![key];
      if (val != null) {
        return int.tryParse(val.toString());
      }
    }
    return null;
  }

  String get category {
    final t = type?.toLowerCase() ?? '';
    final tit = title.toLowerCase();
    if (t.contains('devis') ||
        t.contains('quote') ||
        tit.contains('devis') ||
        tit.contains('quote')) {
      return 'devis';
    }
    if (t.contains('facture') ||
        t.contains('invoice') ||
        tit.contains('facture') ||
        tit.contains('invoice')) {
      return 'facture';
    }
    if (t.contains('ticket') || tit.contains('ticket')) {
      return 'ticket';
    }
    if (t.contains('projet') ||
        t.contains('project') ||
        tit.contains('projet') ||
        tit.contains('project')) {
      return 'projet';
    }
    return 'general';
  }
}
