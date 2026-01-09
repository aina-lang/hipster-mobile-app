class MessageModel {
  final int id;
  final String content;
  final String senderType;
  final DateTime createdAt;
  final int userId;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderType,
    required this.createdAt,
    required this.userId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      senderType: json['senderType'],
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['user']?['id'] ?? 0,
    );
  }
}
