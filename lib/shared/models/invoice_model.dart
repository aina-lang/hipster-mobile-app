class InvoiceModel {
  final int id;
  final String reference;
  final String type; // 'quote' or 'invoice'
  final String status;
  final double amount;
  final double subTotal;
  final double taxRate;
  final double taxAmount;
  final List<InvoiceItemModel> items;
  final DateTime? dueDate;
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.reference,
    required this.type,
    required this.status,
    required this.amount,
    required this.subTotal,
    required this.taxRate,
    required this.taxAmount,
    this.items = const [],
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
      subTotal: double.tryParse(json['subTotal'].toString()) ?? 0.0,
      taxRate: double.tryParse(json['taxRate'].toString()) ?? 0.0,
      taxAmount: double.tryParse(json['taxAmount'].toString()) ?? 0.0,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((i) => InvoiceItemModel.fromJson(i))
                .toList()
          : [],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class InvoiceItemModel {
  final int id;
  final String description;
  final String? unit;
  final double quantity;
  final double unitPrice;
  final double total;

  InvoiceItemModel({
    required this.id,
    required this.description,
    this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'],
      description: json['description'],
      unit: json['unit'],
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      unitPrice: double.tryParse(json['unitPrice'].toString()) ?? 0.0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
    );
  }
}
