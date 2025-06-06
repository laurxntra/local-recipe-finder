import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PositionProvider extends ChangeNotifier {
  double? _longitude;
  double? _latitude;
  bool _positionKnown = false;
  String? _positionError;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get positionKnown => _positionKnown;
  String? get positionError => _positionError;


  PositionProvider() {
    _startLocation();
  }

  Future<Position> _determinePosition() async {
    final bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _startLocation() {
    Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final Position position = await _determinePosition();
        _latitude = position.latitude;
        _longitude = position.longitude;
        _positionKnown = true;
        _positionError = null;
        notifyListeners();
      } catch (e) {
        _latitude = null;
        _longitude = null;
        _positionKnown = false;
        _positionError = e.toString();
        notifyListeners();
      }
    });
  }
}