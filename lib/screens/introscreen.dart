import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:travel_the_globe/screens/globescreen.dart';
import 'package:travel_the_globe/screens/loginscreen.dart';
import 'package:travel_the_globe/screens/registerscreen.dart';
import 'package:travel_the_globe/utilities/constants/colors.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    //User user = null; // for debugging only
    return SplashScreen(
      navigateAfterSeconds: user != null ? GlobeScreen(/*uid: user.uid*/) : LoginScreen(),
      seconds: 1,
      title: Text(
        'Welcome to my thesis!',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      styleTextUnderTheLoader: TextStyle(),
      backgroundColor: AppColorPalette.DeepKoamaru,
      loaderColor: AppColorPalette.Ceil,
    );
  }
}
