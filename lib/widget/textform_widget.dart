import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;
  final String text;
  final TextInputType type;
  final List<TextInputFormatter> inputFormat;

  const TextFormWidget(
      {super.key,
      required this.text,
      required this.controller,
      required this.readOnly,
      required this.type,
      required this.inputFormat});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: false,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: text,
        labelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
        ),
        suffixIcon: controller.text.isEmpty
            ? Container(width: 0)
            : IconButton(
                color: Color(0x6B57636C),
                icon: const Icon(Icons.close),
                onPressed: () => controller.clear(),
              ),
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
      keyboardType: type,
      inputFormatters: inputFormat,
    );
  }
}
