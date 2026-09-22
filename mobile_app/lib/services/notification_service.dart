import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: settings,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'school_notifications',
            'School Notifications',
            description: 'School app notifications',
            importance: Importance.max,
          ),
        );

    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      show(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    });
  }

  // Show a local notification
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'school_notifications',
      'School Notifications',
      channelDescription: 'School app notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  // Get current FCM token
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // Save FCM token to your ASP.NET API
  static Future<void> saveFCMToken({
    required int userId,
    required String role,
    required String jwtToken,
    required String fcmToken,
  }) async {
    final response = await http.post(
      Uri.parse(
        'http://localhost:7205/api/MobileAccount/save-fcm-token',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({
        'userId': userId,
        'token': fcmToken,
        'role': role,
      }),
    );

    print("FCM save status: ${response.statusCode}");
    print("FCM save response: ${response.body}");
  }

  // Get current token AND listen for future token changes
  static Future<void> setupTokenRefresh({
    required int userId,
    required String role,
    required String jwtToken,
  }) async {
    // Get the token currently assigned to this device
    final token = await getToken();

    if (token != null) {
      await saveFCMToken(
        userId: userId,
        role: role,
        jwtToken: jwtToken,
        fcmToken: token,
      );
    }

    // Listen for Firebase changing the token
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) async {
        print("🔥 FCM TOKEN CHANGED: $newToken");

        await saveFCMToken(
          userId: userId,
          role: role,
          jwtToken: jwtToken,
          fcmToken: newToken,
        );
      },
    );
  }
}