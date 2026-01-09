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
  final String? notes;
  final String? terms;
  final String? pdfUrl;
  final SenderDetailsModel? senderDetails;
  final ClientSnapshotModel? clientSnapshot;
  final ProjectSnapshotModel? projectSnapshot;

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
    this.notes,
    this.terms,
    this.pdfUrl,
    this.senderDetails,
    this.clientSnapshot,
    this.projectSnapshot,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'],
      reference: json['reference']?.toString() ?? 'N/A',
      type: json['type']?.toString() ?? 'invoice',
      status: json['status']?.toString() ?? 'pending',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      subTotal: double.tryParse(json['subTotal']?.toString() ?? '0') ?? 0.0,
      taxRate: double.tryParse(json['taxRate']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['taxAmount']?.toString() ?? '0') ?? 0.0,
      pdfUrl: json['pdfUrl']?.toString(),
      items: (json['items'] is List)
          ? (json['items'] as List)
                .map(
                  (i) => InvoiceItemModel.fromJson(i as Map<String, dynamic>),
                )
                .toList()
          : [],
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      createdAt:
          DateTime.tryParse(
            json['issueDate']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      notes: json['notes']?.toString(),
      terms: json['terms']?.toString(),
      senderDetails: (json['senderDetails'] is Map<String, dynamic>)
          ? SenderDetailsModel.fromJson(json['senderDetails'])
          : null,
      clientSnapshot: (json['clientSnapshot'] is Map<String, dynamic>)
          ? ClientSnapshotModel.fromJson(json['clientSnapshot'])
          : null,
      projectSnapshot: (json['projectSnapshot'] is Map<String, dynamic>)
          ? ProjectSnapshotModel.fromJson(json['projectSnapshot'])
          : null,
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
      description: json['description'] ?? 'Sans description',
      unit: json['unit'],
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class SenderDetailsModel {
  final String? companyName;
  final String? commercialName;
  final String? email;
  final String? phone;
  final String? address;
  final String? siret;
  final String? tvaNumber;
  final PaymentDetailsModel? paymentDetails;

  SenderDetailsModel({
    this.companyName,
    this.commercialName,
    this.email,
    this.phone,
    this.address,
    this.siret,
    this.tvaNumber,
    this.paymentDetails,
  });

  factory SenderDetailsModel.fromJson(Map<String, dynamic> json) {
    return SenderDetailsModel(
      companyName: json['companyName']?.toString(),
      commercialName: json['commercialName']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      siret: json['siret']?.toString(),
      tvaNumber: json['tvaNumber']?.toString(),
      paymentDetails: (json['paymentDetails'] is Map<String, dynamic>)
          ? PaymentDetailsModel.fromJson(json['paymentDetails'])
          : null,
    );
  }
}

class ClientSnapshotModel {
  final int? id;
  final String? name;
  final String? email;
  final String? company;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? country;
  final String? siret;
  final String? tvaNumber;

  ClientSnapshotModel({
    this.id,
    this.name,
    this.email,
    this.company,
    this.address,
    this.city,
    this.zipCode,
    this.country,
    this.siret,
    this.tvaNumber,
  });

  factory ClientSnapshotModel.fromJson(Map<String, dynamic> json) {
    return ClientSnapshotModel(
      id: json['id'],
      name: json['name']?.toString(),
      company: json['company']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      zipCode: json['zipCode']?.toString(),
      country: json['country']?.toString(),
      siret: json['siret']?.toString(),
      tvaNumber: json['tvaNumber']?.toString(),
    );
  }
}

class ProjectSnapshotModel {
  final int? id;
  final String? name;
  final String? description;

  ProjectSnapshotModel({this.id, this.name, this.description});

  factory ProjectSnapshotModel.fromJson(Map<String, dynamic> json) {
    return ProjectSnapshotModel(
      id: json['id'],
      name: json['name']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class PaymentDetailsModel {
  final String? bank;
  final String? iban;
  final String? bic;
  final String? mode;

  PaymentDetailsModel({this.bank, this.iban, this.bic, this.mode});

  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsModel(
      bank: json['bank']?.toString() ?? json['bankName']?.toString(),
      iban: json['iban']?.toString(),
      bic: json['bic']?.toString(),
      mode: json['mode']?.toString(),
    );
  }
}
