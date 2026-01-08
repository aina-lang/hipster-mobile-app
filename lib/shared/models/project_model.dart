class ProjectModel {
  final int id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final double progress;
  final double budget;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.progress,
    required this.budget,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      status: json['status'],
      progress: (json['progress'] ?? 0).toDouble(),
      budget: double.tryParse(json['budget'].toString()) ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
