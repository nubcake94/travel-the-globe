import 'package:flutter/material.dart';

InputDecoration inputDecoration({String hintText = '', Color fillColor = Colors.white}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.black26),
    fillColor: fillColor,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
      borderSide: BorderSide.none,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
      borderSide: BorderSide.none,
    ),
  );
}
