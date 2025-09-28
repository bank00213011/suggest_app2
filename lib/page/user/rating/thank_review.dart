// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/user/tab/main_user.dart';

class ThankyouReview extends StatelessWidget {
  final UserModel my_account;
  ThankyouReview({Key? key, required this.my_account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/thank_you.svg'),
          SizedBox(
            height: 40,
          ),
          Text(
            '"ขอบคุณสำหรับการให้คะแนนพวกเรา เราจะนำมาปรับปรุงเพื่อให้บริการของเราดียิ่งขึ้น."',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 40,
          ),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0))),
                  backgroundColor: MaterialStateProperty.all(Colors.purple),
                ),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainUser(
                            my_account: my_account,
                            from: 'login',
                          )),
                  (Route<dynamic> route) => false,
                ),
                child: Text(
                  'กลับสู่หน้าหลัก',
                  style: TextStyle(color: Colors.white),
                ),
              ))
        ],
      ),
    ))));
  }
}
