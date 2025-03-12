import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  Future<LatLng> getCoordinates(String location) async {
    final String apiKey = "YOUR_GOOGLE_API_KEY"; // Replace with your API key
    final String url = "https://maps.googleapis.com/maps/api/geocode/json?address=$location&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      double lat = data['results'][0]['geometry']['location']['lat'];
      double lng = data['results'][0]['geometry']['location']['lng'];
      return LatLng(lat, lng);
    } else {
      throw Exception("Failed to get coordinates for $location");
    }
  }
}
