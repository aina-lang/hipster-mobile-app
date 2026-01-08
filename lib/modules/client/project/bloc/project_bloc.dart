import 'package:bloc/bloc.dart';
import 'package:tiko_tiko/modules/client/project/services/project_repository.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_event.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository repository;

  ProjectBloc(this.repository) : super(ProjectInitial()) {
    on<ProjectLoadRequested>((event, emit) async {
      if (!event.refresh) {
        emit(ProjectLoading());
      }
      try {
        final projects = await repository.getProjects(
          status: event.status,
          search: event.search,
        );
        emit(ProjectLoaded(projects, status: event.status));
      } catch (e) {
        emit(ProjectFailure("Erreur chargement: $e"));
      }
    });

    on<ProjectSubmitRequested>((event, emit) async {
      emit(ProjectSubmitInProgress());
      try {
        final success = await repository.createProject(
          name: event.name,
          description: event.description,
          startDate: event.startDate,
          endDate: event.endDate,
        );
        if (success) {
          emit(ProjectSubmitSuccess());
          add(ProjectLoadRequested(refresh: true));
        } else {
          emit(ProjectSubmitFailure("Erreur lors de la soumission"));
        }
      } catch (e) {
        emit(ProjectSubmitFailure("Erreur: $e"));
      }
    });
  }
}
