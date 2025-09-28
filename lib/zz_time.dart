import 'package:flutter/material.dart';
import 'package:suggest/api/cloudfirestore_api.dart';
import 'package:suggest/utils.dart';

class ZZTime extends StatefulWidget {
  @override
  State<ZZTime> createState() => _ZZTime();
}

class _ZZTime extends State<ZZTime> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ZZ"),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Column(children: [
            // ElevatedButton(
            //     onPressed: () async => print(
            //         await CloudFirestoreApi.whoLikeComment(
            //             'VzpxQzgLmjSEC9ON0AqOUzKsSHh2')),
            //     child: Text('Test'))
          ]),
        ));
  }
}
