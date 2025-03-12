import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  Future<List<LatLng>> getRoute(double startLat, double startLon, double endLat, double endLon) async {
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['routes'].isEmpty) {
        throw Exception("No route found");
      }

      print("OSRM API Response: $data"); // Debugging print

      final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

      return coordinates.map((coord) {
        print("Raw Coord: $coord"); // Debugging print to check data
        return LatLng(
            double.tryParse(coord[1].toString()) ?? 0.0, // Convert safely
            double.tryParse(coord[0].toString()) ?? 0.0
        );
      }).toList();
    } else {
      throw Exception("Failed to fetch route: ${response.statusCode}");
    }
  }
}
