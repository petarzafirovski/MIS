import 'package:awesome_notifications/awesome_notifications.dart';

class CustomNotificationHandler {
  // Entry point for handling notification creation
  static Future<void> handleNotificationCreated(
      ReceivedNotification notification) async {
  }

  // Entry point for when a notification is displayed to the user
  static Future<void> handleNotificationDisplayed(
      ReceivedNotification notification) async {
  }

  // Entry point for handling notification dismissal
  static Future<void> handleNotificationDismissed(
      ReceivedNotification notification) async {
  }

  // Entry point for handling user action on a notification
  static Future<void> handleUserAction(
      ReceivedNotification notification) async {
  }
}
