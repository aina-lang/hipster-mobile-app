import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tiko_tiko/modules/client/dashboard/services/notification_service.dart';
import 'package:tiko_tiko/shared/models/notification_model.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService = NotificationService();

  NotificationBloc() : super(NotificationInitial()) {
    on<NotificationLoadRequested>((event, emit) async {
      if (!event.refresh) {
        emit(NotificationLoading());
      }

      // Initialize Socket
      _notificationService.initSocket(event.userId, (data) {
        add(NotificationReceived(data));
      });

      try {
        final notifications = await _notificationService.fetchNotifications(
          event.userId,
        );
        emit(NotificationLoaded(notifications));
      } catch (e) {
        emit(
          NotificationFailure(
            "Erreur lors du chargement des notifications: $e",
          ),
        );
      }
    });

    on<NotificationReceived>((event, emit) {
      if (state is NotificationLoaded) {
        final currentNotifications =
            (state as NotificationLoaded).notifications;
        try {
          final newNotification = NotificationModel.fromJson(event.data);
          // Add to beginning of list
          final updatedNotifications = [
            newNotification,
            ...currentNotifications,
          ];
          emit(NotificationLoaded(updatedNotifications));
        } catch (e) {
          print("Error parsing socket notification: $e");
        }
      }
    });

    on<NotificationMarkAsRead>((event, emit) async {
      if (state is NotificationLoaded) {
        final currentNotifications =
            (state as NotificationLoaded).notifications;

        // Optimistic UI Update
        final updatedNotifications = currentNotifications.map((n) {
          return n.id == event.notificationId
              ? NotificationModel(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  message: n.message,
                  data: n.data,
                  isRead: true,
                  createdAt: n.createdAt,
                )
              : n;
        }).toList();

        emit(NotificationLoaded(updatedNotifications));

        // API Call
        await _notificationService.markAsRead(event.notificationId);
      }
    });

    on<NotificationMarkAllAsRead>((event, emit) async {
      if (state is NotificationLoaded) {
        final currentNotifications =
            (state as NotificationLoaded).notifications;

        // Optimistic UI Update
        final updatedNotifications = currentNotifications.map((n) {
          return NotificationModel(
            id: n.id,
            type: n.type,
            title: n.title,
            message: n.message,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();

        emit(NotificationLoaded(updatedNotifications));

        // API Call
        await _notificationService.markAllAsRead(event.userId);
      }
    });
  }

  @override
  Future<void> close() {
    _notificationService.dispose();
    return super.close();
  }
}
