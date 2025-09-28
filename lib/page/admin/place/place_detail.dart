import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suggest/main.dart';
import 'package:intl/intl.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/model/favorite.dart';
import 'package:suggest/model/comment.dart';
import 'package:suggest/model/place.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/admin/place/place_edit.dart';
import 'package:suggest/page/full_image.dart';
import 'package:suggest/page/user/rating/rating_add.dart';
import 'package:suggest/direction/map_direction.dart';

import 'package:suggest/widget/comment_widget.dart';
import 'package:suggest/widget/heart_animation_widget.dart';

class PlaceDetail extends StatefulWidget {
  final Place place;
  bool like;
  final UserModel my_account;

  PlaceDetail(
      {Key? key,
      required this.place,
      required this.like,
      required this.my_account})
      : super(key: key);
  @override
  _PlaceDetail createState() => _PlaceDetail();
}

class _PlaceDetail extends State<PlaceDetail> {
  final commentController = TextEditingController();
  bool? limitComment;
  List photoList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < widget.place.photo.length; i++) {
      photoList.add(widget.place.photo[i]);
    }
    checkLimit();
  }

  void checkLimit() async {
    final ref = await FirebaseFirestore.instance
        .collection('suggest_comment')
        .where('place_id', isEqualTo: widget.place.place_id)
        .get();
    int size = ref.size;
    setState(() {
      if (size == 0) {
        limitComment = false;
      } else if (size > 2) {
        limitComment = true;
      } else {
        limitComment = false;
      }
    });
    print(limitComment);
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.like ? Icons.favorite : Icons.favorite_outline;
    final color = widget.like ? Colors.red : Colors.white;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.place.name),
          actions: [
            widget.my_account.type == 'admin'
                ? GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => PlaceEdit(
                              place: widget.place,
                              my_account: widget.my_account),
                        )),
                    child: Center(
                      child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: const Text("แก้ไข")),
                    ))
                : Container()
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  buildSlidePhoto(),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          decoration: const BoxDecoration(color: Colors.green),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.place.name,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Row(
                                    children: [
                                      widget.my_account.type != 'admin'
                                          ? HeartAnimationWidget(
                                              alwaysAnimate: true,
                                              isAnimating: widget.like,
                                              child: IconButton(
                                                  onPressed: () => setState(() {
                                                        widget.like =
                                                            !widget.like;

                                                        widget.like
                                                            ? CloudFirestoreApi
                                                                .addFavoritePlace(
                                                                    widget.place
                                                                        .place_id,
                                                                    widget
                                                                        .my_account
                                                                        .user_id,
                                                                    'add')
                                                            : CloudFirestoreApi
                                                                .addFavoritePlace(
                                                                    widget.place
                                                                        .place_id,
                                                                    widget
                                                                        .my_account
                                                                        .user_id,
                                                                    'delete');
                                                      }),
                                                  icon: Icon(
                                                    icon,
                                                    color: color,
                                                    size: 28,
                                                  )),
                                            )
                                          : Container(),
                                      GestureDetector(
                                        child: const Icon(
                                          Icons.directions,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MapDirection(
                                                place: widget.place,
                                                my_account: widget.my_account,
                                              ),
                                            )),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Color.fromARGB(255, 201, 171, 5)),
                                  const SizedBox(width: 5),
                                  Text(
                                    'คะแนน (${widget.place.rating}/5)',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16.0),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.place,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      child: Text(widget.place.address,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0))),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 2),
                                  Flexible(
                                    child: Text(widget.place.day,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0)),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: const Text('รายละเอียด',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Text(
                            widget.place.detail,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Divider(),
                        ),
                        Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Comments ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                StreamBuilder<List<Comment>>(
                                  stream: limitComment == true
                                      ? FirebaseFirestore.instance
                                          .collection('suggest_comment')
                                          .where('place_id',
                                              isEqualTo: widget.place.place_id)
                                          .orderBy(CommentField.dateTime,
                                              descending: true)
                                          .limit(2)
                                          .snapshots()
                                          .map((snapshot) => snapshot.docs
                                              .map((doc) =>
                                                  Comment.fromJson(doc.data()))
                                              .toList())
                                      : FirebaseFirestore.instance
                                          .collection('suggest_comment')
                                          .where('place_id',
                                              isEqualTo: widget.place.place_id)
                                          .orderBy(CommentField.dateTime,
                                              descending: true)
                                          .snapshots()
                                          .map((snapshot) => snapshot.docs
                                              .map((doc) =>
                                                  Comment.fromJson(doc.data()))
                                              .toList()),
                                  builder: (context, snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      default:
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                              'ไม่มีความคิดเห็น',
                                              style: TextStyle(fontSize: 24),
                                            ),
                                          );
                                        } else {
                                          final comments = snapshot.data;

                                          return comments!.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    'ไม่มีความคิดเห็น',
                                                    style:
                                                        TextStyle(fontSize: 24),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: comments.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final comment =
                                                        comments[index];

                                                    return CommentWidget(
                                                        comment: comment,
                                                        place: widget.place,
                                                        my_account:
                                                            widget.my_account);
                                                  },
                                                );
                                        }
                                    }
                                  },
                                ),
                                limitComment == true
                                    ? GestureDetector(
                                        onTap: () => setState(() {
                                              limitComment = false;
                                            }),
                                        child: Center(
                                          child: Text(
                                            'โหลดความคิดเห็นเพิ่ม',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 18,
                                                decoration:
                                                    TextDecoration.underline,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ))
                                    : Container()
                              ],
                            )),
                        const SizedBox(height: 120)
                      ],
                    ),
                  )
                ],
              ),
            ),
            widget.my_account.type != 'admin'
                ? Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0))),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.purple),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RatingAdd(
                                place: widget.place,
                                my_account: widget.my_account),
                          ),
                        ),
                        child: const Text(
                          'แสดงความคิดเห็นและให้คะแนน',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )

                    // Container(
                    //   color: Colors.white,
                    //   padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //       onPressed: () => Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //               builder: (context) => RatingAdd(
                    //                   place: widget.place,
                    //                   my_account: widget.my_account),
                    //             ),
                    //           ),
                    //       child: Text('แสดงความคิดเห็นและให้คะแนน')),
                    // )
                  ])
                : Container(),
          ],
        ));
  }

  Widget buildSlidePhoto() => SizedBox(
      height: 250,
      child: CarouselSlider(
        items: photoList.map(
          (i) {
            //var index = photoList.indexOf(i);

            return Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImage(
                            photo: i,
                          ),
                        ));
                  },
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: i,
                      imageBuilder: (context, imageProvider) => Image.network(
                        i,
                        fit: BoxFit.cover,
                        height: double.infinity,
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: Palette.kToDark,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 10.0,
                    right: 10.0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                      decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Text(
                        '${photoList.indexOf(i) + 1}/${photoList.length.toString()}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
              ],
            );
          },
        ).toList(),
        options: CarouselOptions(
            onPageChanged: (index, reason) {},
            viewportFraction: 1,
            height: MediaQuery.of(context).size.height * 0.5),
      ));
}


