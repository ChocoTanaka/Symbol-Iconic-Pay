import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:iconicpay/Const.dart';
import 'package:iconicpay/Symbol.dart';
import 'package:iconicpay/Word.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:math'as math;

Future<void> socket_connect() async {
  const subscribeType = 'confirmedAdded';
  var uid = '';
  final wsUrl = Uri.parse('wss://${MyNode.endpoint}:3001/ws');
  final channel = WebSocketChannel.connect(wsUrl);
  var topic = '$subscribeType/${MyAc!.Address}';
  await channel.ready;
  channel.stream.listen((e) {
    Map<String, dynamic> data = jsonDecode(e);
    if (data['uid'] != null) {
      uid = data['uid'];
      print('uid: $uid');
      Map<String, dynamic> message = {
        'uid': uid,
        'subscribe': topic,
      };
      channel.sink.add(jsonEncode(message));
      return;
    }
    if (data['topic'] == topic) {
      //print(data['data']);
      showNotification(data['data']);
    }
  });
}

String countXYM(Map<String, dynamic> Jdata){
  for(var mosaic in Jdata['transaction']['transactions'][0]['transaction']['mosaics']!){
    if(mosaic['id'] == XYMID){
      return '${(double.parse(mosaic['amount'])* math.pow(10, -6)).toStringAsFixed(2)} XYM';
    }
  }
  return "Another Mosaic";
}

Future<void> showNotification(Map<String, dynamic> Jdata) async {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.
  resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high', // 同じIDを使用
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    "Tx Confirmed.",
    countXYM(Jdata),
    NotificationDetails(
      android: AndroidNotificationDetails(channel.id, channel.name,
          channelDescription: channel.description),
    ),
  );
}
