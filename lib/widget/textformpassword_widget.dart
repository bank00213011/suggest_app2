import 'package:flutter/material.dart';

class TextFormPasswordWidget extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final bool hidePassword;
  final IconButton icon;

  const TextFormPasswordWidget({
    super.key,
    required this.text,
    required this.controller,
    required this.hidePassword,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: hidePassword,
      decoration: InputDecoration(
        labelText: text,
        labelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
        ),
        hintText: text,
        suffixIcon: icon,
        hintStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
        ),
        errorStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
          color: Color(0xFFFF5963),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0x6B57636C),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0x6B57636C),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFFF5963),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFFF5963),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      style: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      ),
      keyboardType: TextInputType.visiblePassword,
    );
  }
}
