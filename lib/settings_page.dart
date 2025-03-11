import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:womensafety/main.dart';

class SettingsPage extends StatelessWidget {
  final Map<String, String> languageNames = {
    'en': 'English',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'kn': 'ಕನ್ನಡ',
    'hi': 'हिन्दी',
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Language",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: provider.currentLanguage,
              items: languageNames.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  provider.changeLanguage(newLanguage);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
