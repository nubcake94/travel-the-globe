import 'package:flutter/material.dart';
import 'package:travel_the_globe/screens/globescreen.dart';

void main() => runApp(TravelTheGlobe());

class TravelTheGlobe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: GlobeScreen(),
    );
  }
}
