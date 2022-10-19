// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:localstore/localstore.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzl;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fast_contacts/fast_contacts.dart';

// Start the Local Database
final _db = Localstore.instance;
getLocalDb() async {
  try {
    final data = await _db.collection('reminders').get();
    return data;
  } catch (e) {
    debugPrint("Erro -> $e");
  }
}

// Create Reminder
createNewReminder(Reminder reminder, image) async {
  dynamic result;
  try {
    final formatedDate =
        "${reminder.date?.substring(6, 10)}${reminder.date?.substring(3, 5)}${reminder.date?.substring(0, 2)}T${reminder.time?.replaceAll(':', '')}";

    final now = DateTime.now().add(const Duration(minutes: 1));

    if (DateTime.parse(formatedDate).compareTo(now) > 0) {
      if (image != null) {
        File tmpFile = File(image);
        final Directory appDirectory = await getApplicationDocumentsDirectory();
        String path = appDirectory.path;
        final fileName = basename(image);
        tmpFile = await tmpFile.copy('$path/$fileName');
        reminder.imagePath = tmpFile.path;
      }
      reminder.id = _db.collection('reminders').doc().id;
      final notId = Random().nextInt(1000000);
      reminder.notId = '$notId';
      await reminder.save();

      await NotificationApi.showScheduleNotification(
          id: notId,
          title: "Lembrete",
          body: "Você tem que ligar para ${reminder.name}",
          payload: '${reminder.cel}',
          scheduledDate: DateTime.parse(formatedDate));

      result = 200;
    } else {
      result = 401;
    }
  } catch (e) {
    debugPrint('Erro -> $e');
    result = 400;
  }
  return result;
}

//get permission contacts
getContactPermission() async {
  var status = await Permission.contacts.status;
  if (status != PermissionStatus.granted) {
    status = await Permission.contacts.request();
  }
  return status;
}

//fetch contact data
getContact() async {
  dynamic response;
  try {
    var permission = await getContactPermission();
    if (permission == PermissionStatus.granted) {
      final contacts = await FastContacts.allContacts;
      response = contacts;
    } else {
      response = 401; // permissao negada
    }
  } catch (e) {
    response = 400;
  }
  return response;
}

// Call cep api
getAddress(cep) async {
  dynamic result;
  try {
    final response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
    if (response.statusCode == 200) {
      result = jsonDecode(response.body);
    } else {
      result = 400;
    }
  } catch (e) {
    result = 400;
  }
  return result;
}

// send local notifications
class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'schedule channel id',
        'Notificações da Agenda',
        channelDescription: 'schedule channel description',
        playSound: true,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    // se o app for fechado
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotifications.add(details.payload);
    }

    await _notifications.initialize(
      settings,
      onSelectNotification: (payload) async {
        onNotifications.add(payload);
      },
    );
    if (initScheduled) {
      tzl.initializeTimeZones();
      final String currentTimeZone =
          await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    }
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(),
        payload: payload,
      );

  static Future showScheduleNotification({
    int id = 0,
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
  static Future<void> cancelNotification(int id) async =>
      await _notifications.cancel(id);
}

// Reminder Model
class Reminder {
  String? id;
  String? notId;
  String? name;
  String? email;
  String? cel;
  String? cep;
  String? city;
  String? state;
  String? street;
  String? streetNumber;
  String? province;
  String? comp;
  String? date;
  String? time;
  String? imagePath;
  bool? isActive;

  Reminder(
      {this.id,
      this.notId,
      this.name,
      this.email,
      this.cel,
      this.cep,
      this.city,
      this.state,
      this.street,
      this.streetNumber,
      this.province,
      this.comp,
      this.date,
      this.time,
      this.imagePath,
      this.isActive});

  Reminder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    notId = json['notId'];
    name = json['name'];
    email = json['email'];
    cel = json['cel'];
    cep = json['cep'];
    city = json['city'];
    state = json['state'];
    street = json['street'];
    streetNumber = json['streetNumber'];
    province = json['province'];
    comp = json['comp'];
    date = json['date'];
    time = json['time'];
    imagePath = json['imagePath'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['notId'] = notId;
    data['name'] = name;
    data['email'] = email;
    data['cel'] = cel;
    data['cep'] = cep;
    data['city'] = city;
    data['state'] = state;
    data['street'] = street;
    data['streetNumber'] = streetNumber;
    data['province'] = province;
    data['comp'] = comp;
    data['date'] = date;
    data['time'] = time;
    data['imagePath'] = imagePath;
    data['isActive'] = isActive;
    return data;
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
        id: map['id'],
        notId: map['notId'],
        name: map['name'],
        email: map['email'],
        cel: map['cel'],
        cep: map['cep'],
        city: map['city'],
        state: map['state'],
        street: map['street'],
        streetNumber: map['streetNumber'],
        province: map['streetNumber'],
        comp: map['comp'],
        date: map['date'],
        time: map['time'],
        imagePath: map['imagePath'],
        isActive: map['isActive']);
  }
}

extension ExtReminder on Reminder {
  Future save() async {
    return _db.collection('reminders').doc(id).set(toMap());
  }

  Future delete() async {
    return _db.collection('reminders').doc(id).delete();
  }
}
