import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String LAST_KNOWN_LAT_KEY = 'last_known_latitude';
  static const String LAST_KNOWN_LNG_KEY = 'last_known_longitude';
  static const String LAST_UPDATE_TIME_KEY = 'last_location_update_time';

  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _lastKnownPosition;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load last known position from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final lastLat = prefs.getDouble(LAST_KNOWN_LAT_KEY);
      final lastLng = prefs.getDouble(LAST_KNOWN_LNG_KEY);
      final lastUpdateTime = prefs.getInt(LAST_UPDATE_TIME_KEY);

      if (lastLat != null && lastLng != null && lastUpdateTime != null) {
        _lastKnownPosition = Position(
          latitude: lastLat,
          longitude: lastLng,
          timestamp: DateTime.fromMillisecondsSinceEpoch(lastUpdateTime),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }

      _isInitialized = true;
    } catch (e) {
      print('Error initializing LocationService: $e');
    }
  }

  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _saveLastKnownPosition(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(LAST_KNOWN_LAT_KEY, position.latitude);
      await prefs.setDouble(LAST_KNOWN_LNG_KEY, position.longitude);
      await prefs.setInt(LAST_UPDATE_TIME_KEY, position.timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error saving last known position: $e');
    }
  }

  Future<Position?> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 5),
    bool useLastKnownLocation = true,
  }) async {
    if (!await _checkPermissions()) {
      return null;
    }

    try {
      // First, try to get a quick fix with reduced accuracy
      Position? quickPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.reduced,
        timeLimit: const Duration(seconds: 2),
      ).catchError((e) => null);

      if (quickPosition != null) {
        _lastKnownPosition = quickPosition;
        await _saveLastKnownPosition(quickPosition);
        return quickPosition;
      }

      // If quick fix fails, try with desired accuracy
      Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy,
        timeLimit: timeout,
      ).catchError((e) => null);

      if (position != null) {
        _lastKnownPosition = position;
        await _saveLastKnownPosition(position);
        return position;
      }

      // If both attempts fail and useLastKnownLocation is true, return last known position
      if (useLastKnownLocation && _lastKnownPosition != null) {
        return _lastKnownPosition;
      }

      return null;
    } catch (e) {
      print('Error getting current position: $e');
      if (useLastKnownLocation && _lastKnownPosition != null) {
        return _lastKnownPosition;
      }
      return null;
    }
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        _lastKnownPosition = lastPosition;
        await _saveLastKnownPosition(lastPosition);
      }
      return lastPosition ?? _lastKnownPosition;
    } catch (e) {
      print('Error getting last known position: $e');
      return _lastKnownPosition;
    }
  }

  Stream<Position> getPositionStream({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    int intervalInSeconds = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: desiredAccuracy,
        distanceFilter: 10, // Minimum distance (in meters) before a new position is emitted
        timeLimit: Duration(seconds: intervalInSeconds),
      ),
    ).map((position) {
      _lastKnownPosition = position;
      _saveLastKnownPosition(position);
      return position;
    });
  }

  LatLng? positionToLatLng(Position? position) {
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }
} 