import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class CommentField {
  static const dateTime = 'dateTime';
}

class Comment {
  String comment;
  String comment_id;
  Timestamp dateTime;
  int like;
  String place_id;
  double rating;

  String user_id;
  List who_like;

  Comment({
    required this.comment,
    required this.comment_id,
    required this.dateTime,
    required this.like,
    required this.place_id,
    required this.rating,
    required this.user_id,
    required this.who_like,
  });

  static Comment fromJson(Map<String, dynamic> json) => Comment(
        comment: json['comment'],
        comment_id: json['comment_id'],
        dateTime: json['dateTime'],
        like: json['like'],
        place_id: json['place_id'],
        rating: json['rating'],
        user_id: json['user_id'],
        who_like: json['who_like'],
      );

  Map<String, dynamic> toJson() => {
        'comment': comment,
        'comment_id': comment_id,
        'dateTime': dateTime,
        'like': like,
        'place_id': place_id,
        'rating': rating,
        'user_id': user_id,
        'who_like': who_like,
      };
}
