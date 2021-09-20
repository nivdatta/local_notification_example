import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_api.dart';
import 'second_page.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';


Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();

  await NotificationApi.init();
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => new _State();
}

class _State extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationApi.init().whenComplete((){
      setState(() {});
    });
    listenNotifications();
  }

  void listenNotifications() =>
      NotificationApi.onNotifications.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondPage(payload: payload),
      ));
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Name here"),
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column(
            children: [
              new Text("Hello World"),
              new ElevatedButton(
                  onPressed: () => NotificationApi.showNotification(
                    title: "Reminder: Go to sleep",
                    body: "THis is time to sleep now!",
                    payload: "nivedita datta",
                  ),
                  child: Text("Simple Notification")),
              new ElevatedButton(
                  child: Text("Scheduled Notification"),
                  onPressed: () {
                    NotificationApi.showScheduledNotification(
                      title: "Reminder: Dinner in 30 sec",
                      body: "Go to dinner in 30 sec!",
                      payload: "nivedita datta",
                      scheduledDate: DateTime.now().add(Duration(seconds: 30)),
                    );
                    final snackBar = SnackBar(
                        content: Text("scheduled in 30 sec", style: TextStyle(fontSize: 24),),
                      backgroundColor: Colors.grey,
                    );
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(snackBar);
                }
              ),

              new ElevatedButton(
                  child: Text("Daily Notification"),
                  onPressed: () {
                    NotificationApi.showDailyScheduledNotification(
                      title: "Reminder: Dinner in 30 sec",
                      body: "Go to dinner in 30 sec!",
                      payload: "nivedita datta",
                      scheduledDate: DateTime.now().add(Duration(seconds: 30)),
                    );
                    final snackBar = SnackBar(
                      content: Text("scheduled in 30 sec", style: TextStyle(fontSize: 24),),
                      backgroundColor: Colors.grey,
                    );
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(snackBar);
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}