// Container(
              //     color: Colors.white,
              //     padding: EdgeInsets.all(10),
              //     child: Column(
              //       children: [
              //         Text('ตอบกลับความเห็น'),
              //         Row(
              //           children: [
              //             CachedImageUser(
              //                 radius: 25, photo: widget.my_account.photo),
              //             SizedBox(
              //               width: 5,
              //             ),
              //             Expanded(
              //                 child: SizedBox(
              //                     height: 40,
              //                     child: TextFormField(
              //                       maxLines: 1,
              //                       controller: commentController,
              //                       textAlignVertical: TextAlignVertical.top,
              //                       textInputAction: TextInputAction.done,
              //                       decoration: InputDecoration(
              //                         border: OutlineInputBorder(),
              //                         labelText: 'Comment...',
              //                       ),
              //                       autovalidateMode: AutovalidateMode.always,
              //                       // validator: (String? value) {
              //                       //   return (value != null &&
              //                       //           value.contains('@'))
              //                       //       ? 'Do not use the @ char.'
              //                       //       : null;
              //                       // },
              //                     ))),
              //             SizedBox(
              //               width: 5,
              //             ),
              //             GestureDetector(
              //               onTap: () async {
              //                 FocusScope.of(context).unfocus();
              //                 print(commentController.text +
              //                     ' ' +
              //                     widget.my_account.name +
              //                     ' ' +
              //                     widget.my_account.photo);

              //                 // Map map = {
              //                 //   'comment': commentController.text,
              //                 //   'name': widget.my_account.name,
              //                 //   'photo': widget.my_account.photo,
              //                 //   'time': DateTime.now()
              //                 // };
              //                 // widget.comment.sub.add(map);
              //                 // await FirebaseFirestore.instance
              //                 //     .collection('suggest_comment')
              //                 //     .doc('YmOb2nCHPwsYm4qRGJJR')
              //                 //     .update({'sub': comment.sub});

              //                 commentController.text = '';
              //               },
              //               child: Icon(Icons.send, color: Colors.blue),
              //             ),
              //           ],
              //         ),
              //       ],
              //     ))