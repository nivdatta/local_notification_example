import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/rxdart.dart';
import 'utils.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';


class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    final largeIconPath = await Utils.downloadFile(
      'https://image.flaticon.com/icons/png/512/1277/1277314.png',
      'largeIcon'
    );

    final bigPicturePath = await Utils.downloadFile(
        'https://images.unsplash.com/photo-1490487135801-031cf13ab462?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=752&q=80',
        'bigPicture'
    );
    final styleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
    );

    return NotificationDetails(
      android: AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      importance: Importance.max, //comment this out to not see banner on top
      // Add playSound false to remove sound when notification is sent.
      // playSound: false,
      // for iOS, set presentSound=false inside IOSNotificationDetails().
      styleInformation: styleInformation,
    ),
    iOS: IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings('app_icon');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    /// when app is closed
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotifications.add(details.payload);
    }
    await _notifications.initialize(settings,
    onSelectNotification: (payload) async {
      onNotifications.add(payload);
    },
    );
  }

  static tz.TZDateTime _scheduleDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, time.hour, time.minute, time.second
    );

    return scheduledDate.isBefore(now) ?
        scheduledDate.add(Duration(days: 1)) : scheduledDate;
  }

  static tz.TZDateTime _scheduleWeekly(Time time, {required List<int> days}) {
    tz.TZDateTime scheduledDate = _scheduleDaily(time);

    while (!days.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  static void cancel(int id) => _notifications.cancel(id);

  static void cancelAll() => _notifications.cancelAll();

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload
}) async =>
      _notifications.show(id, title, body, await _notificationDetails(),
      payload: payload,
      );

  static Future showScheduledNotification({
    int id = 555,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        await _notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

  static Future showDailyScheduledNotification({
    int id = 0221,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        _scheduleDaily(Time(15, 43)),
        //tz.TZDateTime.from(scheduledDate, tz.local),
        await _notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

  static Future showWeeklyScheduledNotification({
    int id = 0221,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        _scheduleWeekly(Time(15, 43), days: [DateTime.monday, DateTime.tuesday, DateTime.wednesday]),
        //tz.TZDateTime.from(scheduledDate, tz.local),
        await _notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
}