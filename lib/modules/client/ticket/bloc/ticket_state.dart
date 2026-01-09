import 'package:equatable/equatable.dart';
import '../../../../shared/models/ticket_model.dart';
import '../../../../shared/models/message_model.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketLoaded extends TicketState {
  final List<TicketModel> tickets;
  const TicketLoaded(this.tickets);

  @override
  List<Object?> get props => [tickets];
}

class TicketDetailLoaded extends TicketState {
  final TicketModel ticket;
  final List<MessageModel> messages;
  const TicketDetailLoaded({required this.ticket, required this.messages});

  @override
  List<Object?> get props => [ticket, messages];
}

class TicketFailure extends TicketState {
  final String error;
  const TicketFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class TicketCreateSuccess extends TicketState {
  final TicketModel ticket;
  const TicketCreateSuccess(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class TicketMessageSendSuccess extends TicketState {}

class TicketActionLoading extends TicketState {}
