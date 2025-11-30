import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

class NotificationService {
  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger('NotificationService');

  NotificationService() {
    // Don't initialize FirebaseMessaging here - wait for initialize() method
  }

  Future<void> initialize() async {
    // Initialize logging
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // You can customize how logs are handled here
      // For example, send to a logging service or print only in debug mode
    });

    // Initialize local notifications first (always available)
    try {
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings settings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(settings);
      _logger.info('Local notifications initialized');
    } catch (e) {
      _logger.warning('Local notifications initialization failed: $e');
    }

    // Initialize Firebase messaging if available
    try {
      _firebaseMessaging = FirebaseMessaging.instance;
      
      // Request permission for notifications
      await _firebaseMessaging!.requestPermission();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
      });

      // Get FCM token
      String? token = await _firebaseMessaging!.getToken();
      _logger.info('FCM Token: $token');
    } catch (e) {
      _logger.warning('Firebase messaging initialization failed: $e');
      _firebaseMessaging = null;
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'topocoin_channel',
      'Topocoin Notifications',
      channelDescription: 'Notifications for Topocoin wallet',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title ?? 'Topocoin',
      message.notification?.body ?? 'New notification',
      details,
    );
  }

  Future<void> sendNotification(String title, String body, String token) async {
    try {
      // This would typically be done from your backend
      // For demo, we'll simulate sending via a service
      _logger.info('Sending notification: $title - $body to $token');
      
      // Show local notification as fallback/demo
      await _showLocalNotification(RemoteMessage(
        notification: RemoteNotification(
          title: title,
          body: body,
        ),
      ));
    } catch (e) {
      _logger.warning('Failed to send notification: $e');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    Logger('NotificationService').info('Handling background message: ${message.messageId}');
  } catch (e) {
    // Handle Firebase not available
    Logger('NotificationService').warning('Background message handler error: $e');
  }
}