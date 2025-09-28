import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
//import 'package:file_picker/file_picker.dart';

// ไฟล์ จัดการเครื่องมือต่างๆในแอพ
class Utils {
  // แสดง SnackBar
  // static void showSnackBar(BuildContext context, String text) =>
  //     Scaffold.of(context)
  //       ..removeCurrentSnackBar()
  //       ..showSnackBar(SnackBar(content: Text(text)));

  // แสดงข้อความ
  static void showToast(BuildContext context, String text, Color color) =>
      Fluttertoast.showToast(
          msg: text,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: color,
          textColor: Colors.white,
          fontSize: 16.0);

  // รับ Timestamp มาเป็นวัน
  static DateTime toDateTime(Timestamp value) {
    if (value == null) return null!;

    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  // รับ month แล้วคืนเป็น String
  static monthThai(int month) {
    if (month == 1) {
      return 'ม.ค.';
    } else if (month == 2) {
      return 'ก.พ.';
    } else if (month == 3) {
      return 'มี.ค.';
    } else if (month == 4) {
      return 'เม.ย.';
    } else if (month == 5) {
      return 'พ.ค.';
    } else if (month == 6) {
      return 'มิ.ย.';
    } else if (month == 7) {
      return 'ก.ค.';
    } else if (month == 8) {
      return 'ส.ค.';
    } else if (month == 9) {
      return 'ก.ย.';
    } else if (month == 10) {
      return 'ต.ค.';
    } else if (month == 11) {
      return 'พ.ย.';
    } else if (month == 12) {
      return 'ธ.ค.';
    }
  }

  // แสดงวัน ณ ปัจจุบัน
  static String getDateThai() {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    String day, month = '', year;

    day = date.day.toString();
    year = (date.year + 543).toString();

    if (date.month == 1) {
      month = 'ม.ค.';
    } else if (date.month == 2) {
      month = 'ก.พ.';
    } else if (date.month == 3) {
      month = 'มี.ค.';
    } else if (date.month == 4) {
      month = 'เม.ย.';
    } else if (date.month == 5) {
      month = 'พ.ค.';
    } else if (date.month == 6) {
      month = 'มิ.ย.';
    } else if (date.month == 7) {
      month = 'ก.ค.';
    } else if (date.month == 8) {
      month = 'ส.ค.';
    } else if (date.month == 9) {
      month = 'ก.ย.';
    } else if (date.month == 10) {
      month = 'ต.ค.';
    } else if (date.month == 11) {
      month = 'พ.ย.';
    } else if (date.month == 12) {
      month = 'ธ.ค.';
    }
    return day + ' ' + month + ' ' + year;
  }

  static String getMonthThai() {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    String day, month = '', year;
    year = (date.year + 543).toString();

    if (date.month == 1) {
      month = 'ม.ค.';
    } else if (date.month == 2) {
      month = 'ก.พ.';
    } else if (date.month == 3) {
      month = 'มี.ค.';
    } else if (date.month == 4) {
      month = 'เม.ย.';
    } else if (date.month == 5) {
      month = 'พ.ค.';
    } else if (date.month == 6) {
      month = 'มิ.ย.';
    } else if (date.month == 7) {
      month = 'ก.ค.';
    } else if (date.month == 8) {
      month = 'ส.ค.';
    } else if (date.month == 9) {
      month = 'ก.ย.';
    } else if (date.month == 10) {
      month = 'ต.ค.';
    } else if (date.month == 11) {
      month = 'พ.ย.';
    } else if (date.month == 12) {
      month = 'ธ.ค.';
    }
    return month + ' ' + year;
  }

  static getMonthThaiFromNumber(int month) {
    if (month == 1) {
      return 'ม.ค.';
    } else if (month == 2) {
      return 'ก.พ.';
    } else if (month == 3) {
      return 'มี.ค.';
    } else if (month == 4) {
      return 'เม.ย.';
    } else if (month == 5) {
      return 'พ.ค.';
    } else if (month == 6) {
      return 'มิ.ย.';
    } else if (month == 7) {
      return 'ก.ค.';
    } else if (month == 8) {
      return 'ส.ค.';
    } else if (month == 9) {
      return 'ก.ย.';
    } else if (month == 10) {
      return 'ต.ค.';
    } else if (month == 11) {
      return 'พ.ย.';
    } else if (month == 12) {
      return 'ธ.ค.';
    }
  }

  static String getYearThai() {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    String year;
    year = (date.year + 543).toString();

    return year;
  }

  static String differenceTime(DateTime a1) {
    DateTime dt1 = DateTime.now();
    Duration diff = dt1.difference(a1);
    String time = '';
    if (diff.inDays >= 7) {
      time = '${diff.inDays % 7} สัปดาห์';
    } else if (diff.inDays >= 1) {
      time = '${diff.inDays} วัน';
    } else if (diff.inHours >= 1) {
      time = '${diff.inHours} ชั่วโมง';
    } else if (diff.inMinutes >= 1) {
      time = '${diff.inMinutes} นาที';
    } else if (diff.inMinutes < 1) {
      time = 'เมื่อเร็วๆนี้';
    }

    return time;
  }

  static Future<bool> checkInternet() async {
    bool result = await InternetConnectionChecker.instance.hasConnection;
    if (result == true) {
      print('YAY! Free cute dog pics!');
      return false;
    } else {
      print('No internet');
      return true;
    }
  }

  static Future<bool> sendPushNotifications(BuildContext context,
      {required String title,
      required String body,
      required String token}) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to": token == 'librarian' ? "/topics/librarian" : token,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "type": '0rder',
        "id": '28',
        "click_action": 'FLUTTER_NOTIFICATION_CLICK',
      }
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAW2AvWH8:APA91bGemAymozOEvD2RiJreUVVL02ozCjqlagSdjXO2HHCEcY9ftXdVTpHcLuTkQrODqJ0Bn0MUZBCwSSx5JjC8zuKtiqnk1woJrQbqO14yTbMyRaHUiyiWyO73ZJcvuvzY40HMO5y9' // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      print('test ok push CFM');
      //Utils.showToast(context, 'OK Notification', Colors.green);
      return true;
    } else {
      print(' CFM error');
      return false;
    }
  }

  static String returnPassword(int length) {
    String a = '';
    for (int i = 0; i < length; i++) {
      a += '*';
    }
    a.trim();
    return a;
  }
}
