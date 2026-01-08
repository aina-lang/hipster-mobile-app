part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {
  final int userId;
  final bool refresh;

  const NotificationLoadRequested({required this.userId, this.refresh = false});

  @override
  List<Object?> get props => [userId, refresh];
}

class NotificationReceived extends NotificationEvent {
  final Map<String, dynamic> data;

  const NotificationReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class NotificationMarkAsRead extends NotificationEvent {
  final int notificationId;

  const NotificationMarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllAsRead extends NotificationEvent {
  final int userId;

  const NotificationMarkAllAsRead(this.userId);

  @override
  List<Object?> get props => [userId];
}
