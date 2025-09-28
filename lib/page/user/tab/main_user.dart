// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/place/place_add.dart';
import 'package:suggest/page/board/board_add.dart';
import 'package:suggest/page/user/list/place_list_user.dart';
import 'package:suggest/page/user/tab/board_user.dart';
import 'package:suggest/page/user/tab/favorite_user.dart';
import 'package:suggest/page/user/tab/profile_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suggest/page/first_page.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

class MainUser extends StatefulWidget {
  String? from;
  UserModel my_account;
  MainUser({Key? key, required this.my_account, required this.from})
      : super(key: key);

  @override
  _MainUser createState() => _MainUser();
}

class _MainUser extends State<MainUser> {
  String? intent_from, from;
  int? selectedIndex;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    setState(() {
      intent_from = widget.from;
      selectedIndex = (intent_from == 'board') ? 2 : 0;
      load_user();
    });
  }

  void load_user() async {
    var token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance
        .collection('suggest_user')
        .doc(widget.my_account.user_id)
        .update({'token': token}).whenComplete(() => print('Update Token'));

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (!androidInfo.isPhysicalDevice) {
        await MySQLApi.updateData('/user/', {
          'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          'email': widget.my_account.email,
          'name': widget.my_account.name,
          'password': widget.my_account.password,
          'photo': widget.my_account.photo,
          'social': widget.my_account.social,
          'tel': widget.my_account.tel,
          'token': token,
          'type': widget.my_account.type,
          'user_id': widget.my_account.user_id,
        });
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

  Future<bool> Logout() async {
    return (await logoutMethod(context)) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      PlaceListUser(my_account: widget.my_account),
      FavoriteUser(my_account: widget.my_account),
      BoardUser(my_account: widget.my_account),
      ProfileUser(),
    ];

    return WillPopScope(
      onWillPop: Logout,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey.shade900,
          unselectedItemColor: Colors.grey.shade400,
          selectedItemColor: Colors.white,
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
              icon: Icon(Icons.favorite),
              label: 'ถูกใจ',
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
        body: ListView(children: [tabs[selectedIndex!]]),
        floatingActionButton: selectedIndex == 0
            ? FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.grey.shade200,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PlaceAdd(my_account: widget.my_account),
                  ),
                ),
                child: const Icon(Icons.add),
              )
            : selectedIndex == 2
                ? FloatingActionButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BoardAdd(my_account: widget.my_account),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  )
                : null,
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
                await FirebaseFirestore.instance
                    .collection('suggest_user')
                    .doc(widget.my_account.user_id)
                    .update({'token': ''}).whenComplete(
                        () => print('Clear Token'));
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => FirstPage()),
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
