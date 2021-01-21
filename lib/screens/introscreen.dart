import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:travel_the_globe/screens/globescreen.dart';
import 'package:travel_the_globe/screens/loginscreen.dart';
import 'package:travel_the_globe/utilities/constants/colors.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    user = null;
    return SplashScreen(
      navigateAfterSeconds: user != null ? GlobeScreen(userId: user.uid) : LoginScreen(),
      seconds: 2,
      title: Text(
        'Travel the Globe',
        style: new TextStyle(
            fontFamily: 'Goldman',
            fontWeight: FontWeight.w700,
            fontSize: 32.0,
            decoration: TextDecoration.underline,
            decorationColor: AppColorPalette.BabyBlue,
            decorationThickness: 2),
      ),
      image: Image.asset("assets/images/logo.png"),
      photoSize: 100,
      styleTextUnderTheLoader: TextStyle(),
      backgroundColor: AppColorPalette.DarkGrey,
      loaderColor: AppColorPalette.BabyBlue,
    );
  }
}
