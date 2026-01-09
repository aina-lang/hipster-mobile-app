import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiko_tiko/shared/models/message_model.dart';
import '../services/ticket_repository.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketRepository _repository;

  TicketBloc(this._repository) : super(TicketInitial()) {
    on<TicketLoadRequested>(_onLoadRequested);
    on<TicketCreateRequested>(_onCreateRequested);
    on<TicketDetailRequested>(_onDetailRequested);
    on<TicketMessageSent>(_onMessageSent);
  }

  Future<void> _onDetailRequested(
    TicketDetailRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final tickets = await _repository.getTickets();
      final ticket = tickets.firstWhere((t) => t.id == event.ticketId);
      final rawMessages = await _repository.getTicketMessages(event.ticketId);
      final messages = rawMessages
          .map((m) => MessageModel.fromJson(m))
          .toList();
      emit(TicketDetailLoaded(ticket: ticket, messages: messages));
    } catch (e) {
      emit(TicketFailure(e.toString()));
    }
  }

  Future<void> _onMessageSent(
    TicketMessageSent event,
    Emitter<TicketState> emit,
  ) async {
    // Note: We don't emit loading here to avoid flickering local UI if we want optimistic updates
    // but for now let's keep it simple
    try {
      final success = await _repository.sendTicketMessage(
        event.ticketId,
        event.content,
      );
      if (success) {
        emit(TicketMessageSendSuccess());
        // Refresh detail
        add(TicketDetailRequested(event.ticketId));
      } else {
        emit(const TicketFailure("Erreur lors de l'envoi du message"));
      }
    } catch (e) {
      emit(TicketFailure(e.toString()));
    }
  }

  Future<void> _onLoadRequested(
    TicketLoadRequested event,
    Emitter<TicketState> emit,
  ) async {
    if (!event.refresh) emit(TicketLoading());
    try {
      final tickets = await _repository.getTickets();
      emit(TicketLoaded(tickets));
    } catch (e) {
      emit(TicketFailure(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    TicketCreateRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionLoading());
    try {
      final ticket = await _repository.createTicket(
        subject: event.subject,
        description: event.description,
        clientId: event.clientId,
        priority: event.priority,
        projectId: event.projectId,
      );

      if (ticket != null) {
        emit(TicketCreateSuccess(ticket));
        // Reload list automatically
        add(const TicketLoadRequested(refresh: true));
      } else {
        emit(const TicketFailure("Erreur lors de la création du ticket"));
      }
    } catch (e) {
      emit(TicketFailure(e.toString()));
    }
  }
}
