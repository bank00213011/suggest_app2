import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/place.dart';

import 'package:suggest/model/user_model.dart';
import 'package:suggest/utils.dart';

// ไฟล์สำหรับจัดการข้อมูลใน firebase
class CloudFirestoreApi {
  static Stream<List<UserModel>> getUser() => FirebaseFirestore.instance
      .collection('suggest_user')
      .orderBy(UserModelField.dateTime, descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList());

  static Future<String> getTokenFromUserId(String user_id) async {
    String token = '';

    FirebaseFirestore.instance
        .collection('suggest_user')
        .where('user_id', isEqualTo: user_id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        token = result.data()['token'];
      });
    });

    return token;
  }

  static Future<String?> getUsername(String user_id) async {
    String? username;
    FirebaseFirestore.instance
        .collection('suggest_user')
        .where('user_id', isEqualTo: user_id)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        username = result.data()['username'];
      });
    });

    return username;
  }

  // รับค่า id แล้วคืนกลับไป
  static Future<String> getIdGroupMonth(String month) async {
    String? doc_id;
    FirebaseFirestore.instance
        .collection('suggest_group_month')
        .where('month', isEqualTo: month)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        doc_id = result.data()['group_month_id'];
      });
    });

    return doc_id!;
  }

  static Future<int> getSumBookAndReturn(String month, String status) async {
    int sum = 0, sum2 = 0;

    FirebaseFirestore.instance
        .collection('suggest_history')
        .where('status', isEqualTo: status)
        .where('month', isEqualTo: month)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        sum = result.data()['amount'];
        sum2 = sum + sum2;
      });
    });

    return sum2;
  }

  static Future<UserModel> getUserfromComment(String user_id) async {
    UserModel? my_account;

    final ref = await FirebaseFirestore.instance
        .collection('suggest_user')
        .where('user_id', isEqualTo: user_id)
        .get();

    if (ref.size == 0) {
      my_account = null;
      return my_account!;
    } else {
      FirebaseFirestore.instance
          .collection('suggest_user')
          .where('user_id', isEqualTo: user_id)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          var name = result.data()['name'];
          var email = result.data()['email'];
          var password = result.data()['password'];
          var photo = result.data()['photo'];
          var tel = result.data()['tel'];
          var type = result.data()['type'];
          var social = result.data()['social'];
          var photo1 = result.data()['photo'];

          my_account = UserModel(
              user_id: user_id,
              email: email!,
              name: name,
              password: password,
              tel: tel,
              token: '',
              type: type,
              social: social,
              photo: photo1);
        });
      });
    }

    return my_account!;
  }

