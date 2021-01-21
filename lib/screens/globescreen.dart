import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_the_globe/utilities/constants/colors.dart';
import 'package:travel_the_globe/utilities/constants/globe_modes.dart';
import 'package:travel_the_globe/utilities/widgets/appbar_notched_bottom.dart';
import 'package:travel_the_globe/utilities/widgets/globe.dart';

class GlobeScreen extends StatefulWidget {
  final String userId;

  GlobeScreen({this.userId});

  @override
  _GlobeScreenState createState() => _GlobeScreenState();
}

class _GlobeScreenState extends State<GlobeScreen> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool get _travelButtonVisible => _isTravelButtonVisible();

  bool _isTravelButtonVisible() {
    if (_globeKey.currentState != null) if (_globeKey.currentState.pickedCountry != null) {
      if (_globeKey.currentState.pickedCountry.isNotEmpty) return true;
    }
    return false;
  }

  String _getTravelButtonText() {
    if (_globeKey.currentState != null) if (_globeKey.currentState.pickedCountry != null) {
      if (_globeKey.currentState.pickedCountry.isNotEmpty && _globeKey.currentState.globeMode != GlobeMode.TRAVELLING) return 'Travel!';
      if (_globeKey.currentState.globeMode == GlobeMode.TRAVELLING) return 'Finish!';
    }
    return '';
  }

  IconData _getTravelButtonIcon() {
    if (_globeKey.currentState != null) if (_globeKey.currentState.pickedCountry != null) {
      if (_globeKey.currentState.pickedCountry.isNotEmpty && _globeKey.currentState.globeMode != GlobeMode.TRAVELLING)
        return Icons.airplanemode_on_rounded;
      if (_globeKey.currentState.globeMode == GlobeMode.TRAVELLING) return Icons.exit_to_app;
    }
    return Icons.airplanemode_on_rounded;
  }

  GlobalKey<GlobeState> _globeKey = GlobalKey();
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
        child: Stack(children: [
          Center(
            child: Globe(
              key: _globeKey,
              callback: () => setState(() {}),
              userId: widget.userId,
              surface: "assets/images/map/map.png",
              countryCodesSurface: "assets/images/map/codes.png",
              latitude: 0,
              longitude: 0,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Visibility(
                visible: _globeKey.currentState?.globeMode == GlobeMode.ZOOMED_IN,
                child: IconButton(
                  onPressed: () => _globeKey.currentState?.zoomOut(),
                  icon: Icon(Icons.zoom_out_map),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Stack(children: [
                  Text(
                    _globeKey.currentState?.pickedCountry ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.0,
                      fontFamily: 'Goldman',
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3
                        ..color = AppColorPalette.BabyBlue,
                    ),
                  ),
                  Text(
                    _globeKey.currentState?.pickedCountry ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.0,
                      fontFamily: 'Goldman',
                    ),
                  )
                ]),
              ),
            ),
          ),
        ]),
      ),
      floatingActionButton: Visibility(
        visible: _travelButtonVisible,
        child: FloatingActionButton.extended(
          onPressed: _travelButtonVisible ? onTravelButtonPressed : null,
          backgroundColor: Colors.white,
          splashColor: AppColorPalette.BabyBlue,
          label: Text(_getTravelButtonText()),
          icon: Icon(_getTravelButtonIcon()),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NotchedBottomAppBar(
        color: Colors.grey[800],
        height: 50.0,
      ),
    );
  }

  Future<void> onTravelButtonPressed() async {
    switch (_globeKey.currentState.globeMode) {
      case GlobeMode.ZOOMED_IN:
        {
          _globeKey.currentState.travel();
          break;
        }
      case GlobeMode.TRAVELLING:
        {
          _globeKey.currentState.stopTravel();
          break;
        }
      default:
        break;
    }
  }
}
