class InvoiceModel {
  final int id;
  final String reference;
  final String type; // 'quote' or 'invoice'
  final String status;
  final double amount;
  final DateTime? dueDate;
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.reference,
    required this.type,
    required this.status,
    required this.amount,
    this.dueDate,
    required this.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      reference: json['reference'],
      type: json['type'],
      status: json['status'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
