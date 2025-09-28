import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/widget/textform_widget.dart';
import 'package:suggest/widget/textformpassword_widget.dart';

class UserEdit extends StatefulWidget {
  final UserModel user;

  // รับค่ามาจากหน้าก่อน
  UserEdit({Key? key, required this.user}) : super(key: key);

  @override
  _UserEdit createState() => _UserEdit();
}

class _UserEdit extends State<UserEdit> {
  final _formKey = GlobalKey<FormState>();
  String? user_id, email, name, password, tel, type;
  bool _validate = false, hidePassword1 = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final nameController = TextEditingController();
  final telController = TextEditingController();

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    user_id = widget.user.user_id;
    email = widget.user.email;
    name = widget.user.name;
    password = widget.user.password;
    tel = widget.user.tel;
    type = widget.user.type;

    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    passwordConfirmController.addListener(() => setState(() {}));
    nameController.addListener(() => setState(() {}));
    telController.addListener(() => setState(() {}));

    emailController.text = email!;
    nameController.text = name!;
    telController.text = tel!;
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

  @override // แสดง UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('แก้ไขข้อมูลผู้ใช้'),
        ),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                // แสดงจากบนลงล่าง
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildEmail(),
                    const SizedBox(height: 8),
                    buildPassword(),
                    const SizedBox(height: 8),
                    buildUsername(),
                    const SizedBox(height: 8),
                    buildTel(),
                    const SizedBox(height: 16),
                    buildButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
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

  Widget buildTel() => TextFormWidget(
        text: 'เบอร์โทร',
        readOnly: false,
        controller: telController,
        type: TextInputType.number,
        inputFormat: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
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

  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ),
          onPressed: () {
            saveTodo();
          },
          child: const Text('แก้ไขข้อมูล',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ),
      );

  // ฟังก์ชัน แกไ้ขข้อมูล
  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    } else {
      EasyLoading.show(status: 'กรุณารอสักครู่...');

      // แก้ไขข้อมูล
      await FirebaseFirestore.instance
          .collection('suggest_user')
          .doc(user_id)
          .update({
        'name': name.toString().trim(),
        'password': password.toString().trim(),
        'tel': tel.toString().trim(),
      });
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        final isEmulator = androidInfo.isPhysicalDevice == false;
        if (isEmulator) {
          await MySQLApi.updateData('/user/', {
            'user_id': user_id,
            'name': name.toString().trim(),
            'password': password.toString().trim(),
            'tel': tel.toString().trim(),
          });
        }
      }

      EasyLoading.dismiss();

      Navigator.pop(context);
    }
  }
}
