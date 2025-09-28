import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/main.dart';
import 'package:suggest/model/board.dart';
import 'package:suggest/model/user_model.dart';
import 'package:suggest/page/board/board_edit.dart';
import 'package:suggest/page/full_image.dart';
import 'package:suggest/page/user/rating/rating_add.dart';
import 'package:suggest/direction/map_direction.dart';

import 'package:suggest/widget/comment_widget.dart';
import 'package:suggest/widget/heart_animation_widget.dart';

class BoardDetail extends StatefulWidget {
  final Board board;
  final UserModel my_account;

  BoardDetail({Key? key, required this.board, required this.my_account})
      : super(key: key);
  @override
  _BoardDetail createState() => _BoardDetail();
}

class _BoardDetail extends State<BoardDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("กระทู้"),
          actions: [
            widget.my_account.user_id == widget.board.user_id
                ? widget.my_account.type != 'admin'
                    ? GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => BoardEdit(
                                  board: widget.board,
                                  my_account: widget.my_account),
                            )),
                        child: Center(
                          child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: const Text("แก้ไข")),
                        ))
                    : Container()
                : Container()
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // GestureDetector(
                  //   onTap: () => Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => FullImage(
                  //           photo: board.photo,
                  //         ),
                  //       )),
                  //   child: Center(
                  //     child: Builder(
                  //       builder: (BuildContext context) => CachedNetworkImage(
                  //           imageUrl: board.photo,
                  //           imageBuilder: (context, imageProvider) =>
                  //               Image.network(
                  //                 board.photo,
                  //                 fit: BoxFit.cover,
                  //                 width: double.infinity,
                  //                 height: 200,
                  //               ),
                  //           placeholder: (context, url) =>
                  //               const CircularProgressIndicator(),
                  //           errorWidget: (context, url, error) => Image.asset(
                  //                 'assets/no_image.jpg',
                  //                 fit: BoxFit.cover,
                  //                 width: double.infinity,
                  //                 height: 150,
                  //               )),
                  //     ),
                  //   ),
                  // ),
                  buildSlidePhoto(),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Text(widget.board.title,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            "หมวดหมู่ : สถานที่ออกกำลังกาย",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: const Divider(),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Text(
                            widget.board.body,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }

  Widget buildSlidePhoto() => SizedBox(
      height: 250,
      child: CarouselSlider(
        items: widget.board.photo.map(
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
                        '${widget.board.photo.indexOf(i) + 1}/${widget.board.photo.length.toString()}',
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
