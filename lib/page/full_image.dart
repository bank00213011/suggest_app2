import 'dart:io';

import 'package:flutter/material.dart';

class FullImage extends StatefulWidget {
  // รับค่า photo มาจากไฟล์ก่อน
  String photo;
  FullImage({Key? key, required this.photo}) : super(key: key);

  @override
  _FullImage createState() => _FullImage();
}

class _FullImage extends State<FullImage> {
  late String photo;

  @override // รัน initState ก่อน
  void initState() {
    super.initState();
    setState(() {
      photo = widget.photo;
    });
  }

  // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            // แสดงรูปภาพ
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 2,
              child: Image.network(
                photo,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 20.0,
          right: 20.0,
          child: IconButton(
            onPressed: () =>
                // กดย้อนกลับ
                Navigator.pop(context, false),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    ));
  }
}

class FullImage2 extends StatefulWidget {
  // รับค่า photo มาจากไฟล์ก่อน
  File photo;
  FullImage2({Key? key, required this.photo}) : super(key: key);

  @override
  _FullImage2 createState() => _FullImage2();
}

class _FullImage2 extends State<FullImage2> {
  // แสดง UI
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            // แสดงรูปภาพ
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 2,
              child: Image.file(
                widget.photo,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 20.0,
          right: 20.0,
          child: InkWell(
            onTap: () {
              // กดย้อนกลับ
              Navigator.pop(context, false);
            },
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    ));
  }
}
