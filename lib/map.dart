import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:womensafety/services/route_service.dart'; // Import RouteService

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  RouteService routeService = RouteService();
  List<LatLng> routeCoordinates = [];
  LatLng? currentLocation;
  LatLng? destination;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> fetchRoute() async {
    if (currentLocation == null || destination == null) return;
    try {
      List<LatLng> coordinates = await routeService.getRoute(
          currentLocation!.latitude,
          currentLocation!.longitude,
          destination!.latitude,
          destination!.longitude);
      setState(() {
        routeCoordinates = coordinates;
      });
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map Screen")),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(
          initialCenter: currentLocation!,
          initialZoom: 13,
          onTap: (tapPosition, point) {
            setState(() {
              destination = point;
            });
            fetchRoute();
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          // Show current location marker
          MarkerLayer(
            markers: [
              Marker(
                point: currentLocation!,
                width: 50.0,
                height: 50.0,
                child: Icon(Icons.person_pin, color: Colors.blue, size: 40),
              ),
              if (destination != null)
                Marker(
                  point: destination!,
                  width: 50.0,
                  height: 50.0,
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
            ],
          ),
          // Draw polyline if route exists
          if (routeCoordinates.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routeCoordinates,
                  color: Colors.blue,
                  strokeWidth: 4.0,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
