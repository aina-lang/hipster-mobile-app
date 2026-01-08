import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tiko_tiko/modules/client/dashboard/services/dashboard_repository.dart';
import 'package:tiko_tiko/shared/models/invoice_model.dart';

// Events
abstract class InvoiceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InvoiceLoadRequested extends InvoiceEvent {
  final bool refresh;
  InvoiceLoadRequested({this.refresh = false});
}

// States
abstract class InvoiceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<InvoiceModel> invoices;
  InvoiceLoaded(this.invoices);
  @override
  List<Object?> get props => [invoices];
}

class InvoiceFailure extends InvoiceState {
  final String error;
  InvoiceFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final DashboardRepository repository;

  InvoiceBloc(this.repository) : super(InvoiceInitial()) {
    on<InvoiceLoadRequested>((event, emit) async {
      if (!event.refresh) emit(InvoiceLoading());
      try {
        final invoices = await repository.getInvoices();
        emit(InvoiceLoaded(invoices));
      } catch (e) {
        emit(InvoiceFailure(e.toString()));
      }
    });
  }
}
