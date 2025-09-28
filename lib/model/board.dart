import 'package:flutter/cupertino.dart';

class BoardField {
  static const dateTime = 'dateTime';
}

class Board {
  String board_id;
  String body;
  String category;
  String title;
  List photo;
  String user_id;

  Board({
    required this.board_id,
    required this.body,
    required this.category,
    required this.title,
    required this.photo,
    required this.user_id,
  });

  static Board fromJson(Map<String, dynamic> json) => Board(
        board_id: json['board_id'],
        body: json['body'],
        category: json['category'],
        title: json['title'],
        photo: json['photo'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        'board_id': board_id,
        'body': body,
        'category': category,
        'title': title,
        'photo': photo,
        'user_id': user_id,
      };
}
