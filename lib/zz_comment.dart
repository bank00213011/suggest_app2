import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suggest/model/comment.dart';
import 'package:suggest/utils.dart';
import 'package:suggest/widget/comment_widget.dart';

class ZZComment extends StatefulWidget {
  @override
  _ZZ createState() => _ZZ();
}

class _ZZ extends State<ZZComment> {
  List<Map> test = [
    {"id": '1', "name": "ร้านอาหาร"},
    {"id": '2', "name": "สถานที่ท่องเที่ยว"}
  ];

  String? keyword = '';
  String Type = '';
  List sub = [];

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void popupMethod() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('⭐ กรุณาเลือก'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              RadioListTile(
                groupValue: Type,
                title: const Text('uqLTrAcw5VqUEookBBqP'),
                value: 'uqLTrAcw5VqUEookBBqP',
                onChanged: (String? val) {
                  setState(() {
                    Type = val!;
                    print(Type);
                    Navigator.of(context).pop(false);
                  });
                },
              ),
              RadioListTile(
                groupValue: Type,
                title: const Text('ยกเลิก'),
                value: '',
                onChanged: (String? val) {
                  setState(() {
                    Type = '';
                    print(Type);
                    Navigator.of(context).pop(false);
                  });
                },
              ),
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ZZ"),
      ),
      body: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search places,group or date',
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          setState(() {
                            keyword = val;
                          });
                        },
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                            onPressed: popupMethod,
                            icon: const Icon(Icons.filter_list)),
                        Type != ''
                            ? Positioned(
                                bottom: 15,
                                right: 15,
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  color: Colors.green,
                                ))
                            : Container()
                      ],
                    )
                  ],
                ),
              ),
              StreamBuilder<List<Comment>>(
                stream: Type != ''
                    ? FirebaseFirestore.instance
                        .collection('suggest_comment')
                        .where('place_id', isEqualTo: Type)
                        .orderBy(CommentField.dateTime, descending: true)
                        .snapshots()
                        .map((snapshot) => snapshot.docs
                            .map((doc) => Comment.fromJson(doc.data()))
                            .toList())
                    : FirebaseFirestore.instance
                        .collection('suggest_comment')
                        .orderBy(CommentField.dateTime, descending: true)
                        .snapshots()
                        .map((snapshot) => snapshot.docs
                            .map((doc) => Comment.fromJson(doc.data()))
                            .toList()),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.hasError) {
                        print(snapshot.hasError.toString());
                        return const Center(
                          child: Text(
                            'No Comment',
                            style: TextStyle(fontSize: 24),
                          ),
                        );
                      } else {
                        final comments = snapshot.data;
                        return comments!.isEmpty
                            ? const Center(
                                child: Text(
                                  'No Data',
                                  style: TextStyle(fontSize: 24),
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index];

                                  return Text('data');
                                  //CommentWidget(comment: comment);
                                },
                              );
                      }
                  }
                },
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: popupMethod,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), //
    );
  }
}
