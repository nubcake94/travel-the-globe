import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:travel_the_globe/utilities/constants/continents.dart';
import 'package:travel_the_globe/utilities/constants/globe_modes.dart';
import 'package:tuple/tuple.dart';

class Globe extends StatefulWidget {
  final String surface;
  final double latitude;
  final double longitude;
  final Alignment alignment;

  Globe({Key key, this.surface, this.latitude, this.longitude, this.alignment = Alignment.center}) : super(key: key);

  @override
  _GlobeState createState() => _GlobeState();
}

class _GlobeState extends State<Globe> with TickerProviderStateMixin {
  Uint32List surface;
  GlobeMode _globeMode = GlobeMode.ZOOM_OUT;
  double surfaceWidth;
  double surfaceHeight;
  double rotationX = 0;
  double rotationZ = 0;
  double zoom = 0.0;
  final double _zoomIn = 4.0;
  double latitude = 0;
  double longitude = 0;
  double _lastRotationX = 0;
  double _lastRotationZ = 0;
  Offset _lastFocalPoint;
  Offset _origo;
  Offset _lastClickLocalPosition;
  AnimationController rotationZController;
  AnimationController rotationXController;
  AnimationController zoomController;
  Animation<double> rotationZAnimation;
  Animation<double> rotationXAnimation;
  Animation<double> zoomAnimation;
  double radius;
  double get zoomedRadius => radius * math.pow(2, zoom);

  List<Tuple2<Offset, double>> rayCast(Offset start) {
    List<Tuple2<Offset, double>> result = List();
    // (X - X0)^2 + (Y - Y0) ^2 + z^2 = r^2
    double positiveSquare = math.sqrt(math.pow(zoomedRadius, 2) - math.pow(start.dx, 2) - math.pow(start.dy, 2));
    if (positiveSquare.isNaN) {
      print('no hit result - input was $start');
      return result;
    } else if (positiveSquare == 0) {
      result.add(Tuple2(Offset(start.dx, start.dy), positiveSquare));
    } else {
      result.add(Tuple2(Offset(start.dx, start.dy), positiveSquare));
      result.add(Tuple2(Offset(start.dx, start.dy), -1.0 * positiveSquare));
    }
    return result;
  }

  Future<void> rotate(Offset offset) async {
    rotationXController.duration = Duration(milliseconds: 500);
    final endX = rotationX - offset.dy / zoomedRadius;
    rotationXAnimation = Tween<double>(begin: rotationX, end: endX.abs() >= 0.5 * math.pi ? endX.sign * 0.5 * math.pi : endX)
        .animate(CurveTween(curve: Curves.decelerate).animate(rotationXController));
    rotationXController
      ..value = 0
      ..forward();

    rotationZController.duration = Duration(milliseconds: 500);
    rotationZAnimation = Tween<double>(begin: rotationZ, end: rotationZ + offset.dx / zoomedRadius)
        .animate(CurveTween(curve: Curves.decelerate).animate(rotationZController));
    rotationZController
      ..value = 0
      ..forward().then((value) => rotationZ = rotationZ % (2 * math.pi));
  }

  Offset rotate_immediate(Offset offset) {
    var dx = _lastRotationX - offset.dy / zoomedRadius;
    dx = dx.abs() > 0.5 * math.pi ? dx.sign * 0.5 * math.pi : dx;
    var dy = _lastRotationZ + offset.dx / zoomedRadius;
    dy = dy % (2.0 * math.pi);
    return Offset(dx, dy);
  }

  void printState() {
    print("--- Globe state ---\n"
        "Origo : $_origo\n"
        "Radius : $radius\n"
        "Longitude : $longitude - Latitude : $latitude\n"
        "RotationZ : $rotationZ - RotationX : $rotationX\n"
        "LastClickLocalPosition : $_lastClickLocalPosition\n\n");
  }

  double getLatitude({double rX}) {
    return rX / math.pi * 180;
  }

  double getRotationX({double latitude}) {
    return latitude / 180 * math.pi;
  }

  double getLongitude({double rZ}) {
    return ((((10.5) / 180 * math.pi) + rZ - math.pi) % (math.pi * 2) / math.pi * 180) - 180;
  }

  double getRotationZ({double longitude}) {
    return (latitude - 10.5) / 180 * math.pi;
  }

