import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/page/admin/tab/main_admin.dart';
import 'package:suggest/page/user/tab/main_user.dart';
import 'package:suggest/utils.dart';
import 'package:suggest/widget/button_widget.dart';
import 'package:suggest/widget/textform_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suggest/model/user_model.dart';

class EditUserPage extends StatefulWidget {
  final UserModel my_account;
  final String from;

  // รับค่ามาจากหน้าก่อน
  EditUserPage({Key? key, required this.my_account, required this.from})
      : super(key: key);

  @override
  _EditUserPage createState() => _EditUserPage();
}

class _EditUserPage extends State<EditUserPage> {
  // ประกาศตัวแปร
  final _formKey = GlobalKey<FormState>();
  late String? user_id, email, name, password, tel, type, from;
  late UserModel user;
  bool hidePassword = false;

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final telController = TextEditingController();

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    user_id = widget.my_account.user_id;
    email = widget.my_account.email;
    name = widget.my_account.name;
    password = widget.my_account.password;
    tel = widget.my_account.tel;
    type = widget.my_account.type;
    from = widget.from;

    emailController.addListener(() => setState(() {}));
    nameController.addListener(() => setState(() {}));
    telController.addListener(() => setState(() {}));

    emailController.text = email!;
    nameController.text = name!;
    telController.text = tel!;
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    telController.dispose();

    super.dispose();
  }

  @override // แสดง UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('แก้ไขโปรไฟล์'),
        ),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              // แสดงจากบนลงล่าง
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildEmail(),
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
      );

  Widget buildEmail() => TextFormWidget(
        text: 'E - mail',
        readOnly: false,
        controller: emailController,
        type: TextInputType.emailAddress,
        inputFormat: [],
      );

  // TextFormField(
  //       maxLines: 1,
  //       readOnly: true,
  //       initialValue: email,
  //       onChanged: (email) => setState(() => this.email = email),
  //       validator: (email) {
  //         if (email!.isEmpty) {
  //           return 'กรุณาใส่อีเมลก่อน';
  //         }
  //         return null;
  //       },
  //       decoration: const InputDecoration(
  //         border: OutlineInputBorder(),
  //         labelText: 'E - mail',
  //       ),
  //     );

  Widget buildUsername() => TextFormWidget(
        text: 'ชื่อผู้ใช้',
        readOnly: false,
        controller: nameController,
        type: TextInputType.name,
        inputFormat: [],
      );

  // TextFormField(
  //       maxLines: 1,
  //       initialValue: name,
  //       onChanged: (name) => setState(() => this.name = name),
  //       validator: (name) {
  //         if (name!.isEmpty) {
  //           return 'กรุณาใส่ชื่อบัญชีก่อน';
  //         }
  //         return null;
  //       },
  //       decoration: InputDecoration(
  //         border: OutlineInputBorder(),
  //         labelText: 'กรุณาใส่ชื่อบัญชี',
  //       ),
  //     );

  Widget buildTel() => TextFormWidget(
        text: 'เบอร์โทร',
        readOnly: false,
        controller: telController,
        type: TextInputType.number,
        inputFormat: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
      );

  // TextFormField(
  //       maxLines: 1,
  //       initialValue: tel,
  //       keyboardType: TextInputType.number,
  //       inputFormatters: <TextInputFormatter>[
  //         FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
  //       ],
  //       onChanged: (tel) => setState(() => this.tel = tel),
  //       validator: (tel) {
  //         if (tel!.isEmpty) {
  //           return 'กรุณาใส่เบอร์โทรก่อน';
  //         }
  //         if (tel.length < 8) {
  //           return 'กรุณาเช็คจำนวนตัวเลขก่อน';
  //         }
  //         return null;
  //       },
  //       decoration: InputDecoration(
  //         border: OutlineInputBorder(),
  //         labelText: 'กรุณาใส่เบอร์โทร',
  //       ),
  //     );

  Widget buildButton() => ButtonWidget(
      label: 'แก้ไขข้อมูล', onPressed: () => saveTodo(), color: Colors.blue);

  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    final tel = telController.text.trim();

    if (name.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่ชื่อก่อน', Colors.red);
      return;
    }

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (email.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่อีเมลก่อน', Colors.red);
      return;
    } else if (!emailRegExp.hasMatch(email)) {
      Utils.showToast(context, 'กรุณาตรวจสอบอีเมลก่อน', Colors.red);
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

    await FirebaseFirestore.instance
        .collection('suggest_user')
        .doc(user_id)
        .update({
      'name': name.toString().trim(),
      'tel': tel.toString().trim(),
    });

    print(user_id);
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        await MySQLApi.updateData('/user/', {
          'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          'email': widget.my_account.email,
          'name': name.toString().trim(),
          'password': widget.my_account.password,
          'photo': widget.my_account.photo,
          'social': widget.my_account.social,
          'tel': tel.toString().trim(),
          'token': widget.my_account.token,
          'type': widget.my_account.type,
          'user_id': user_id,
        });
      }
    }

    //  final userAuth = FirebaseAuth.instance.currentUser;
    // await userAuth?.updateDisplayName(name.toString().trim());

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name.toString().trim());
    prefs.setString('tel', tel.toString().trim());

    final user = UserModel(
      user_id: user_id.toString().trim(),
      email: email.toString().trim(),
      name: name.toString().trim(),
      password: password.toString().trim(),
      photo: '',
      social: widget.my_account.social,
      tel: tel.toString().trim(),
      token: '',
      type: type.toString().trim(),
    );

    EasyLoading.dismiss();
    if (type == 'admin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MainAdmin(
                  my_account: user,
                  from: 'edit_user',
                )),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MainUser(
                  my_account: user,
                  from: 'edit_user',
                )),
        (Route<dynamic> route) => false,
      );
    }
  }
}
