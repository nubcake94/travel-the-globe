import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_the_globe/screens/introscreen.dart';

class LogoutButton extends StatelessWidget {
  final IconData iconData;

  LogoutButton({this.iconData});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData),
      onPressed: () => _logOut(context),
    );
  }

  void _logOut(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut().then((res) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => IntroScreen()), (Route<dynamic> route) => false);
    });
  }
}
