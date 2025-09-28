import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FavoriteField {
  static const dateTime = 'dateTime';
}

class Favorite {
  String favorite_id;
  String place_id;
  String user_id;
  Timestamp dateTime;

  Favorite({
    required this.favorite_id,
    required this.place_id,
    required this.user_id,
    required this.dateTime,
  });

  static Favorite fromJson(Map<String, dynamic> json) => Favorite(
        favorite_id: json['favorite_id'],
        place_id: json['place_id'],
        user_id: json['user_id'],
        dateTime: json['dateTime'],
      );

  Map<String, dynamic> toJson() => {
        'favorite_id': favorite_id,
        'place_id': place_id,
        'user_id': user_id,
        'dateTime': dateTime,
      };
}
