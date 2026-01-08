import 'package:equatable/equatable.dart';
import 'package:tiko_tiko/shared/models/project_model.dart';

abstract class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<ProjectModel> projects;
  final String? status;

  ProjectLoaded(this.projects, {this.status});

  @override
  List<Object?> get props => [projects, status];
}

class ProjectFailure extends ProjectState {
  final String error;
  ProjectFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ProjectSubmitInProgress extends ProjectState {}

class ProjectSubmitSuccess extends ProjectState {}

class ProjectSubmitFailure extends ProjectState {
  final String error;
  ProjectSubmitFailure(this.error);

  @override
  List<Object?> get props => [error];
}
