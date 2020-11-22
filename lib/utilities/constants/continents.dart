import 'dart:math';

import 'package:flutter/material.dart';

class Continents {
  Continents._();

  static final Continent NorthAmerica = Continent("North America", longitude: -82, latitude: 57);
  static final Continent SouthAmerica = Continent("South America", longitude: -58, latitude: -15);
  static final Continent Europe = Continent("Europe", longitude: 25, latitude: 50);
  static final Continent Africa = Continent("Africa", longitude: 24, latitude: 7);
  static final Continent Asia = Continent("Asia", longitude: 91, latitude: 47);
  static final Continent Australia = Continent("Australia", longitude: 137, latitude: -25);
  static final Continent Antarctica = Continent("Antarctica", longitude: 0, latitude: -90);

  static List<Continent> allContinents() {
    return [NorthAmerica, SouthAmerica, Europe, Africa, Asia, Australia, Antarctica];
  }

  static Continent closest({double latitude, double longitude}) {
    // TODO make more accurate
    Continent result;
    double diffResult = double.infinity;
    for (Continent continent in allContinents()) {
      double diff = sqrt(pow(continent.latitude - latitude, 2) + pow(continent.longitude - longitude, 2));
      if (diff < diffResult) {
        diffResult = diff;
        result = continent;
      }
    }
    return result;
  }
}

class Continent {
  final String name;
  final double longitude;
  final double latitude;
  Continent(this.name, {@required this.longitude, @required this.latitude});
}