  Future<SphereImage> buildSphere(double maxWidth, double maxHeight) {
    if (surface == null) return null;
    final r = zoomedRadius.roundToDouble();
    final minX = math.max(-r, (-1 - widget.alignment.x) * maxWidth / 2);
    final minY = math.max(-r, (-1 + widget.alignment.y) * maxHeight / 2);
    final maxX = math.min(r, (1 - widget.alignment.x) * maxWidth / 2);
    final maxY = math.min(r, (1 + widget.alignment.y) * maxHeight / 2);
    final width = maxX - minX;
    final height = maxY - minY;
    if (width <= 0 || height <= 0) return null;
    final sphere = Uint32List(width.toInt() * height.toInt());

    var angle = math.pi / 2 - rotationX;
    final sinx = math.sin(angle);
    final cosx = math.cos(angle);
    // angle = 0;
    // final siny = math.sin(angle);
    // final cosy = math.cos(angle);
    angle = rotationZ + math.pi / 2;
    final sinz = math.sin(angle);
    final cosz = math.cos(angle);

    final surfaceXRate = (surfaceWidth - 1) / (2.0 * math.pi);
    final surfaceYRate = (surfaceHeight - 1) / (math.pi);

    for (var y = minY; y < maxY; y++) {
      final sphereY = (height - y + minY - 1).toInt() * width;
      for (var x = minX; x < maxX; x++) {
        var z = r * r - x * x - y * y;
        if (z > 0) {
          z = math.sqrt(z);

          var x1 = x, y1 = y, z1 = z;
          double x2, y2, z2;
          //rotate around the X axis
          y2 = y1 * cosx - z1 * sinx;
          z2 = y1 * sinx + z1 * cosx;
          y1 = y2;
          z1 = z2;
          //rotate around the Y axis
          // x2 = x1 * cosy + z1 * siny;
          // z2 = -x1 * siny + z1 * cosy;
          // x1 = x2;
          // z1 = z2;
          //rotate around the Z axis
          x2 = x1 * cosz - y1 * sinz;
          y2 = x1 * sinz + y1 * cosz;
          x1 = x2;
          y1 = y2;

          final lat = math.asin(z1 / r);
          final lon = math.atan2(y1, x1);

          final x0 = (lon + math.pi) * surfaceXRate;
          final y0 = (math.pi / 2 - lat) * surfaceYRate;

          final color = surface[(y0.toInt() * surfaceWidth + x0).toInt()];
          sphere[(sphereY + x - minX).toInt()] = color;
        }
      }
    }

    final c = Completer<SphereImage>();
    ui.decodeImageFromPixels(sphere.buffer.asUint8List(), width.toInt(), height.toInt(), ui.PixelFormat.rgba8888, (image) {
      final sphereImage = SphereImage(
        image: image,
        radius: r,
        origin: Offset(-minX, -minY),
        offset: Offset((widget.alignment.x + 1) * maxWidth / 2, (widget.alignment.y + 1) * maxHeight / 2),
      );
      c.complete(sphereImage);
    });
    return c.future;
  }

