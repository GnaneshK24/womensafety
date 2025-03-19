import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'font_size_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final baseFontSize = fontSizeProvider.fontSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.welcomeMessage,
          style: TextStyle(
            fontSize: baseFontSize * 1.5,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                l10n.safetyTips,
                style: TextStyle(
                  fontSize: baseFontSize * 1.125,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildGridButton(context, Icons.contacts, l10n.emergencyContacts, () {}),
                _buildGridButton(context, Icons.sports_kabaddi, l10n.selfDefense, () {}),
                _buildGridButton(context, Icons.gavel, l10n.laws, () {}),
                _buildGridButton(context, Icons.newspaper, l10n.news, () {}),
                _buildGridButton(context, Icons.map, l10n.map, () {}),
                _buildGridButton(context, Icons.settings, l10n.settings, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(BuildContext context, IconData icon, String text, VoidCallback onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final baseFontSize = fontSizeProvider.fontSize;
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          width: 140,
          height: 140,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: isDark 
                        ? [Colors.pinkAccent.withOpacity(0.8), Colors.deepPurpleAccent.withOpacity(0.8)]
                        : [Colors.pinkAccent, Colors.deepPurpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: baseFontSize * 0.875,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.pinkAccent.withOpacity(0.8) : Colors.pinkAccent,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 