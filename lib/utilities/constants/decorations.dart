import 'package:flutter/material.dart';

InputDecoration inputDecoration(String text) {
  return InputDecoration(
    hintText: text,
    hintStyle: TextStyle(color: Colors.white24),
    fillColor: Colors.white10,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
      borderSide: BorderSide.none,
    ),
  );
}
