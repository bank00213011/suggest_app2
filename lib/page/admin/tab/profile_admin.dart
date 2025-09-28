import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:suggest/api/authentication_google.dart';
import 'package:suggest/api/firestorage_api.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suggest/page/change_password.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/edit_user.dart';
import 'package:suggest/page/first_page.dart';
import 'package:suggest/utils.dart';
import 'package:path/path.dart' as path;

class ProfileAdmin extends StatefulWidget {
  @override
  _ProfileAdmin createState() => _ProfileAdmin();
}

class _ProfileAdmin extends State<ProfileAdmin> {
  SharedPreferences? prefs;
  bool hidePassword = false;
  String? user_id, email, name, password, tel, type, social, photo_before;
  UserModel? user;
  String imagePath = '';
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      user_id = prefs?.getString('user_id') ?? '';
      email = prefs?.getString('email') ?? '';
      name = prefs?.getString('name') ?? '';
      password = prefs?.getString('password') ?? '';
      tel = prefs?.getString('tel') ?? '';
      type = prefs?.getString('type') ?? '';
      social = prefs?.getString('social') ?? '';
      photo_before = prefs?.getString('photo') ?? '';
    });

    user = UserModel(
      user_id: user_id ?? '',
      email: email ?? '',
      name: name ?? '',
      password: password ?? '',
      social: social ?? '',
      tel: tel ?? '',
      token: '',
      type: type ?? '',
      photo: photo_before ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          const SizedBox(height: 30.0),
          buildPhoto(),
          const SizedBox(height: 30.0),
          buildEmail(),
          const SizedBox(height: 10.0),
          buildUsername(),
          const SizedBox(height: 10.0),
          buildTel(),
          const SizedBox(height: 10.0),
          buildType(),
          const SizedBox(height: 10.0),
          Divider(),
          social == 'email' ? buildButtonChangePassword() : Container(),
          buildButtonEdit(),
          buildButtonExit()
        ],
      ),
    ));
  }

  Widget buildPhoto() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: IconButton(
                icon: Icon(Icons.delete, size: 25.0),
                onPressed: () => print('object'),
              ),
            ),
          ),
          CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xff476cfb),
            child: ClipOval(
              child: SizedBox(
                width: 105,
                height: 105,
                child: (photo_before != null && photo_before!.isNotEmpty)
                    ? Image.network(
                        photo_before!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/placeholder.png',
                                fit: BoxFit.cover),
                      )
                    : Image.asset('assets/user.png', fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 60.0),
            child: IconButton(
              icon: const Icon(Icons.photo_camera, size: 25.0),
              onPressed: () async {
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    imagePath = pickedFile.path;
                  });
                  await uploadPic(File(imagePath));
                }
              },
            ),
          ),
        ],
      );

  Widget buildEmail() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          children: <Widget>[
            Container(
              width: 60,
              child: Text('อีเมล :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(email ?? '',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildUsername() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          children: <Widget>[
            Container(
              width: 60,
              child: Text('ชื่อผู้ใช้ :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(name ?? '',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildTel() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          children: <Widget>[
            Container(
              width: 67,
              child: Text('เบอร์โทร :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(tel ?? '',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildType() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          children: <Widget>[
            Container(
              width: 65,
              child: Text('ประเภท :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                  (type == "admin") ? "แอดมิน" : "ผู้ใช้",
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildButtonChangePassword() => ListTile(
        leading: const Icon(Icons.key),
        title: Text('เปลี่ยนรหัสผ่าน'),
        trailing: const Icon(Icons.navigate_next),
        onTap: () {
          if (user != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChangePassword(my_account: user!),
              ),
            );
          }
        },
      );

  Widget buildButtonEdit() => ListTile(
        leading: const Icon(Icons.person),
        title: Text('แก้ไขข้อมูล'),
        trailing: const Icon(Icons.navigate_next),
        onTap: () => goToEditUser(),
      );

  Widget buildButtonExit() => ListTile(
        leading: const Icon(Icons.exit_to_app),
        title: Text('ออกจากระบบ'),
        trailing: const Icon(Icons.navigate_next),
        onTap: () => logoutMethod(),
      );

  Future uploadPic(File _image) async {
    FocusScope.of(context).unfocus();

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    try {
      String fileName =
          'User_${DateTime.now().millisecondsSinceEpoch}${path.extension(_image.path)}';

      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child('User/$fileName').putFile(_image);

      if (snapshot.state == TaskState.success) {
        final String url = await snapshot.ref.getDownloadURL();

        if (photo_before != null && photo_before!.isNotEmpty) {
          await FireStorageApi.removePhoto(photo_before!);
        }

        prefs?.setString('photo', url);
        await FirebaseFirestore.instance
            .collection('suggest_user')
            .doc(user_id)
            .update({'photo': url});

        if (Platform.isAndroid) {
          final deviceInfo = DeviceInfoPlugin();
          final androidInfo = await deviceInfo.androidInfo;

          final isEmulator = androidInfo.isPhysicalDevice == false;
          if (isEmulator) {
            await MySQLApi.updateData('/user/', {
              'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
              'email': email,
              'name': name,
              'password': password,
              'photo': url,
              'social': social,
              'tel': tel,
              'token': '',
              'type': type,
              'user_id': user_id,
            });
          }
        }

        if (!mounted) return;
        setState(() {
          photo_before = url;
        });
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
        Utils.showToast(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่', Colors.red);
      }
    } catch (e) {
      EasyLoading.dismiss();
      Utils.showToast(context, 'เกิดข้อผิดพลาด: $e', Colors.red);
    }
  }

  void goToEditUser() {
    if (user_id == null) return;

    final user = UserModel(
      user_id: user_id!.trim(),
      email: email?.trim() ?? '',
      name: name?.trim() ?? '',
      password: password?.trim() ?? '',
      tel: tel?.trim() ?? '',
      token: '',
      type: type?.trim() ?? '',
      social: social?.trim() ?? '',
      photo: photo_before ?? '',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditUserPage(my_account: user, from: 'edit'),
      ),
    );
  }

  logoutMethod() async {
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
                Navigator.of(context).pop(); // ปิด dialog ก่อนทำงาน

                // เคลียร์ token ใน firestore
                if (user_id != null && user_id!.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('suggest_user')
                      .doc(user_id)
                      .update({'token': ''}).catchError((e) {
                    print('Error clearing token: $e');
                  });
                }

                // if (Platform.isAndroid) {
                //   final deviceInfo = DeviceInfoPlugin();
                //   final androidInfo = await deviceInfo.androidInfo;
                //   final isEmulator = androidInfo.isPhysicalDevice == false;

                //   if (isEmulator && user_id != null) {
                //     await MySQLApi.updateData(
                //         '/user/', {'user_id': user_id, 'token': ''});
                //   }
                // }

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => FirstPage()),
                    (route) => false);
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}
