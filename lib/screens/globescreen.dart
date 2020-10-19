import 'package:flutter/material.dart';
import 'package:sphere/sphere.dart';

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
          child: Sphere(
            surface: 'assets/images/world.png',
            radius: 150,
            latitude: 0,
            longitude: 0,
          ),
        ),
      ),
    );
  }
}
