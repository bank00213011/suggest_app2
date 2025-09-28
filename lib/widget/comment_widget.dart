import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/api/mysql_api.dart';
import 'package:suggest/model/comment.dart';
import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/utils.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final Place place;
  final UserModel my_account;

  CommentWidget(
      {Key? key,
      required this.comment,
      required this.place,
      required this.my_account});

  @override
  _CommentWidget createState() => _CommentWidget();
}

class _CommentWidget extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('suggest_user')
              .doc(widget.comment.user_id)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              final user = UserModel(
                user_id: data['user_id'],
                email: data['email'],
                name: data['name'],
                password: data['password'],
                tel: data['tel'],
                token: data['token'],
                type: data['type'],
                social: data['social'],
                photo: data['photo'],
              );

              return ListTile(
                onLongPress: () =>
                    deleteComment(context, widget.comment, widget.place),
                leading: user.photo == ''
                    ? CircleAvatar(
                        radius: 25,
                        child: Text(
                          user.name.substring(0, 1),
                          style: const TextStyle(fontSize: 25),
                        ),
                      )
                    : CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(user.photo),
                      ),
                title: Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.star,
                        color: Color.fromARGB(255, 201, 171, 5)),
                    Text(
                      ' (${widget.comment.rating}/5)',
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.comment.comment),
                    Row(
                      children: [
                        Text(
                          Utils.differenceTime(
                              widget.comment.dateTime.toDate()),
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        FutureBuilder<bool>(
                          future: CloudFirestoreApi.whoLikeComment(
                              widget.comment.comment_id,
                              widget.my_account.user_id),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            if (snapshot.hasError) {
                              return const Text("");
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              // Map<String, dynamic> data =
                              //     snapshot.data! as Map<String, dynamic>;
                              bool like = snapshot.data!;

                              return Row(
                                children: [
                                  like
                                      ? Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 18,
                                        )
                                      : Icon(
                                          Icons.favorite_outline,
                                          size: 18,
                                        ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  widget.comment.like == 0
                                      ? Text('')
                                      : Text(
                                          widget.comment.like.toString(),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  snapshot.data!
                                      ? GestureDetector(
                                          onTap: () async {
                                            widget.comment.who_like.removeWhere(
                                                (item) =>
                                                    item ==
                                                    widget.my_account.user_id);

                                            await FirebaseFirestore.instance
                                                .collection('suggest_comment')
                                                .doc(widget.comment.comment_id)
                                                .update({
                                              'like': widget.comment.like - 1,
                                              'who_like':
                                                  widget.comment.who_like
                                            });

                                            if (Platform.isAndroid) {
                                              final deviceInfo =
                                                  DeviceInfoPlugin();
                                              final androidInfo =
                                                  await deviceInfo.androidInfo;

                                              final isEmulator = androidInfo
                                                      .isPhysicalDevice ==
                                                  false;
                                              if (isEmulator) {
                                                await MySQLApi.updateData(
                                                    '/comment/', {
                                                  'comment_id':
                                                      widget.comment.comment_id,
                                                  'like':
                                                      widget.comment.like - 1,
                                                  'who_like': widget
                                                      .comment.who_like
                                                      .toString()
                                                });
                                              }
                                            }
                                          },
                                          child: Text('ยกเลิก'),
                                        )
                                      : GestureDetector(
                                          onTap: () async {
                                            // widget.comment.who_like
                                            //     .add(widget.my_account.user_id);

                                            setState(() {});

                                            widget.comment.who_like
                                                .add(widget.my_account.user_id);
                                            await FirebaseFirestore.instance
                                                .collection('suggest_comment')
                                                .doc(widget.comment.comment_id)
                                                .update({
                                              'like': widget.comment.like + 1,
                                              'who_like':
                                                  widget.comment.who_like
                                            });
                                            if (Platform.isAndroid) {
                                              final deviceInfo =
                                                  DeviceInfoPlugin();
                                              final androidInfo =
                                                  await deviceInfo.androidInfo;

                                              final isEmulator = androidInfo
                                                      .isPhysicalDevice ==
                                                  false;
                                              if (isEmulator) {
                                                await MySQLApi.updateData(
                                                    '/comment/', {
                                                  'comment_id':
                                                      widget.comment.comment_id,
                                                  'like':
                                                      widget.comment.like + 1,
                                                  'who_like': widget
                                                      .comment.who_like
                                                      .toString()
                                                });
                                              }
                                            }
                                          },
                                          child: Text('ถูกใจ'),
                                        ),
                                ],
                              );
                            }

                            return const Text("");
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const Text("");
          },
        ),
        Divider()
      ],
    );
  }
}

Future deleteComment(BuildContext context, Comment comment, Place place) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('⭐ แจ้งเตือน'),
        content: const Text('คุณต้องการลบคอมเม้น ใช่หรือไม่?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ไม่ใช่'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await FirebaseFirestore.instance
                  .collection('suggest_comment')
                  .doc(comment.comment_id)
                  .delete()
                  .whenComplete(() => null);
              if (Platform.isAndroid) {
                final deviceInfo = DeviceInfoPlugin();
                final androidInfo = await deviceInfo.androidInfo;

                final isEmulator = androidInfo.isPhysicalDevice == false;
                if (isEmulator) {
                  await MySQLApi.deleteData(
                      '/comment/', {'comment_id': comment.comment_id});
                }
              }

              await CloudFirestoreApi.setAverageRating(place)
                  .whenComplete(() => print('Deleted Comment'));
            },
            child: const Text('ใช่'),
          ),
        ],
      );
    },
  );
}
