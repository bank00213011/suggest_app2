import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModelField {
  static final dateTime = 'dateTime';
}

class UserModel {
  final String user_id;
  final String email;
  final String password;
  final String name;
  final String social;
  final String tel;
  final String token;
  final String type;
  final String photo;
  //final DateTime dateTime;

  const UserModel({
    required this.user_id,
    required this.email,
    required this.name,
    required this.password,
    required this.social,
    required this.tel,
    required this.token,
    required this.type,
    required this.photo,
    //required this.dateTime
  });

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
        user_id: json['user_id'],
        email: json['email'],
        password: json['password'],
        name: json['name'],
        social: json['social'],
        tel: json['tel'],
        token: json['token'],
        type: json['type'],
        photo: json['photo'],
      );

  Map<String, dynamic> toJson() => {
        'user_id': user_id,
        'email': email,
        'password': password,
        'name': name,
        'social': social,
        'tel': tel,
        'token': token,
        'type': type,
        'photo': photo,
      };
}
