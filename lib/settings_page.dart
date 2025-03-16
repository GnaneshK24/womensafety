import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Locale _selectedLocale = Locale('en'); // Default language
  ThemeMode _themeMode = ThemeMode.system; // Default theme mode
  bool _notificationsEnabled = true;
  bool _soundEffectsEnabled = true;
  double _fontSize = 16.0;

  void _setLocale(Locale newLocale) {
    if (Intl.verifiedLocale(newLocale.languageCode, (locale) => true, onFailure: (locale) => null) != null) {
      setState(() {
        _selectedLocale = newLocale;
      });
    }
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: SingleChildScrollView( // Fix for overflow issue
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Selection
                Text("Language Selection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<Locale>(
                  value: _selectedLocale,
                  items: [
                    DropdownMenuItem(child: Text("English"), value: Locale('en')),
                    DropdownMenuItem(child: Text("தமிழ் (Tamil)"), value: Locale('ta')),
                    DropdownMenuItem(child: Text("हिन्दी (Hindi)"), value: Locale('hi')),
                  ],
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      _setLocale(newLocale);
                    }
                  },
                ),
                SizedBox(height: 20),

                // Theme Mode Selection
                Text("App Theme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListTile(
                  title: Text("Light"),
                  leading: Radio(
                    value: ThemeMode.light,
                    groupValue: _themeMode,
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) _setThemeMode(mode);
                    },
                  ),
                ),
                ListTile(
                  title: Text("Dark"),
                  leading: Radio(
                    value: ThemeMode.dark,
                    groupValue: _themeMode,
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) _setThemeMode(mode);
                    },
                  ),
                ),
                ListTile(
                  title: Text("System Default"),
                  leading: Radio(
                    value: ThemeMode.system,
                    groupValue: _themeMode,
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) _setThemeMode(mode);
                    },
                  ),
                ),
                SizedBox(height: 20),

                // Notifications Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Enable Notifications", style: TextStyle(fontSize: 18)),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Sound Effects Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Enable Sound Effects", style: TextStyle(fontSize: 18)),
                    Switch(
                      value: _soundEffectsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _soundEffectsEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Font Size Adjustment
                Text("Font Size", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Slider(
                  value: _fontSize,
                  min: 12,
                  max: 24,
                  divisions: 6,
                  label: "${_fontSize.toInt()}",
                  onChanged: (double value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Privacy Settings Navigation
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacySettingsPage()));
                  },
                  child: Text("Privacy Settings"),
                ),

                SizedBox(height: 20),

                // About Page Navigation
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
                  },
                  child: Text("About"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy Privacy Settings Page
class PrivacySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Privacy Settings")),
      body: Center(child: Text("Privacy options go here.")),
    );
  }
}

// About Page (Now Scrollable)
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About")),
      body: SingleChildScrollView( // Fix for overflow issue
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("App Name: Women Safety", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Version: 1.0.0", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Developed by: Your Name", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("License: MIT License", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              "This is a women safety application designed to provide safety for women.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
