import 'package:flutter/cupertino.dart';

class CategoryField {
  static const dateTime = 'dateTime';
}

class Category {
  String id;
  String name;
  String photo;

  Category({
    required this.id,
    required this.name,
    required this.photo,
  });

  static Category fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        photo: json['photo'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photo': photo,
      };
}
