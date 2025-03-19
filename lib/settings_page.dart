import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'sos_settings_provider.dart';
import 'font_size_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEffectsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final sosSettings = Provider.of<SOSSettingsProvider>(context, listen: false);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Theme Settings
          StatefulBuilder(
            builder: (context, setState) => SwitchListTile(
              title: Text(l10n.darkMode),
              subtitle: Text(l10n.toggleTheme),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                themeProvider.toggleTheme();
                setState(() {});
              },
            ),
          ),

          // Language Settings
          StatefulBuilder(
            builder: (context, setState) => ListTile(
              title: Text(l10n.language),
              subtitle: Text(l10n.language),
              trailing: DropdownButton<Locale>(
                value: languageProvider.locale,
                items: [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('hi'), child: Text('हिंदी')),
                  DropdownMenuItem(value: Locale('ta'), child: Text('தமிழ்')),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    languageProvider.setLocale(newLocale);
                    setState(() {});
                  }
                },
              ),
            ),
          ),

          // Notification Settings
          SwitchListTile(
            title: Text(l10n.notifications),
            subtitle: Text(l10n.enableNotifications),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          // Sound Effects Settings
          SwitchListTile(
            title: Text(l10n.soundEffects),
            subtitle: Text(l10n.enableSoundEffects),
            value: _soundEffectsEnabled,
            onChanged: (bool value) {
              setState(() {
                _soundEffectsEnabled = value;
              });
            },
          ),

          // Police Call Settings
          StatefulBuilder(
            builder: (context, setState) => SwitchListTile(
              title: Text(l10n.policeCallTitle),
              subtitle: Text(l10n.policeCallDescription),
              value: sosSettings.policeCallEnabled,
              onChanged: (bool value) {
                sosSettings.togglePoliceCall(value);
                setState(() {});
              },
            ),
          ),

          // Font Size Settings
          StatefulBuilder(
            builder: (context, setState) => ListTile(
              title: Text(l10n.fontSize),
              subtitle: Slider(
                value: fontSizeProvider.fontSize,
                min: 12,
                max: 24,
                divisions: 12,
                label: fontSizeProvider.fontSize.toStringAsFixed(1),
                onChanged: (double value) {
                  fontSizeProvider.setFontSize(value);
                  setState(() {});
                },
              ),
              trailing: Text(
                '${fontSizeProvider.fontSize.toStringAsFixed(1)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Logout Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.logout),
                    content: Text(l10n.logoutConfirmation),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.logout, style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: Text(
                l10n.logout,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
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