  void loadSurface() {
    rootBundle.load(widget.surface).then((data) {
      ui.decodeImageFromList(data.buffer.asUint8List(), (image) {
        image.toByteData(format: ui.ImageByteFormat.rawRgba).then((pixels) {
          surface = pixels.buffer.asUint32List();
          surfaceWidth = image.width.toDouble();
          surfaceHeight = image.height.toDouble();
          setState(() {});
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    latitude = widget.latitude;
    longitude = widget.longitude;
    rotationX = (widget.latitude * math.pi / 180);
    rotationZ = ((widget.longitude - 10.5) * math.pi / 180) % (2 * math.pi);
    rotationZController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          rotationZ = rotationZAnimation.value;
        });
      });
    rotationXController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          rotationX = rotationXAnimation.value;
        });
      });
    zoomController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          zoom = zoomController.value;
        });
      });
    loadSurface();
    printState();
  }

  @override
  void dispose() {
    rotationZController.dispose();
    rotationXController.dispose();
    zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              radius = constraints.maxWidth * 0.5 - 1;
              _origo = Offset(constraints.maxWidth, constraints.maxHeight) * 0.5;
              return GestureDetector(
                onTapDown: (details) => onTapDown(details),
                onTap: () => {} /*onTap()*/,
                onDoubleTapDown: (details) => onDoubleTapDown(details),
                onDoubleTap: () => onDoubleTap(),
                onScaleStart: _globeMode == GlobeMode.ZOOM_OUT
                    ? (ScaleStartDetails details) => onScaleStart(details)
                    : (ScaleStartDetails details) {},
                onScaleUpdate: _globeMode == GlobeMode.ZOOM_OUT
                    ? (ScaleUpdateDetails details) => onScaleUpdate(details)
                    : (ScaleUpdateDetails details) {},
                onScaleEnd:
                    _globeMode == GlobeMode.ZOOM_OUT ? (ScaleEndDetails details) => onScaleEnd(details) : (ScaleEndDetails details) {},
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return FutureBuilder(
                      future: buildSphere(constraints.maxWidth, constraints.maxHeight),
                      builder: (BuildContext context, AsyncSnapshot<SphereImage> snapshot) {
                        return CustomPaint(
                          painter: SpherePainter(snapshot.data),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void onScaleStart(ScaleStartDetails details) {
    _lastRotationX = rotationX;
    _lastRotationZ = rotationZ;
    _lastFocalPoint = details.focalPoint;
    rotationZController.stop();
    rotationXController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final offset = details.focalPoint - _lastFocalPoint;
    rotationX = _lastRotationX + offset.dy / radius;
    if (rotationX >= 0.5 * math.pi) rotationX = 0.5 * math.pi;
    if (rotationX <= -0.5 * math.pi) rotationX = -0.5 * math.pi;
    rotationZ = _lastRotationZ - offset.dx / radius;
    rotationZ = rotationZ % (2 * math.pi);
    setState(() {});
  }

  void onScaleEnd(ScaleEndDetails details) {
    final a = -300;
    final vZ = details.velocity.pixelsPerSecond.dx * 0.3;
    final tZ = (vZ / a).abs() * 1000;
    final sZ = (vZ.sign * 0.5 * vZ * vZ / a) / radius;
    rotationZController.duration = Duration(milliseconds: tZ.toInt());
    rotationZAnimation =
        Tween<double>(begin: rotationZ, end: rotationZ + sZ).animate(CurveTween(curve: Curves.decelerate).animate(rotationZController));
    rotationZController
      ..value = 0
      ..forward().then((value) => rotationZ = rotationZ % (2 * math.pi));

    final vX = details.velocity.pixelsPerSecond.dy * 0.15;
    final tX = (vX / a / 2).abs() * 1000;
    final sX = (vX.sign * 0.5 * vX * vX / a) / radius;
    final endX = rotationX - sX;
    rotationXController.duration = Duration(milliseconds: tX.toInt());
    rotationXAnimation = Tween<double>(begin: rotationX, end: endX.abs() >= 0.5 * math.pi ? endX.sign * 0.5 * math.pi : endX)
        .animate(CurveTween(curve: Curves.decelerate).animate(rotationXController));
    rotationXController
      ..value = 0
      ..forward();
  }

  void onTapDown(TapDownDetails details) {
    _lastClickLocalPosition = details.localPosition;
    setState(() {});
  }

  void onDoubleTapDown(TapDownDetails details) {
    _lastClickLocalPosition = details.localPosition;
    setState(() {});
  }

  void onDoubleTap() async {
    final Offset clickedPoint = Offset(
      _lastClickLocalPosition.dx - _origo.dx,
      _lastClickLocalPosition.dy - _origo.dy,
    );

    var rayCastResult = rayCast(clickedPoint);
    if (rayCastResult.isEmpty) {
      return;
    }
    _lastRotationX = rotationX;
    _lastRotationZ = rotationZ;

    Offset clickedPointRotation = rotate_immediate(clickedPoint);
    double latitude = getLatitude(rX: clickedPointRotation.dx);
    double longitude = getLongitude(rZ: clickedPointRotation.dy);

    Continent pickedContinent = Continents.closest(latitude: latitude, longitude: longitude);

    rotate(clickedPoint).then((value) {
      if (_globeMode == GlobeMode.ZOOM_OUT) {
        setState(() {
          _globeMode = GlobeMode.ZOOM_IN;
        });
        zoomController.duration = Duration(milliseconds: 500);
        zoomAnimation = Tween<double>(begin: zoom, end: _zoomIn).animate(CurveTween(curve: Curves.decelerate).animate(zoomController));
        zoomController
          ..value = 0
          ..forward();
      }
    });

    //printState();

    /*List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    print(placemarks[0]);*/
  }
}

class SphereImage {
  SphereImage({this.image, this.radius, this.origin, this.offset});
  final ui.Image image;
  final double radius;
  final Offset origin;
  final Offset offset;
}

class SpherePainter extends CustomPainter {
  SpherePainter(this.sphereImage);
  final SphereImage sphereImage;

  @override
  void paint(Canvas canvas, Size size) {
    if (sphereImage == null) return;
    final paint = Paint();
    final rect = Rect.fromCircle(center: sphereImage.offset, radius: sphereImage.radius - 1);
    final path =
        Path.combine(PathOperation.intersect, Path()..addOval(rect), Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)));
    canvas.clipPath(path);
    canvas.drawImage(sphereImage.image, sphereImage.offset - sphereImage.origin, paint);

    final gradient = RadialGradient(
      center: Alignment.center,
      colors: [Colors.transparent, Colors.black.withOpacity(0.35), Colors.black.withOpacity(0.5)],
      stops: [0.1, 0.85, 1.0],
    );
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
