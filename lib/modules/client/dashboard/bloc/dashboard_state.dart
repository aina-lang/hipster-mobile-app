part of 'dashboard_bloc.dart';

class DashboardData extends Equatable {
  final List<ProjectModel> projects;
  final List<TicketModel> tickets;
  final List<InvoiceModel> invoices;
  final LoyaltyModel? loyalty;

  const DashboardData({
    this.projects = const [],
    this.tickets = const [],
    this.invoices = const [],
    this.loyalty,
  });

  DashboardData copyWith({
    List<ProjectModel>? projects,
    List<TicketModel>? tickets,
    List<InvoiceModel>? invoices,
    LoyaltyModel? loyalty,
  }) {
    return DashboardData(
      projects: projects ?? this.projects,
      tickets: tickets ?? this.tickets,
      invoices: invoices ?? this.invoices,
      loyalty: loyalty ?? this.loyalty,
    );
  }

  @override
  List<Object?> get props => [projects, tickets, invoices, loyalty];
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData data;

  const DashboardLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class DashboardFailure extends DashboardState {
  final String message;

  const DashboardFailure(this.message);

  @override
  List<Object> get props => [message];
}
