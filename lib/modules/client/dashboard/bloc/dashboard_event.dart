part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  final int clientId;
  final int userId;
  final bool refresh;

  const DashboardLoadRequested({
    required this.clientId,
    required this.userId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [clientId, userId, refresh];
}
