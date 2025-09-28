import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:suggest/widget/textform_widget.dart';
import 'package:suggest/widget/textformpassword_widget.dart';
import 'package:suggest/api/auth_utils.dart';
import 'package:suggest/api/authentication_google.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/tab/main_admin.dart';
import 'package:suggest/page/forgot_password.dart';
import 'package:suggest/page/user/tab/main_user.dart';
import 'package:suggest/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suggest/page/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));

    emailController.text = "";
    passwordController.text = "";
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildHeader(),
                  // รูปภาพถูกลบออกตรงนี้
                  buildEmail(),
                  const SizedBox(height: 8),
                  buildPassword(),
                  const SizedBox(height: 8),
                  buildForgetPassword(),
                  buildButton(),
                  buildTextRegister(),
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildHeader() => Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'เข้าสู่ระบบ',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ],
        ),
      );

  Widget buildEmail() => Container(
      margin: const EdgeInsets.only(top: 10),
      child: TextFormWidget(
          text: 'Email',
          readOnly: false,
          controller: emailController,
          type: TextInputType.emailAddress,
          inputFormat: []));

  Widget buildPassword() => TextFormPasswordWidget(
        text: 'Password',
        controller: passwordController,
        hidePassword: hidePassword,
        icon: IconButton(
          icon: hidePassword
              ? const Icon(Icons.visibility_outlined)
              : const Icon(Icons.visibility_off_outlined),
          onPressed: () => setState(() {
            hidePassword = !hidePassword;
          }),
        ),
      );

  Widget buildForgetPassword() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ForgotPassword(),
                    ),
                  ),
              child: const Text(
                'ลืมรหัสผ่าน',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ))
        ],
      );

  Widget buildButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0))),
            backgroundColor:
                MaterialStateProperty.all(const Color.fromARGB(255, 0, 109, 4)),
          ),
          onPressed: () {
            saveTodo();
          },
          child: const Text(
            'เข้าสู่ระบบ',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget buildTextRegister() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ยังไม่มีบัญชีใช่มั้ย?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              },
              child: const Text(
                'สมัครเลย',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ))
        ],
      );

  void saveTodo() async {
    FocusScope.of(context).unfocus();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่อีเมลล์ก่อน', Colors.red);
      return;
    }

    if (password.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รหัสก่อน', Colors.red);
      return;
    }

    if (password.length != 6) {
      Utils.showToast(context, 'รหัสผ่านต้องมี 6 ตัว', Colors.red);
      return;
    }

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    final collection = FirebaseFirestore.instance.collection("suggest_user");
    final snapshot = await collection
        .where("email", isEqualTo: email)
        .where("password", isEqualTo: password)
        .get();

    if (snapshot.docs.isEmpty) {
      EasyLoading.dismiss();
      Utils.showToast(context, 'ไม่พบข้อมูลนี้', Colors.red);
      return;
    } else {
      EasyLoading.dismiss();

      String userId = snapshot.docs.first['user_id'];
      String tel = snapshot.docs.first['tel'];
      String type = snapshot.docs.first['type'];
      String name = snapshot.docs.first['name'];
      String photo = snapshot.docs.first['photo'];
      String social = snapshot.docs.first['social'];

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('check', true);
      prefs.setString('user_id', userId);
      prefs.setString('tel', tel);
      prefs.setString('type', type);
      prefs.setString('password', password);
      prefs.setString('email', email);
      prefs.setString('name', name);
      prefs.setString('photo', photo);
      prefs.setString('social', social);

      final my_account = UserModel(
        user_id: userId,
        tel: tel,
        token: '',
        type: type,
        password: password,
        email: email,
        name: name,
        photo: photo,
        social: social,
      );

      if (type == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainAdmin(
                    my_account: my_account,
                    from: 'login',
                  )),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainUser(
                    my_account: my_account,
                    from: 'login',
                  )),
          (Route<dynamic> route) => false,
        );
      }
    }
  }
}
