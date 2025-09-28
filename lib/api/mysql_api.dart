import 'dart:convert';
import 'package:suggest/constants/config.dart';
import 'package:http/http.dart' as http;

class MySQLApi {
  static Future getData(String path) async {
    final response = await http.get(Uri.parse("http://10.0.2.2:8080/suggest$path"));
    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future searchData(String path, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("http://10.0.2.2:8080/suggest$path"),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(data));

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future postData(String path, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("http://10.0.2.2:8080/suggest$path"),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(data));

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future updateData(String path, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("http://10.0.2.2:8080/suggest$path"),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(data));

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future deleteData(String path, Map<String, dynamic> data) async {
    final response = await http.delete(
        Uri.parse("http://10.0.2.2:8080/suggest$path"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data));

    if (response.statusCode == 200) {
      print(response.body);
      return true;
    } else {
      return false;
    }
  }

  static Future<List<String>> getBrandList() async {
    List<String> listData = [];

    final data = await getData('/brand');
    for (int i = 0; i < data.length; i++) {
      listData.add(data[i]['name']);
    }

    return listData;
  }

  static Future<List<String>> getCategoryList() async {
    List<String> listData = [];

    final data = await getData('/category');

    for (int i = 0; i < data.length; i++) {
      listData.add(data[i]['name']);
    }
    return listData;
  }

  static Future<List<String>> getSubCategoryList(String name) async {
    List<String> listData = [];

    final data = await postData('/subCategory', {"name": name});

    for (int i = 0; i < data.length; i++) {
      listData.add(data[i]['name']);
    }
    return listData;
  }
}
