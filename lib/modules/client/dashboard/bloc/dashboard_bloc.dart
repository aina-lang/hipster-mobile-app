import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/models/project_model.dart';
import '../../../../shared/models/ticket_model.dart';
import '../../../../shared/models/invoice_model.dart';
import '../../../../shared/models/loyalty_model.dart';
import '../services/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(DashboardInitial()) {
    on<DashboardLoadRequested>((event, emit) async {
      if (!event.refresh) {
        emit(DashboardLoading());
      }

      try {
        // Fetch data in parallel (without notifications)
        final results = await Future.wait([
          repository.getProjects(),
          repository.getTickets(),
          repository.getInvoices(),
          repository.getLoyaltyStatus(event.clientId),
        ]);

        final projects = results[0] as List<ProjectModel>;
        final tickets = results[1] as List<TicketModel>;
        final invoices = results[2] as List<InvoiceModel>;
        final loyalty = results[3] as LoyaltyModel?;

        emit(
          DashboardLoaded(
            DashboardData(
              projects: projects,
              tickets: tickets,
              invoices: invoices,
              loyalty: loyalty,
            ),
          ),
        );
      } catch (e) {
        emit(DashboardFailure("Erreur lors du chargement: $e"));
      }
    });
  }
}
