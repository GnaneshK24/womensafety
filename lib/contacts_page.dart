import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class ContactsPage extends StatefulWidget {
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
        SnackBar(content: Text('Contacts saved successfully')));
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
          SnackBar(content: Text('Contact permission denied')));
    }
  }

  Future<Position?> _getCurrentLocation() async {
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

  Future<bool> isWhatsAppInstalled() async {
    try {
      bool installed = await canLaunchUrl(Uri.parse("whatsapp://send"));
      return installed;
    } on PlatformException {
      return false;
    }
  }

  Future<void> _sendLocation() async {
    Position? position = await _getCurrentLocation();
    if (position == null) return;

    String location =
        "https://maps.google.com/?q=${position.latitude},${position.longitude}";
    String message = "🚨 Emergency! My live location is: $location";
    String encodedMessage = Uri.encodeComponent(message);

    for (String number in _savedContacts) {
      if (number.isNotEmpty) {
        String formattedNumber = number.replaceAll(RegExp(r'\D'), '');
        bool whatsappInstalled = await isWhatsAppInstalled();
        if (whatsappInstalled) {
          Uri whatsappUrl =
          Uri.parse("whatsapp://send?phone=$formattedNumber&text=$encodedMessage");
          if (await canLaunchUrl(whatsappUrl)) {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open WhatsApp for $number')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('WhatsApp is not installed')));
        }

        Uri smsUrl = Uri.parse("sms:$formattedNumber?body=$encodedMessage");
        if (await canLaunchUrl(smsUrl)) {
          await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not send SMS to $number')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        backgroundColor: Colors.redAccent, // Light theme with red accent
        elevation: 0,
      ),
      backgroundColor: Colors.grey[200], // Light background
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.white,
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
                                decoration: InputDecoration(
                                  labelText: 'Contact ${i + 1}',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.contacts, color: Colors.blue),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveContacts,
                  child: Text("Save Contacts"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: _sendLocation,
                  child: Text("Send Location"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
