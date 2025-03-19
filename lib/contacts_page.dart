import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsPage extends StatefulWidget {
  static Future<void> shareLocation(Position position) async {
    final locationUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}'
    );
    
    if (await canLaunchUrl(locationUrl)) {
      await launchUrl(locationUrl);
    }
  }

  static Future<void> sendLocation(BuildContext context) async {
    try {
      // Get contacts immediately
      final prefs = await SharedPreferences.getInstance();
      final savedContacts = [
        prefs.getString('contact1') ?? "",
        prefs.getString('contact2') ?? "",
        prefs.getString('contact3') ?? ""
      ].where((number) => number.isNotEmpty).toList();

      // Get location with reduced accuracy and timeout
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.reduced,
          timeLimit: Duration(seconds: 2),
        );
      } catch (e) {
        // If location fails, try with lowest accuracy
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.lowest,
            timeLimit: Duration(seconds: 2),
          );
        } catch (e) {
          // If still fails, use last known location
          position = await Geolocator.getLastKnownPosition();
        }
      }

      if (position == null) {
        throw Exception('Could not get location');
      }

      // Create location URL and message
      String location = "https://maps.google.com/?q=${position.latitude},${position.longitude}";
      String message = "🚨 EMERGENCY SOS! I need immediate help! My location: $location";
      String encodedMessage = Uri.encodeComponent(message);

      // Create futures for all message sending operations
      List<Future<void>> messageFutures = [];

      // Process all contacts simultaneously
      for (String number in savedContacts) {
        String formattedNumber = number.replaceAll(RegExp(r'\D'), '');
        
        // Try WhatsApp first
        messageFutures.add(
          isWhatsAppInstalled().then((whatsappInstalled) async {
            if (whatsappInstalled) {
              Uri whatsappUrl = Uri.parse("whatsapp://send?phone=$formattedNumber&text=$encodedMessage");
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
              }
            }
          }),
        );

        // Try SMS as backup
        messageFutures.add(
          launchUrl(
            Uri.parse("sms:$formattedNumber?body=$encodedMessage"),
            mode: LaunchMode.externalApplication,
          ),
        );
      }

      // Wait for all messages to be sent with a timeout
      await Future.wait(
        messageFutures,
        eagerError: false,
      ).timeout(
        Duration(seconds: 5),
        onTimeout: () {
          // Even if some messages fail, we don't want to block the SOS process
          return <void>[];
        },
      );

    } catch (e) {
      // In emergency situations, we don't want to show errors to the user
      // Just continue with the SOS process
      print('Error in sendLocation: $e');
    }
  }

  static Future<Position?> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enable location services')));
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied')));
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Location permissions are permanently denied, enable them in settings.')));
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  static Future<bool> isWhatsAppInstalled() async {
    try {
      bool installed = await canLaunchUrl(Uri.parse("whatsapp://send"));
      return installed;
    } on PlatformException {
      return false;
    }
  }

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<TextEditingController> _controllers =
  List.generate(3, (index) => TextEditingController());
  List<String> _savedContacts = ["", "", ""];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedContacts = [
        prefs.getString('contact1') ?? "",
        prefs.getString('contact2') ?? "",
        prefs.getString('contact3') ?? ""
      ];
      for (int i = 0; i < 3; i++) {
        _controllers[i].text = _savedContacts[i];
      }
    });
  }

  Future<void> _saveContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 3; i++) {
      await prefs.setString('contact${i + 1}', _controllers[i].text);
    }
    setState(() {
      _savedContacts = _controllers.map((c) => c.text).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.contactsSaved)));
  }

  Future<void> _pickContact(int index) async {
    if (await Permission.contacts.request().isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        setState(() {
          _controllers[index].text = contact.phones.first.number ?? "";
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.contactPermissionDenied)));
    }
  }

  Future<void> _sendLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}',
      );

      // Send location to all saved contacts
      for (String phoneNumber in _savedContacts) {
        if (phoneNumber.isNotEmpty) {
          final messageUrl = Uri.parse(
            'https://wa.me/$phoneNumber?text=EMERGENCY! I need help! My location: $locationUrl',
          );
          if (await canLaunchUrl(messageUrl)) {
            await launchUrl(messageUrl);
          }
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.contactsSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.locationError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.emergencyContacts),
        backgroundColor: isDark ? Colors.pinkAccent : Colors.redAccent,
        elevation: 0,
      ),
      backgroundColor: isDark ? Color(0xFF121212) : Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: isDark ? Color(0xFF1E1E1E) : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controllers[i],
                                keyboardType: TextInputType.phone,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                decoration: InputDecoration(
                                  labelText: '${localizations.contact} ${i + 1}',
                                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: isDark 
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey[100],
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? Colors.white24 : Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isDark ? Colors.pinkAccent : Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.contacts, 
                                color: isDark ? Colors.pinkAccent : Colors.blue),
                              onPressed: () => _pickContact(i),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveContacts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.pinkAccent.withOpacity(0.8) : Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      localizations.saveContacts,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.pinkAccent.withOpacity(0.8) : Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      localizations.sendLocation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
