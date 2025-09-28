// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/user/rating/thank_review.dart';
import 'package:suggest/widget/textform_widget.dart';

class RatingAdd extends StatefulWidget {
  final Place place;
  final UserModel my_account;

  RatingAdd({Key? key, required this.place, required this.my_account})
      : super(key: key);
  @override
  _RatingAdd createState() => _RatingAdd();
}

class _RatingAdd extends State<RatingAdd> {
  double? _ratingValue;
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    commentController.addListener(() => setState(() {}));
    commentController.text = '';
  }

  @override
  void dispose() {
    commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              'หน้าแสดงความคิดเห็น',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          CircleAvatar(
              radius: 40, backgroundImage: NetworkImage(widget.place.photo[0])),
          Text(
            widget.place.name,
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'ให้คะแนนพวกเราหน่อย',
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            'คะแนนของคุณคือกำลังใจของเรา',
            style: TextStyle(color: Colors.grey),
          ),
          RatingBar(
              initialRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              ratingWidget: RatingWidget(
                  full: const Icon(Icons.star, color: Colors.orange),
                  half: const Icon(
                    Icons.star_half,
                    color: Colors.orange,
                  ),
                  empty: const Icon(
                    Icons.star_outline,
                    color: Colors.grey,
                  )),
              onRatingUpdate: (value) {
                setState(() {
                  _ratingValue = value;
                });
              }),
          SizedBox(
            height: 10,
          ),
          TextFormWidget(
            text: 'ความคิดเห็น...',
            readOnly: false,
            controller: commentController,
            type: TextInputType.text,
            inputFormat: [],
          ),

          // Stack(
          //   children: [
          //     SizedBox(
          //         height: 40,
          //         child: TextFormField(
          //           maxLines: 1,
          //           controller: commentController,
          //           textAlignVertical: TextAlignVertical.top,
          //           textInputAction: TextInputAction.done,
          //           decoration: InputDecoration(
          //             border: OutlineInputBorder(),
          //             labelText: 'ความคิดเห็น...',
          //           ),
          //           autovalidateMode: AutovalidateMode.always,
          //           validator: (String? value) {
          //             print(value);
          //             value != ''
          //                 ? Positioned(
          //                     right: 0,
          //                     child: IconButton(
          //                       icon: Icon(Icons.close),
          //                       onPressed: () => commentController.clear(),
          //                     ))
          //                 : Container();
          //           },
          //         )),
          //   ],
          // ),
          SizedBox(
            height: 10,
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
                onPressed: () => save_data(),
                child: Text(
                  'แสดงความคิดเห็นและให้คะแนน',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ))
        ],
      ),
    )));
  }

  void save_data() async {
    if (_ratingValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('กรุณาให้คะแนนก่อน'),
      ));
      return;
    }

    EasyLoading.show(status: 'กรุณารอสักครู่...');

    String id = DateTime.now().millisecondsSinceEpoch.toString();

    final docComment =
        FirebaseFirestore.instance.collection('suggest_comment').doc(id);
    await docComment.set({
      'comment': commentController.text.trim(),
      'comment_id': id,
      'dateTime': DateTime.now(),
      'like': 0,
      'place_id': widget.place.place_id,
      'rating': _ratingValue,
      'user_id': widget.my_account.user_id,
      'who_like': []
    });

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        await MySQLApi.postData('/comment/', {
          'comment': commentController.text.trim(),
          'comment_id': id,
          'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          'like_data': 0,
          'place_id': widget.place.place_id,
          'rating': _ratingValue,
          'user_id': widget.my_account.user_id,
          'who_like': ""
        });
      }
    }

    await CloudFirestoreApi.setAverageRating(widget.place)
        .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('ให้คะแนนสำเร็จ'),
            )));

    EasyLoading.dismiss();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ThankyouReview(
                my_account: widget.my_account,
              )),
    );
  }
}
