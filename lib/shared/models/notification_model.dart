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
    return NotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // --- Helpers ---

  int? get projectId => data?['projectId'];
  int? get invoiceId => data?['invoiceId'];
  int? get ticketId => data?['ticketId'];

  String get category {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('devis') || title.toLowerCase().contains('devis'))
      return 'devis';
    if (t.contains('facture') || title.toLowerCase().contains('facture'))
      return 'facture';
    if (t.contains('ticket') || title.toLowerCase().contains('ticket'))
      return 'ticket';
    if (t.contains('projet') || t.contains('project')) return 'projet';
    return 'general';
  }
}
