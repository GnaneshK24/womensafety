import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

Future<List<LatLng>> getUnsafeZones() async {
  List<LatLng> unsafeZones = [];

  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('unsafe_zones').get();
    for (var doc in snapshot.docs) {
      double lat = doc['latitude'];
      double lon = doc['longitude'];
      unsafeZones.add(LatLng(lat, lon));
    }
  } catch (e) {
    print("Error fetching unsafe zones: $e");
  }

  return unsafeZones;
}
