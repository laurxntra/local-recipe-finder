import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// This class is a provider for managing the user's position.
/// It extends ChangeNotifier to notify listeners when the position changes.
/// It uses the Geolocator package to determine the current position.
/// Fields:
/// - _longitude: longitude of user
/// - _latitude: latitude of user
/// - _positionKnown: if position is known yet
/// - _positionError: error message when getting position
class PositionProvider extends ChangeNotifier {
  double? _longitude; // longitude of user
  double? _latitude; // latitude of user
  bool _positionKnown = false; // if position is known yet
  String? _positionError; // error message when getting position

  double? get latitude => _latitude; // getter for latitude
  double? get longitude => _longitude; // getter for longitude
  bool get positionKnown => _positionKnown; // getter for position known
  String? get positionError => _positionError; // getter for position error

  /// this is a constructor for the PositionProvider class tha gets the user's position
  /// It starts the location service to get the user's position.
  /// Parameters: N/A
  /// Returns: N/A
  PositionProvider() {
    _startLocation();
  }

  /// This function dettermines the user's current position using Geolocator.
  /// This function came from the Gelocator package documentation.
  /// Parameters: N/A
  /// Returns: A Future that resolves to the user's current Position.
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

  /// This function starts the location service to get the user's position.
  /// It notifies listeners when the position is known or if there is an error.
  /// Parameters: N/A
  /// Returns: N/A
  void _startLocation() {
    Timer(const Duration(seconds: 1), () async {
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
