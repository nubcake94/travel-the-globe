import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:travel_the_globe/screens/globescreen.dart';
import 'package:travel_the_globe/screens/introscreen.dart';
import 'package:travel_the_globe/screens/registerscreen.dart';
import 'package:travel_the_globe/utilities/constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TravelTheGlobe());
}

class TravelTheGlobe extends StatelessWidget {
  ThemeData theme = ThemeData.dark().copyWith(
    primaryColor: AppColorPalette.DeepKoamaru,
    scaffoldBackgroundColor: AppColorPalette.DeepKoamaru,
    accentColor: AppColorPalette.Ceil,
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
