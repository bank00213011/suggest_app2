import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:suggest/api/authentication_google.dart';
import 'package:suggest/api/custom_colors.dart';
import 'package:suggest/app_localizations.dart';
import 'package:suggest/page/admin/tab/main_admin.dart';
import 'package:suggest/page/login.dart';
import 'package:flutter/material.dart';

import 'package:suggest/widget/google_sign_in_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LanguagesActions { english, chinese }

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildHeader(),            // 🔹 หัวข้อ "แอพแนะนำสถานที่"
                    const SizedBox(height: 16),

                    // 🔽 ย้ายโลโก้มาไว้ใต้หัวข้อ
                    ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 26),
                  //  buildButtonGoogle(),
                    const SizedBox(height: 20),
                    buildButton2(context),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget buildHeader() => const Align(
        alignment: Alignment.center,
        child: Text(
          'แอปแนะนำสถานที่ออกกำลังกาย',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 15, 15, 15),
          ),
        ),
      );

 // Widget buildButtonGoogle() => GoogleSignInButton(
  //      label: "เข้าสู่ระบบด้วย Google",
 //       color: Colors.blue,
 //     );

  Widget buildButton2(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.all(Color.fromARGB(255, 0, 109, 4)),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          ),
          child: const Text(
            'ล็อกอินด้วยอีเมล',
            maxLines: 1,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
}

// ใช้ตรวจสอบว่าผู้ใช้ (docId) มีอยู่ใน Firestore หรือยัง
Future<bool> checkIfDocExists(String docId) async {
  try {
    var collectionRef = FirebaseFirestore.instance.collection('suggest_user');
    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  } catch (e) {
    throw e;
  }
}
