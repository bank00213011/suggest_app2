import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/api/firestorage_api.dart';
import 'package:suggest/api/mysql_api.dart';

import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/place/place_detail.dart';
import 'package:suggest/page/admin/place/place_edit.dart';

class PlaceWidget extends StatelessWidget {
  final Place place;
  final UserModel my_account;

  const PlaceWidget({Key? key, required this.place, required this.my_account})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      width: 260,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
              onTap: () async {
                bool like = await CloudFirestoreApi.checkLikePlace(
                    place.place_id, my_account.user_id);

                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => PlaceDetail(
                          place: place, like: like, my_account: my_account)),
                );
              },
              onLongPress: () => my_account.user_id == place.user_id
                  ? editDeleteMethod(context, place, my_account)
                  : print('object'),
              child: Card(
                child: Column(
                  children: [
                    if (place.photo.length != 0)
                      CachedNetworkImage(
                          imageUrl: place.photo[0],
                          imageBuilder: (context, imageProvider) =>
                              Image.network(
                                place.photo[0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150,
                              ),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image.asset(
                                'assets/no_image.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150,
                              )),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  place.name,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Color.fromARGB(255, 201, 171, 5)),
                                  Text(' (${place.rating}/5)'),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Text(
                                  place.address,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 201, 171, 5)),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.calendar_month),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Text(
                                  place.day,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 201, 171, 5)),
                                ),
                              )
                            ],
                          ),
                          Divider(),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('suggest_user')
                                .doc(place.user_id)
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError &&
                                  (snapshot.hasData &&
                                      !snapshot.data!.exists)) {
                                return const Text("");
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                Map<String, dynamic> data = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('by ${data['name']}'),
                                  ],
                                );
                              }

                              return const Text("");
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))));
}

editDeleteMethod(
    BuildContext context, Place place, UserModel my_account) async {
  return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text(
            '⭐ กรุณาเลือกรายการ',
            style: TextStyle(fontSize: 18),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          PlaceEdit(place: place, my_account: my_account),
                    ));
              },
              child: const Text(
                'แก้ไขสถานที่',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.of(context).pop(false);
                await FirebaseFirestore.instance
                    .collection('suggest_place')
                    .doc(place.place_id)
                    .delete()
                    .whenComplete(() async {
                  for (final photoUrl in place.photo) {
                    await FireStorageApi.removePhoto(photoUrl);
                  }
                });

                if (Platform.isAndroid) {
                  final deviceInfo = DeviceInfoPlugin();
                  final androidInfo = await deviceInfo.androidInfo;

                  final isEmulator = androidInfo.isPhysicalDevice == false;
                  if (isEmulator) {
                    await MySQLApi.deleteData(
                        '/place/', {'place_id': place.place_id});
                  }
                }
              },
              child: const Text(
                'ลบสถานที่',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      });
}
