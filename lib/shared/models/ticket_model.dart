class TicketModel {
  final int id;
  final String subject;
  final String description;
  final String priority;
  final String status;
  final DateTime createdAt;

  TicketModel({
    required this.id,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      subject: json['subject'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
