// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suggest/utils.dart';
import 'package:suggest/widget/textform_widget.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPassword createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {
  final emailController = TextEditingController();
  String password = '';

  @override // หน้า UI
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('ลืมรหัสผ่าน'),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'กรุณาใส่อีเมลล์เพื่อทำการแสดงรหัสผ่าน',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                buildEmail(),
                const SizedBox(height: 10),
                buildButton(context),
                const SizedBox(
                  height: 10,
                ),
                if (password != '')
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('รหัสผ่านของคุณคือ $password'),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(
                              ClipboardData(text: password));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('บันทึกรหัสผ่านแล้ว'),
                          ));
                        },
                        child: const Row(
                          children: [Text('Copy'), Icon(Icons.copy)],
                        ))
                  ])
              ],
            ),
          ),
        ),
      );

  Widget buildHeader() => const Align(
        child: Text(
          'Register',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        alignment: Alignment.topLeft,
      );

  Widget buildEmail() => TextFormWidget(
        text: 'E - Mail',
        readOnly: false,
        controller: emailController,
        type: TextInputType.emailAddress,
        inputFormat: [],
      );

  Widget buildButton(BuildContext context) => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.purple),
        ),
        onPressed: () => saveTodo(context),
        label: const Text(
          'แสดงรหัสผ่าน',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        icon: const Icon(
          Icons.email_outlined,
          color: Colors.white,
        ),
      ));

  void saveTodo(BuildContext context) async {
    final email = emailController.text.trim();

    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (email.isEmpty) {
      Utils.showToast(context, 'กรุณากรอกอีเมลล์ก่อน', Colors.red);
      return;
    } else if (!emailRegExp.hasMatch(email)) {
      Utils.showToast(context, 'กรุณาตรวจสอบอีเมลล์ก่อน', Colors.red);
      return;
    }

    final collection = FirebaseFirestore.instance.collection("suggest_user");
    final snapshot =
        await collection.where("email", isEqualTo: email).limit(1).get();

    if (snapshot.docs.isEmpty) {
      Utils.showToast(context, "ข้อมูลไม่ถูกต้อง กรุณาลองใหม่", Colors.red);
      return;
    } else {
      setState(() {
        password = snapshot.docs.first['password'];
      });
    }

    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) => const Center(
    //           child: CircularProgressIndicator(),
    //         ));

    // try {
    //   await FirebaseAuth.instance
    //       .sendPasswordResetEmail(email: emailController.text.trim());
    //   Utils.showToast(context, 'Passowrd Reset Email Sent', Colors.green);
    //   Navigator.of(context).popUntil((route) => route.isFirst);
    // } on FirebaseAuthException catch (e) {
    //   Utils.showToast(context, e.message.toString(), Colors.red);
    //   Navigator.of(context).pop();
    // }
  }
}
