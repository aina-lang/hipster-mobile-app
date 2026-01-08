import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tiko_tiko/modules/client/devis_facture/services/invoice_repository.dart';
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

class InvoiceStatusUpdateRequested extends InvoiceEvent {
  final int id;
  final String status;
  InvoiceStatusUpdateRequested({required this.id, required this.status});
  @override
  List<Object?> get props => [id, status];
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

class InvoiceStatusUpdateSuccess extends InvoiceState {
  final InvoiceModel updatedInvoice;
  InvoiceStatusUpdateSuccess(this.updatedInvoice);
  @override
  List<Object?> get props => [updatedInvoice];
}

class InvoiceFailure extends InvoiceState {
  final String error;
  InvoiceFailure(this.error);
  @override
  List<Object?> get props => [error];
}

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository repository;

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

    on<InvoiceStatusUpdateRequested>((event, emit) async {
      emit(InvoiceLoading());
      try {
        final updated = await repository.updateStatus(event.id, event.status);
        emit(InvoiceStatusUpdateSuccess(updated));
        // Optionally reload the list
        add(InvoiceLoadRequested(refresh: true));
      } catch (e) {
        emit(InvoiceFailure(e.toString()));
      }
    });
  }
}
