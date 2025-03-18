import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildEmergencyButton(context, icon: Icons.local_hospital, label: l10n.ambulance, phoneNumber: "102"),
          _buildEmergencyButton(context, icon: Icons.fire_truck, label: l10n.fireService, phoneNumber: "101"),
          _buildEmergencyButton(context, icon: Icons.child_care, label: l10n.childCare, phoneNumber: "1098"),
          _buildEmergencyButton(context, icon: Icons.local_police, label: l10n.police, phoneNumber: "100"),
          _buildEmergencyButton(context, icon: Icons.woman, label: l10n.womensHelpline, phoneNumber: "1091"),
          _buildEmergencyButton(context, icon: Icons.family_restroom, label: l10n.domesticAbuseHelpline, phoneNumber: "181"),
          _buildEmergencyButton(context, icon: Icons.security, label: l10n.cyberCrimeHelpline, phoneNumber: "1930"),
          _buildEmergencyButton(context, icon: Icons.train, label: l10n.railwayHelpline, phoneNumber: "139"),
          _buildEmergencyButton(context, icon: Icons.elderly, label: l10n.seniorCitizenHelpline, phoneNumber: "14567"),
          _buildEmergencyButton(context, icon: Icons.shield, label: l10n.nirbhayaHelpline, phoneNumber: "7827170170"),
        ],
      ),
    );
  }

  // Helper function to build an emergency button
  Widget _buildEmergencyButton(BuildContext context, {required IconData icon, required String label, required String phoneNumber}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.pinkAccent.withOpacity(0.8) : Colors.pinkAccent.withOpacity(0.8),
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
      ),
      onPressed: () => _makePhoneCall(phoneNumber),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          SizedBox(height: 10),
          Text(
            label, 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 16, 
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
