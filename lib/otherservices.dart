import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherServicesWidget extends StatelessWidget {
  // Function to make phone calls
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildEmergencyButton(context, icon: Icons.local_hospital, label: "Ambulance", phoneNumber: "102"),
          _buildEmergencyButton(context, icon: Icons.fire_truck, label: "Fire Service", phoneNumber: "101"),
          _buildEmergencyButton(context, icon: Icons.child_care, label: "Child Care", phoneNumber: "1098"),
          _buildEmergencyButton(context, icon: Icons.local_police, label: "Police", phoneNumber: "100"),
          _buildEmergencyButton(context, icon: Icons.woman, label: "Women’s Helpline", phoneNumber: "1091"),
          _buildEmergencyButton(context, icon: Icons.family_restroom, label: "Domestic Abuse Helpline", phoneNumber: "181"),
          _buildEmergencyButton(context, icon: Icons.security, label: "Cyber Crime Helpline", phoneNumber: "1930"),
          _buildEmergencyButton(context, icon: Icons.train, label: "Railway Helpline", phoneNumber: "139"),
          _buildEmergencyButton(context, icon: Icons.elderly, label: "Senior Citizen Helpline", phoneNumber: "14567"),
          _buildEmergencyButton(context, icon: Icons.shield, label: "Nirbhaya Helpline", phoneNumber: "7827170170"),
        ],
      ),
    );
  }

  // Helper function to build an emergency button
  Widget _buildEmergencyButton(BuildContext context, {required IconData icon, required String label, required String phoneNumber}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent.withOpacity(0.8),
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () => _makePhoneCall(phoneNumber),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}
