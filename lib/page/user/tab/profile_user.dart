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
import 'package:suggest/page/full_image.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/edit_user.dart';
import 'package:suggest/page/first_page.dart';
import 'package:suggest/utils.dart';
import 'package:path/path.dart' as path;

class ProfileUser extends StatefulWidget {
  @override
  _ProfileUser createState() => _ProfileUser();
}

class _ProfileUser extends State<ProfileUser> {
  //  ประกาศตัวแปร
  SharedPreferences? prefs;
  bool hidePassword = false;
  UserModel? user;

  String? user_id = '',
      email = '',
      name = '',
      password = '',
      tel = '',
      type = '',
      token = '',
      social = '',
      photo_before = '';

  String imagePath = '';
  final picker = ImagePicker();

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    load();
  }

  // โหลดข้อมูล SharedPreferences
  Future load() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs?.getString('user_id');
      email = prefs?.getString('email');
      name = prefs?.getString('name');
      password = prefs?.getString('password');
      tel = prefs?.getString('tel');
      type = prefs?.getString('type');
      social = prefs?.getString('social');
      photo_before = prefs?.getString('photo');
    });
    user = UserModel(
        user_id: user_id!,
        email: email!,
        name: name!,
        password: password!,
        social: tel!,
        tel: tel!,
        token: '',
        type: type!,
        photo: photo_before!);
  }

  @override // หน้า UI
  Widget build(BuildContext context) {
    return ListView(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        const SizedBox(
          height: 30.0,
        ),
        buildPhoto(),
        const SizedBox(height: 30.0),
        buildEmail(),
        const SizedBox(
          height: 10.0,
        ),
        buildUsername(),
        const SizedBox(
          height: 10.0,
        ),
        buildTel(),
        const SizedBox(
          height: 10.0,
        ),
        buildType(),
        const SizedBox(
          height: 10.0,
        ),
        Divider(),
        social == 'email' ? buildButtonChangePassword() : Container(),
        buildButtonEdit(),
        buildButtonExit()
      ],
    );
  }

  Widget buildPhoto() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 25.0,
                  ),
                  onPressed: () => print('object')),
            ),
          ),
          GestureDetector(
            onTap: () => photo_before != ''
                ? Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullImage(photo: photo_before!),
                    ),
                  )
                : print('test'),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xff476cfb),
              child: ClipOval(
                child: SizedBox(
                    width: 105,
                    height: 105,
                    child: photo_before != ''
                        ? Image.network(
                            photo_before!, // this image doesn't exist
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/placeholder.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/user.png',
                            fit: BoxFit.cover,
                          )),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 60.0),
            child: IconButton(
              icon: Icon(
                Icons.photo_camera,
                size: 25.0,
              ),
              onPressed: () async {
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  // CroppedFile? croppedFile = await ImageCropper()
                  //     .cropImage(sourcePath: pickedFile.path, uiSettings: [
                  //   AndroidUiSettings(
                  //     toolbarTitle: 'การตัดรูป',
                  //     toolbarColor: Colors.green[700],
                  //     toolbarWidgetColor: Colors.white,
                  //     activeControlsWidgetColor: Colors.green[700],
                  //     initAspectRatio: CropAspectRatioPreset.original,
                  //     lockAspectRatio: false,
                  //   ),
                  //   IOSUiSettings(
                  //     minimumAspectRatio: 1.0,
                  //   ),
                  // ]);
                  // if (croppedFile != null) {
                  setState(() {
                    imagePath = pickedFile.path;
                    uploadPic(imagePath);
                    print(imagePath);
                  });
                }
                //}
              },
            ),
          ),
        ],
      );

  Widget buildEmail() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 60,
              child: Text('อีเมลล์ :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('$email',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildUsername() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 60,
              child: Text('ชื่อผู้ใช้ :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('$name',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildPassword() => Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 65,
                  child: const Text('รหัสผ่าน :',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: hidePassword
                      ? Text('$password',
                          style: TextStyle(color: Colors.black, fontSize: 16.0))
                      : Text(Utils.returnPassword(password!.length),
                          style:
                              TextStyle(color: Colors.black, fontSize: 16.0)),
                ),
              ],
            ),
          ),
          Positioned(
              right: 30,
              child: GestureDetector(
                  child: Icon(
                    hidePassword == false
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onTap: () => setState(() {
                        hidePassword = !hidePassword;
                      })))
        ],
      );

  Widget buildTel() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 67,
              child: Text('เบอร์โทร :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text('$tel',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildType() => Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 65,
              child: Text('ประเภท :',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(type == 'user' ? 'ผู้ใช้ทั่วไป' : 'แอดมิน',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
            ),
          ],
        ),
      );

  Widget buildButtonChangePassword() => ListTile(
      leading: const Icon(Icons.key),
      title: Text('เปลี่ยนรหัสผ่าน'),
      trailing: const Icon(Icons.navigate_next),
      onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangePassword(my_account: user!),
            ),
          ));

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
        onTap: () => logoutMethod(context),
      );

  // อัปโหลดรูปภาพ
  Future uploadPic(String filePath) async {
    FocusScope.of(context).unfocus();

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    if (filePath == "") {
      // ถ้าไม่มีรูปให้แสดง SnackBar
      Utils.showToast(context, 'กรุณาเลือกรูปก่อน', Colors.red);
      EasyLoading.dismiss();
      return;
    } else {
      String fileName =
          'User_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';

      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child('User/$fileName').putFile(File(filePath));
      if (snapshot.state == TaskState.success) {
        String url = await snapshot.ref.getDownloadURL();

        if (photo_before != '') {
          await FireStorageApi.removePhoto(photo_before!);
        }

        EasyLoading.dismiss();
        prefs?.setString('photo', url);
        FirebaseFirestore.instance
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

        // await FirebaseAuth.instance.currentUser!.updatePhotoURL(url);

        setState(() {
          photo_before = url;
        });
      } else {
        EasyLoading.dismiss();
        Utils.showToast(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่', Colors.red);
        return;
      }
    }
  }

  // ไปหน้า EditUserPage
  void goToEditUser() {
    final user = UserModel(
        user_id: user_id.toString().trim(),
        email: email.toString().trim(),
        name: name.toString().trim(),
        password: password.toString().trim(),
        social: tel.toString().trim(),
        tel: tel.toString().trim(),
        token: '',
        type: type.toString().trim(),
        photo: '');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditUserPage(my_account: user, from: 'edit'),
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
              // ปิด popup
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                //await Authentication.signOut(context: context);
                await FirebaseFirestore.instance
                    .collection('suggest_user')
                    .doc(user_id)
                    .update({'token': ''}).whenComplete(
                        () => print('Clear Token'));

                // if (Platform.isAndroid) {
                //   final deviceInfo = DeviceInfoPlugin();
                //   final androidInfo = await deviceInfo.androidInfo;

                //   final isEmulator = androidInfo.isPhysicalDevice == false;
                //   if (isEmulator) {
                //     await MySQLApi.updateData('/user/', {
                //       'dateTime':
                //           DateTime.now().millisecondsSinceEpoch.toString(),
                //       'email': email,
                //       'name': name,
                //       'password': password,
                //       'photo': photo_before,
                //       'social': social,
                //       'tel': tel,
                //       'token': '',
                //       'type': type,
                //       'user_id': user_id,
                //     });
                //   }
                // }

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
              //  await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => FirstPage(),
                    ),
                    (route) => false);
              },
              child: new Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}
