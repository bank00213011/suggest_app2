import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:suggest/utils.dart';

class EPAuthentication {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.showToast(
            context, 'ไม่มีข้อมูลบัญชีนี้ กรุณาสมัครสมาชิกก่อน', Colors.red);
      } else if (e.code == 'wrong-password') {
        Utils.showToast(context, 'รหัสผ่านไม่ถูกต้อง', Colors.red);
      }
    }

    return user!;
  }

  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.updatePhotoURL("");
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Utils.showToast(
            context, 'รหัสผ่านเดาง่ายเกินไป กรุณาเปลี่ยน', Colors.red);
      } else if (e.code == 'email-already-in-use') {
        Utils.showToast(
            context, 'อีเมลล์นี้ถูกใช้แล้ว กรุณาเปลี่ยน', Colors.red);
      }
    } catch (e) {
      print(e);
    }

    return user;
  }

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}
