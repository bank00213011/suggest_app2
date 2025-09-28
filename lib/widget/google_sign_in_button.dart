import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:suggest/api/auth_google.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/user/tab/main_user.dart';

import 'package:suggest/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInButton extends StatelessWidget {
  final String label;
  final Color color;
  final double roundness;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final Widget? trailingWidget;

  //GoogleSignInButton({Key? key, required this.text}) : super(key: key);

  const GoogleSignInButton({
    Key? key,
    required this.label,
    required this.color,
    this.roundness = 18,
    this.fontWeight = FontWeight.bold,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.trailingWidget,
  }) : super(key: key);
  //bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        onPressed: () async {
          User? user =
              await AuthenticationGoogle.signInWithGoogle(context: context);

          if (user != null) {
            EasyLoading.show(status: "กรุณารอสักครู่...");

            final collection =
                FirebaseFirestore.instance.collection("suggest_user");
            final snapshot =
                await collection.where("email", isEqualTo: user.email!).get();

            if (snapshot.docs.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('suggest_user')
                  .where('email', isEqualTo: user.email!)
                  .limit(1)
                  .get()
                  .then((querySnapshot) {
                querySnapshot.docs.forEach((result) async {
                  var disable = result.data()['disable'];
                  var email = result.data()['email'];
                  var password = result.data()['password'];
                  var name = result.data()['name'];
                  var tel = result.data()['tel'];
                  var type = result.data()['type'];
                  var photo = result.data()['photo'];
                  var social = result.data()['social'];
                  var user_id = result.data()['user_id'];

                  if (disable) {
                    Utils.showToast(context,
                        "บัญชีถูกปิดอยู่ กรุณาติดต่อแอดมิน", Colors.red);
                    EasyLoading.dismiss();
                    return;
                  }

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool('check', true);
                  prefs.setString('email', email);
                  prefs.setString('password', password);
                  prefs.setString('name', name);
                  prefs.setString('tel', tel);
                  prefs.setString('type', type);
                  prefs.setString('photo', photo);
                  prefs.setString('social', social);
                  prefs.setString('user_id', user_id);

                  final my_account = UserModel(
                    email: email,
                    name: name,
                    password: password,
                    tel: tel,
                    type: type,
                    token: '',
                    photo: photo,
                    user_id: user_id,
                    social: social,
                  );

                  EasyLoading.dismiss();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainUser(
                        my_account: my_account,
                        from: 'login',
                      ),
                    ),
                    (Route<dynamic> route) => false,
                  );
                });
              }).catchError((e) {
                Utils.showToast(context, "เกิดข้อผิดพลาด", Colors.red);
              });
            } else {
              var userId = DateTime.now().millisecondsSinceEpoch.toString();

              await FirebaseFirestore.instance
                  .collection('suggest_user')
                  .doc(userId)
                  .set({
                'dateTime': DateTime.now(),
                'disable': false,
                'email': user.email,
                'name': user.displayName,
                'password': '******',
                'photo': user.photoURL,
                'social': "google",
                'tel': '',
                'token': '',
                'type': 'user',
                'user_id': userId,
              });

              if (Platform.isAndroid) {
                final deviceInfo = DeviceInfoPlugin();
                final androidInfo = await deviceInfo.androidInfo;

                final isEmulator = androidInfo.isPhysicalDevice == false;
                if (isEmulator) {
                  await MySQLApi.postData('/user/', {
                    'dateTime':
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    'disable': false,
                    'email': user.email,
                    'name': user.displayName,
                    'password': '******',
                    'photo': user.photoURL,
                    'social': "google",
                    'tel': '',
                    'token': '',
                    'type': 'user',
                    'user_id': userId,
                  });
                }
              }

              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('check', true);
              prefs.setString('user_id', userId);
              prefs.setString('email', user.email!);
              prefs.setString('name', user.displayName!);
              prefs.setString('password', '******');
              prefs.setString('tel', '');
              prefs.setString('type', 'user');
              prefs.setString('photo', user.photoURL!);
              prefs.setString('social', "google");

              final my_account = UserModel(
                  email: user.email!,
                  name: user.displayName!,
                  password: '******',
                  tel: '',
                  type: 'user',
                  token: '',
                  photo: user.photoURL!,
                  user_id: userId,
                  social: 'google');
              EasyLoading.dismiss();
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
        },
        // style: ElevatedButton.styleFrom(
        //   visualDensity: VisualDensity.compact,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(roundness),
        //   ),
        //   elevation: 0,
        //   backgroundColor: color,
        //   textStyle: TextStyle(
        //     color: Colors.white,
        //     fontWeight: fontWeight,
        //   ),
        //   padding: padding,
        // ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("assets/google.png"),
                height: 25.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     CircleAvatar(
        //       radius: 14,
        //       backgroundColor: Colors.white,
        //       child: Image.asset(
        //         'assets/google.png',
        //         height: 24,
        //       ),
        //     ),
        //     Padding(
        //         padding: const EdgeInsets.only(left: 10),
        //         child: Text(
        //           label,
        //           style: const TextStyle(fontSize: 18, color: Colors.white),
        //         ))
        //   ],
        // ),
      );
}
