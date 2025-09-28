// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:suggest/api/mysql_api.dart';

import 'package:suggest/utils.dart';
import 'package:suggest/widget/button_widget.dart';
import 'package:suggest/widget/textform_widget.dart';
import 'package:suggest/widget/textformpassword_widget.dart';

class UserAdd extends StatefulWidget {
  @override
  _UserAdd createState() => _UserAdd();
}

class _UserAdd extends State<UserAdd> {
  // ประกาศตัวแปรก่อนเข้าหน้า UI
  final _formKey = GlobalKey<FormState>();
  late String email = '',
      tel = '',
      password = '',
      name = '',
      password_confirm = '';
  bool _validate = false;

  bool hidePassword1 = false, hidePassword2 = false;

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
          title: const Text('หน้าเพิ่มบัญชีผู้ใช้งาน'),
        ),
        body: Container(
          height: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildName(),
                  const SizedBox(height: 8),
                  buildEmail(),
                  const SizedBox(height: 8),
                  buildPassword(),
                  const SizedBox(height: 8),
                  buildPasswordConfirm(),
                  const SizedBox(height: 8),
                  buildTel(),
                  const SizedBox(height: 16),
                  buildButton()
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildHeader() => Align(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สร้างบัญชีผู้ใช้งาน',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            Text(
              'สำหรับแอดมินเท่านั้น',
              style: TextStyle(color: Colors.green),
            )
          ],
        ),
        alignment: Alignment.topLeft,
      );

  Widget buildImage() => Image.asset(
        'assets/b.png',
        height: 150,
      );

  Widget buildTextRegister() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'สร้างบัญชีเจ้าหน้าที่',
            style: TextStyle(fontSize: 16),
          ),
        ],
      );

  Widget buildEmail() => TextFormWidget(
        text: 'อีเมลล์',
        readOnly: false,
        controller: emailController,
        type: TextInputType.emailAddress,
        inputFormat: [],
      );

  Widget buildName() => TextFormWidget(
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

  Widget buildButton() => ButtonWidget(
      label: 'บันทึก', onPressed: () => saveTodo(), color: Colors.blue);

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

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    print(await checkIfDocExists(email.trim()));
    EasyLoading.dismiss();

    if (await checkIfDocExists(email.trim()) == false) {
      EasyLoading.dismiss();
      Utils.showToast(context, 'อีเมลซ้ำ กรุณาเปลี่ยน',
          Colors.red); // ส่งค่าไปเพิ่มข้อมูลผู้ใช้
    } else {
      final doc = FirebaseFirestore.instance.collection('suggest_user').doc();

       doc.set({
        'user_id': doc.id,
        'email': email.trim(),
        'password': password.trim(),
        'name': name.trim(),
        'tel': tel.trim(),
        'token': '',
        'type': 'ผู้ใช้ทั่วไป',
        'photo': '',
        'dateTime': DateTime.now(),
      }).whenComplete(
          () => Utils.showToast(context, 'เพิ่มผู้ใช้สำเร็จ', Colors.green));

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        final isEmulator = androidInfo.isPhysicalDevice == false;
        if (isEmulator) {
          await MySQLApi.postData('/user/', {
            'user_id': doc.id,
            'email': email.trim(),
            'password': password.trim(),
            'name': name.trim(),
            'tel': tel.trim(),
            'token': '',
            'type': 'ผู้ใช้ทั่วไป',
            'photo': '',
            'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          });
        }
      }
      EasyLoading.dismiss();
      Navigator.pop(context); // ย้อนกลับหน้าเดิม
    }
  }

  // เช็คว่าชื่อซ้ำหรือไม่
  Future<bool> checkIfDocExists(String email) async {
    bool check = false;
    final snapshot = await FirebaseFirestore.instance
        .collection('suggest_user')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.length == 0) {
      // ถ้าไม่ซ้ำให้เป็น false
      check = true;
    } else {
      // ถ้าซ้ำให้เป็น true
      check = false;
    }
    return check;
  }
}
