import 'package:equatable/equatable.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class TicketLoadRequested extends TicketEvent {
  final bool refresh;
  const TicketLoadRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class TicketCreateRequested extends TicketEvent {
  final String subject;
  final String description;
  final int clientId;
  final String? priority;
  final int? projectId;

  const TicketCreateRequested({
    required this.subject,
    required this.description,
    required this.clientId,
    this.priority,
    this.projectId,
  });

  @override
  List<Object?> get props => [
    subject,
    description,
    clientId,
    priority,
    projectId,
  ];
}

class TicketDetailRequested extends TicketEvent {
  final int ticketId;
  const TicketDetailRequested(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class TicketMessageSent extends TicketEvent {
  final int ticketId;
  final String content;
  const TicketMessageSent({required this.ticketId, required this.content});

  @override
  List<Object?> get props => [ticketId, content];
}
