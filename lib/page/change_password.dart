import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:suggest/api/mysql_api.dart';

import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/tab/main_admin.dart';
import 'package:suggest/page/user/tab/main_user.dart';
import 'package:suggest/utils.dart';
import 'package:suggest/widget/button_widget.dart';
import 'package:suggest/widget/textformpassword_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  final UserModel my_account;

  const ChangePassword({Key? key, required this.my_account}) : super(key: key);

  @override
  _ChangePassword createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool hidePassword1 = true, hidePassword2 = true, hidePassword3 = true;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();

    oldPasswordController.addListener(() => setState(() {}));
    newPasswordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override // แสดง UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('หน้าเปลี่ยนรหัส'),
        ),
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildOldPassword(),
                  const SizedBox(height: 8),
                  buildNewPassword(),
                  const SizedBox(height: 8),
                  buildConfirmPassword(),
                  const SizedBox(height: 8),
                  buildButton(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildOldPassword() => TextFormPasswordWidget(
        text: 'รหัสผ่านเดิม',
        controller: oldPasswordController,
        hidePassword: hidePassword1,
        icon: IconButton(
          icon: hidePassword1
              ? const Icon(
                  Icons.visibility_outlined,
                )
              : const Icon(
                  Icons.visibility_off_outlined,
                ),
          onPressed: () => setState(() {
            hidePassword1 = !hidePassword1;
          }),
        ),
      );

  Widget buildNewPassword() => TextFormPasswordWidget(
        text: 'รหัสผ่านใหม่',
        controller: newPasswordController,
        hidePassword: hidePassword2,
        icon: IconButton(
          icon: hidePassword2
              ? const Icon(
                  Icons.visibility_outlined,
                )
              : const Icon(
                  Icons.visibility_off_outlined,
                ),
          onPressed: () => setState(() {
            hidePassword2 = !hidePassword2;
          }),
        ),
      );

  Widget buildConfirmPassword() => TextFormPasswordWidget(
        text: 'ยืนยันรหัสผ่าน',
        controller: confirmPasswordController,
        hidePassword: hidePassword3,
        icon: IconButton(
          icon: hidePassword3
              ? const Icon(
                  Icons.visibility_outlined,
                )
              : const Icon(
                  Icons.visibility_off_outlined,
                ),
          onPressed: () => setState(() {
            hidePassword3 = !hidePassword3;
          }),
        ),
      );

  Widget buildButton() => ButtonWidget(
      label: 'เปลี่ยนรหัส', onPressed: () => saveTodo(), color: Colors.blue);

  // ฟังก์ชัน แกไ้ขข้อมูล
  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รหัสผ่านเดิมก่อน', Colors.red);
      return;
    }

    if (newPassword.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รหัสผ่านใหม่ก่อน', Colors.red);
      return;
    }

    if (confirmPassword.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รหัสผ่านใหม่อีกครั้งก่อน', Colors.red);
      return;
    }

    if (newPassword.length < 5) {
      Utils.showToast(context, 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว', Colors.red);
      return;
    }

    if (oldPassword != widget.my_account.password) {
      Utils.showToast(context, 'กรุณาใส่รหัสผ่านเดิมให้ถูกต้อง', Colors.red);
      return;
    }

    if (newPassword != confirmPassword) {
      Utils.showToast(
          context, 'รหัสผ่านใหม่กับรหัสยืนยันต้องตรงกัน', Colors.red);
      return;
    }

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    await FirebaseFirestore.instance
        .collection('suggest_user')
        .doc(widget.my_account.user_id)
        .update({
      'password': newPassword,
    });
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        await MySQLApi.updateData('/user/', {
          'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          'email': widget.my_account.email,
          'name': widget.my_account.name,
          'password': newPassword,
          'photo': widget.my_account.photo,
          'social': widget.my_account.social,
          'tel': widget.my_account.tel,
          'token': widget.my_account.token,
          'type': widget.my_account.type,
          'user_id': widget.my_account.user_id,
        });
      }
    }

    EasyLoading.dismiss();

    // final myUser = FirebaseAuth.instance.currentUser;
    // final cred = EmailAuthProvider.credential(
    //     email: myUser!.email!, password: widget.my_account.password);

    // myUser.reauthenticateWithCredential(cred).then((value) {
    //   myUser.updatePassword(newPassword).then((_) {
    //     print("OK");
    //   }).catchError((error) {
    //     print("Error");
    //   });
    // }).catchError((err) {});

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('password', newPassword);

    final user = UserModel(
        user_id: widget.my_account.user_id,
        email: widget.my_account.email,
        name: widget.my_account.name,
        password: newPassword,
        social: widget.my_account.social,
        tel: widget.my_account.tel,
        token: widget.my_account.token,
        type: widget.my_account.type,
        photo: widget.my_account.photo);

    // ignore: use_build_context_synchronously
    if (widget.my_account.type == 'admin') {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MainAdmin(
              my_account: user,
              from: 'edit_user',
            ),
          ),
          (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MainUser(
              my_account: user,
              from: 'edit_user',
            ),
          ),
          (route) => false);
    }
  }
}
