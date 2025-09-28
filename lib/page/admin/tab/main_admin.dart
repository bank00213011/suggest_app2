// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suggest/api/authentication_google.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/tab/board_admin.dart';
import 'package:suggest/page/admin/tab/home_admin.dart';
import 'package:suggest/page/admin/tab/profile_admin.dart';
import 'package:suggest/page/first_page.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MainAdmin extends StatefulWidget {
  String? from;
  UserModel my_account;
  MainAdmin({Key? key, required this.my_account, required this.from})
      : super(key: key);

  @override
  _MainAdmin createState() => _MainAdmin();
}

class _MainAdmin extends State<MainAdmin> {
  String? token = '', request_amount = '', intent_from, from;
  int? selectedIndex;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    setState(() {
      intent_from = widget.from;
      selectedIndex = (intent_from == 'edit_user') ? 2 : 0;
      load_user();
    });
  }

  void load_user() async {
    token = await FirebaseMessaging.instance.getToken();
    print(token);

    await FirebaseMessaging.instance
        .subscribeToTopic('librarian')
        .whenComplete(() => print('Subscribe librarian'));

    await FirebaseFirestore.instance
        .collection('suggest_user')
        .doc(widget.my_account.user_id)
        .update({'token': token}).whenComplete(() => print('Update Token'));

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        await MySQLApi.updateData(
            '/user/', {'user_id': widget.my_account.user_id, 'token': token});
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              color: Colors.grey,
              playSound: true,
              groupKey: 'id',
              setAsGroupSummary: true,
              icon: '@drawable/logo',
            ),
          ),
        );
      }
    });
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();
    print(statuses[Permission.camera].toString());
  }

  Future<bool> Logout() async {
    return (await logoutMethod(context)) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeAdmin(my_account: widget.my_account),
      BoardAdmin(my_account: widget.my_account),
      ProfileAdmin(),
    ];

    return WillPopScope(
      onWillPop: Logout,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey[300],
          unselectedItemColor: Colors.grey[600],
          selectedItemColor: Colors.grey[900],
          currentIndex: selectedIndex!,
          onTap: (index) => setState(() {
            selectedIndex = index;
          }),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'หน้าหลัก',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'ข่าวสาร',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts, size: 28),
              label: 'ผู้ใช้',
            ),
          ],
        ),
        body: ListView(
          children: [tabs[selectedIndex!]],
        ),
      ),
    );
  }

  logoutMethod(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการออกจากระบบ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();

                await FirebaseFirestore.instance
                    .collection('suggest_user')
                    .doc(widget.my_account.user_id)
                    .update({'token': ''}).whenComplete(() => print('Clear Token'));

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => FirstPage()),
                  (route) => false,
                );
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }

  appBarMainEmployee(int? selectedIndex) {
    if (selectedIndex == 0) {
      return const Text('หน้าหลัก');
    } else if (selectedIndex == 1) {
      return const Text('บอร์ด');
    } else {
      return const Text('บัญชีผู้ใช้');
    }
  }
}

enum DrawerSections {
  a,
  b,
  c,
  d,
  e,
  f,
  g,
  h,
}