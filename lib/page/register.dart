// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/widget/textform_widget.dart';
import 'package:suggest/widget/textformpassword_widget.dart';
import 'package:http/http.dart' as http;
import 'package:suggest/api/auth_utils.dart';
import 'package:suggest/page/login.dart';
import 'package:suggest/page/user/tab/main_user.dart';
import 'package:suggest/utils.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late String email = '',
      tel = '',
      password = '',
      name = '',
      password_confirm = '';
  bool hidePassword1 = true, hidePassword2 = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final nameController = TextEditingController();
  final telController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    passwordConfirmController.addListener(() => setState(() {}));
    nameController.addListener(() => setState(() {}));
    telController.addListener(() => setState(() {}));

    emailController.text = '';
    passwordController.text = '';
    passwordConfirmController.text = '';
    nameController.text = '';
    telController.text = '';
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    nameController.dispose();
    telController.dispose();

    super.dispose();
  }

  @override // หน้า UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('หน้าสมัครสมาชิก'),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                // ไล่ widget จากบนลงล่าง
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  buildHeader(),
                  // buildImage(),
                  // buildTextRegister(),
                  buildUsername(),
                  const SizedBox(height: 8),
                  buildEmail(),
                  const SizedBox(height: 8),
                  buildPassword(),
                  const SizedBox(height: 8),
                  buildPasswordConfirm(),
                  const SizedBox(height: 8),
                  buildTel(),
                  const SizedBox(height: 16),
                  buildButton(),
                  buildTextLogin()
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildHeader() => Align(
        child: Text(
          'สร้างบัญชี',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        alignment: Alignment.topLeft,
      );

  Widget buildImage() => Image.asset(
        'assets/b.png',
        height: 150,
      );

  Widget buildEmail() => TextFormWidget(
        text: 'อีเมลล์',
        readOnly: false,
        controller: emailController,
        type: TextInputType.emailAddress,
        inputFormat: [],
      );

  Widget buildUsername() => TextFormWidget(
        text: 'ชื่อ - นามสกุล',
        readOnly: false,
        controller: nameController,
        type: TextInputType.text,
        inputFormat: [],
      );

  Widget buildPassword() => TextFormPasswordWidget(
        text: 'รหัสผ่าน',
        controller: passwordController,
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

  Widget buildPasswordConfirm() => TextFormPasswordWidget(
        text: 'รหัสผ่านอีกครั้ง',
        controller: passwordConfirmController,
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

  Widget buildTel() => TextFormWidget(
        text: 'เบอร์โทร',
        readOnly: false,
        controller: telController,
        type: TextInputType.number,
        inputFormat: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
      );

  Widget buildTextLogin() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'มีบัญชีอยู่แล้ว',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text(
                'เข้าสู่ระบบ',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ))
        ],
      );

  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Color.fromARGB(255, 0, 109, 4)),
          ),
          onPressed: () {
            saveTodo();
          },
          child: Text(
            'สมัครสมาชิก',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirm = passwordConfirmController.text.trim();
    final tel = telController.text.trim();

    if (name.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ชื่อก่อน', Colors.red);
      return;
    }

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (email.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่อีเมลล์ก่อน', Colors.red);
      return;
    } else if (!emailRegExp.hasMatch(email)) {
      Utils.showToast(context, 'กรุณาตรวจสอบอีเมลล์ก่อน', Colors.red);
      return;
    }

    if (password.length < 5) {
      Utils.showToast(context, 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว', Colors.red);
      return;
    }

    if (passwordConfirm != password) {
      Utils.showToast(context, 'รหัสผ่านไม่ตรงกัน', Colors.red);
      return;
    }

    if (tel.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่เบอร์โทรก่อน', Colors.red);
      return;
    }

    if (tel.length != 10) {
      Utils.showToast(context, 'เบอร์โทรต้องมี 10 ตัว', Colors.red);
      return;
    }

    final collection = FirebaseFirestore.instance.collection("suggest_user");
    final snapshot = await collection.where("email", isEqualTo: email).get();

    if (snapshot.docs.isNotEmpty) {
      Utils.showToast(context, 'อีเมลล์นี้มีผู้ใช้แล้ว', Colors.red);
      return;
    }

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    var userId = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseFirestore.instance
        .collection('suggest_user')
        .doc(userId)
        .set({
      'dateTime': DateTime.now(),
      'email': email.trim(),
      'name': name.trim(),
      'password': password.trim(),
      'photo': '',
      'social': 'email',
      'tel': tel.trim(),
      'token': '',
      'type': 'user',
      'user_id': userId,
    }).whenComplete(() {
      Utils.showToast(context, 'สมัครสมาชิกสำเร็จ', Colors.green);
    });

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        await MySQLApi.postData('/user/', {
          'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          'email': email.trim(),
          'name': name.trim(),
          'password': password.trim(),
          'photo': '',
          'social': 'email',
          'tel': tel.trim(),
          'token': '',
          'type': 'user',
          'user_id': userId,
        });
      }
    }

    EasyLoading.dismiss();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
