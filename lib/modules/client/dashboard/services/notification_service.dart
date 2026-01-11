import 'package:dio/dio.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tiko_tiko/shared/models/notification_model.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final Dio _dio = AppConstants.dio;
  IO.Socket? _socket;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initLocalNotifications();
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    try {
      await _localNotificationsPlugin.initialize(initializationSettings);

      // Request permissions for Android 13+
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      print('NotificationService: Local Notifications Init Error: $e');
    }
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'notification_channel_id',
          'General Notifications',
          channelDescription: 'Notifications from Hipster',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      notificationDetails,
    );
  }

  // --- REST API ---

  Future<List<NotificationModel>> fetchNotifications(int userId) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'userId': userId},
      );
      if (response.statusCode == 200) {
        // Handle paginated response structure: { data: { data: [], meta: ... } }
        final rawData = response.data['data'];
        final List listData = (rawData is Map)
            ? (rawData['data'] ?? [])
            : (rawData ?? []);
        return listData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('NotificationService REST Error: $e');
      return [];
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _dio.patch(
        '/notifications/$notificationId',
        data: {'isRead': true},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('NotificationService REST Error: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead(int userId) async {
    try {
      final response = await _dio.patch(
        '/notifications/mark-all-read',
        data: {'userId': userId},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('NotificationService REST Error: $e');
      return false;
    }
  }

  // --- Socket.IO ---

  void initSocket(
    int userId,
    Function(Map<String, dynamic>) onNotification,
  ) async {
    if (_socket != null && _socket!.connected) return;

    // Check network connectivity before attempting socket connection
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult.contains(ConnectivityResult.none);

    if (isOffline) {
      print(
        'NotificationService: Network offline, skipping Socket.IO connection',
      );
      return;
    }

    print(
      "NotificationService: Connecting Socket to ${AppConstants.baseFileUrl}",
    );

    // Use local variable to avoid null check on field in callback if disposed
    final socket = IO.io(AppConstants.baseFileUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket = socket;

    socket.connect();

    socket.onConnect((_) {
      print('NotificationService: Socket Connected');
      socket.emit('register', {'userId': userId});
    });

    socket.on('notification:new', (data) {
      print('NotificationService: Received Notification: $data');
      if (data != null) {
        onNotification(data);
        if (data['title'] != null && data['message'] != null) {
          _showLocalNotification(data['title'], data['message']);
        }
      }
    });

    socket.on('notifications:allRead', (data) {
      print('NotificationService: All notifications marked as read: $data');
      // Potential callback or internal logic
    });

    _socket!.onDisconnect(
      (_) => print('NotificationService: Socket Disconnected'),
    );
    _socket!.onError(
      (data) => print('NotificationService: Socket Error: $data'),
    );
  }

  void dispose() {
    _socket?.disconnect();
    _socket = null;
  }
}