//   // คำนวณราคารวม แล้วคืนกลับไป
  static Future<int> getSumBookMonth(String month, String status) async {
    int sum = 0;
    FirebaseFirestore.instance
        .collection('suggest_month')
        .where('month', isEqualTo: month)
        .where('status', isEqualTo: status)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        sum += int.parse(result.data()['amount']);
      });
    });
    return sum;
  }

  static Future addComment(
      String comment, String place_id, String user_id) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();

    final doc =
        FirebaseFirestore.instance.collection('suggest_comment').doc(id);
    doc.set({
      'comment': comment,
      'comment_id': id,
      'dateTime': DateTime.now(),
      'like': 0,
      'place_id': place_id,
      'user_id': user_id,
    });
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final isEmulator = androidInfo.isPhysicalDevice == false;
      if (isEmulator) {
        MySQLApi.postData('/comment/', {
          'comment': comment,
          'comment_id': id,
          'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          'like': 0,
          'place_id': place_id,
          'user_id': user_id,
        });
      }
    }
  }

  static Future setAverageRating(Place place) async {
    double sum = 0;

    final ref = await FirebaseFirestore.instance
        .collection('suggest_comment')
        .where('place_id', isEqualTo: place.place_id)
        .get();

    if (ref.size == 0) {
      FirebaseFirestore.instance
          .collection('suggest_place')
          .doc(place.place_id)
          .update({'rating': "0"});

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        final isEmulator = androidInfo.isPhysicalDevice == false;
        if (isEmulator) {
          MySQLApi.updateData('/place/', {
            'address': place.address,
            'category': place.category,
            'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
            'day': place.day,
            'detail': place.detail,
            'latitude': place.location.latitude,
            'longitude': place.location.longitude,
            'name': place.name,
            'photo': place.photo.toString(),
            'place_id': place.place_id,
            'rating': 0,
            'user_id': place.user_id
          });
        }
      }
    } else {
      FirebaseFirestore.instance
          .collection('suggest_comment')
          .where('place_id', isEqualTo: place.place_id)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          sum = sum + result.data()['rating'];
        });
      });

      final average = (sum / ref.size).toStringAsFixed(1);
      print(average);

      FirebaseFirestore.instance
          .collection('suggest_place')
          .doc(place.place_id)
          .update({'rating': double.parse(average)});

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        final isEmulator = androidInfo.isPhysicalDevice == false;
        if (isEmulator) {
          MySQLApi.updateData('/place/', {
            'address': place.address,
            'category': place.category,
            'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
            'day': place.day,
            'detail': place.detail,
            'latitude': place.location.latitude,
            'longitude': place.location.longitude,
            'name': place.name,
            'photo': place.photo.toString(),
            'place_id': place.place_id,
            'rating': double.parse(average),
            'user_id': place.user_id
          });
        }
      }
    }
  }

  static Future addFavoritePlace(
      String place_id, String user_id, String type) async {
    if (type == 'add') {
      if (checkLikePlace(place_id, user_id) == true) {
        return;
      }

      String id = DateTime.now().millisecondsSinceEpoch.toString();

      final doc =
          FirebaseFirestore.instance.collection('suggest_favorite').doc(id);
      doc.set({
        'favorite_id': id,
        'place_id': place_id,
        'user_id': user_id,
        'dateTime': DateTime.now(),
      });
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        final isEmulator = androidInfo.isPhysicalDevice == false;
        if (isEmulator) {
          MySQLApi.postData('/favorite/', {
            'favorite_id': id,
            'place_id': place_id,
            'user_id': user_id,
            'dateTime': DateTime.now().millisecondsSinceEpoch.toString(),
          });
        }
      }
    } else {
      var id = await getPlaceIdFromUserId(place_id, user_id);
      FirebaseFirestore.instance
          .collection('suggest_favorite')
          .doc(id)
          .delete();

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        final isEmulator = androidInfo.isPhysicalDevice == false;
        if (isEmulator) {
          MySQLApi.deleteData('/favorite/', {
            'favorite_id': id,
          });
        }
      }
    }
  }

  static Future<String?> getPlaceIdFromUserId(
      String placeId, String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('suggest_favorite')
          .where('place_id', isEqualTo: placeId)
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final favoriteId = data['favorite_id'] as String?;
        print("test : $favoriteId");
        return favoriteId;
      } else {
        return null; // กรณีไม่เจอข้อมูล
      }
    } catch (e) {
      print("Error getPlaceIdFromUserId: $e");
      return null;
    }
  }

  static Future<Place?> getPlaceFromId(String placeId) async {
    try {
      final ref = await FirebaseFirestore.instance
          .collection('suggest_place')
          .where('place_id', isEqualTo: placeId)
          .limit(1)
          .get();

      if (ref.docs.isEmpty) {
        return null; // ไม่มีข้อมูล
      }

      final doc = ref.docs.first;
      final data = doc.data();

      return Place(
        user_id: data['user_id'],
        name: data['name'],
        photo: data['photo'],
        address: data['address'],
        category: data['category'],
        day: data['day'],
        detail: data['detail'],
        location: data['location'],
        place_id: data['place_id'],
        rating: (data['rating'] as num).toDouble(),
      );
    } catch (e) {
      print("Error getPlaceFromId: $e");
      return null;
    }
  }

  static Future<bool> checkLikePlace(String place_id, String user_id) async {
    bool check;
    final ref = await FirebaseFirestore.instance
        .collection('suggest_favorite')
        .where('place_id', isEqualTo: place_id)
        .where('user_id', isEqualTo: user_id)
        .get();

    ref.size == 0 ? check = false : check = true;
    return check;
  }

  static Future<bool> whoLikeComment(String commentId, String userId) async {
    try {
      final ref = await FirebaseFirestore.instance
          .collection('suggest_comment')
          .where('comment_id', isEqualTo: commentId)
          .where('who_like',
              arrayContains: userId) // ใช้ arrayContains แทน arrayContainsAny
          .limit(1)
          .get();

      return ref.docs.isNotEmpty;
    } catch (e) {
      print("Error whoLikeComment: $e");
      return false;
    }
  }

  static Future getMaxvalue() async {
    int? data;
    FirebaseFirestore.instance
        .collection('suggest_comment')
        .orderBy("a", descending: true)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        data = result.data()['a'];
      });
    });

    print(data ??= 0);
  }
}
