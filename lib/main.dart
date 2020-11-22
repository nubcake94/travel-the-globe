import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_the_globe/screens/introscreen.dart';
import 'package:travel_the_globe/utilities/constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TravelTheGlobe());
}

class TravelTheGlobe extends StatelessWidget {
  final ThemeData theme = ThemeData.dark().copyWith(
    primaryColor: AppColorPalette.DarkGrey,
    scaffoldBackgroundColor: AppColorPalette.DarkGrey,
    accentColor: AppColorPalette.BabyBlue,
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: IntroScreen(),
    );
  }
}
