import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectLoadRequested extends ProjectEvent {
  final String? status;
  final String? search;
  final bool refresh;

  ProjectLoadRequested({this.status, this.search, this.refresh = false});

  @override
  List<Object?> get props => [status, search, refresh];
}

class ProjectSubmitRequested extends ProjectEvent {
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double? budget;
  final List<String> files;

  ProjectSubmitRequested({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.budget,
    this.files = const [],
  });

  @override
  List<Object?> get props => [
    name,
    description,
    startDate,
    endDate,
    budget,
    files,
  ];
}
