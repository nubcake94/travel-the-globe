import 'package:flutter/material.dart';
import 'package:travel_the_globe/utilities/widgets/globe.dart';

class GlobeScreen extends StatefulWidget {
  @override
  _GlobeScreenState createState() => _GlobeScreenState();
}

class _GlobeScreenState extends State<GlobeScreen> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Globe(
            surface: "assets/images/map/map1.png",
            latitude: 0,
            longitude: 0,
          ),
        ),
      ),
    );
  }
}
