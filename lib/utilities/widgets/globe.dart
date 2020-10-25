import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tuple/tuple.dart';

// ignore: must_be_immutable
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
  double surfaceWidth;
  double surfaceHeight;
  double rotationX = 0;
  double rotationZ = 0;
  double _lastRotationX = 0;
  double _lastRotationZ = 0;
  Offset _lastFocalPoint;
  Offset _origo;
  Offset _lastClickLocalPosition;
  AnimationController rotationZController;
  Animation<double> rotationZAnimation;
  double radius;

  List<Tuple2<Offset, double>> rayCast(Offset start) {
    List<Tuple2<Offset, double>> result = List();
    // (X - X0)^2 + (Y - Y0) ^2 + z^2 = r^2
    double positiveSquare = math.sqrt(math.pow(radius, 2) - math.pow(start.dx, 2) - math.pow(start.dy, 2));
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

  void rotate(Offset offset) {
    rotationX -= offset.dy / radius;
    rotationZ += offset.dx / radius;
    setState(() {});
  }

  Future<SphereImage> buildSphere(double maxWidth, double maxHeight) {
    if (surface == null) return null;
    final r = radius.roundToDouble();
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
    rotationX = widget.latitude * math.pi / 180;
    rotationZ = widget.longitude * math.pi / 180;
    rotationZController = AnimationController(vsync: this)
      ..addListener(() {
        setState(() => rotationZ = rotationZAnimation.value);
      });
    loadSurface();
  }

  @override
  void dispose() {
    rotationZController.dispose();
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
                onTap: () => onTap(),
                onDoubleTapDown: (details) => onDoubleTapDown(details),
                onDoubleTap: () => onDoubleTap(),
                onScaleStart: (ScaleStartDetails details) => onScaleStart(details),
                onScaleUpdate: (ScaleUpdateDetails details) => onScaleUpdate(details),
                onScaleEnd: (ScaleEndDetails details) => onScaleEnd(details),
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
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final offset = details.focalPoint - _lastFocalPoint;
    rotationX = _lastRotationX + offset.dy / radius;
    rotationZ = _lastRotationZ - offset.dx / radius;
    setState(() {});
  }

  void onScaleEnd(ScaleEndDetails details) {
    final a = -300;
    final v = details.velocity.pixelsPerSecond.dx * 0.3;
    final t = (v / a).abs() * 1000;
    final s = (v.sign * 0.5 * v * v / a) / radius;
    rotationZController.duration = Duration(milliseconds: t.toInt());
    rotationZAnimation =
        Tween<double>(begin: rotationZ, end: rotationZ + s).animate(CurveTween(curve: Curves.decelerate).animate(rotationZController));
    rotationZController
      ..value = 0
      ..forward();
  }

  void onTapDown(TapDownDetails details) {
    _lastClickLocalPosition = details.localPosition;
    setState(() {});
    print('onTapDown fired $_lastClickLocalPosition');
  }

  void onTap() {
    print('onTap fired  $_lastClickLocalPosition');
    final Offset clickedPoint = Offset(
      _lastClickLocalPosition.dx - _origo.dx,
      _lastClickLocalPosition.dy - _origo.dy,
    );
    print(rayCast(clickedPoint));
  }

  void onDoubleTapDown(TapDownDetails details) {
    _lastClickLocalPosition = details.localPosition;
    setState(() {});
    print('onDoubleTapDown fired $_lastClickLocalPosition');
  }

  void onDoubleTap() {
    print('onDoubleTap fired  $_lastClickLocalPosition');
    final Offset clickedPoint = Offset(
      _lastClickLocalPosition.dx - _origo.dx,
      _lastClickLocalPosition.dy - _origo.dy,
    );
    var rayCastResult = rayCast(clickedPoint);
    if (rayCastResult.isEmpty) {
      return;
    }
    double z = rayCastResult[0].item2;
    rotate(clickedPoint);
    print(z);
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
