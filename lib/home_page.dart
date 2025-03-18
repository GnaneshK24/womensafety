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

    return Column(
      children: [
        Text(
          l10n.welcomeMessage,
          style: TextStyle(
            fontSize: baseFontSize * 1.5, // 24 when base is 16
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          l10n.safetyTips,
          style: TextStyle(
            fontSize: baseFontSize * 1.125, // 18 when base is 16
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          l10n.emergencyContacts,
          style: TextStyle(
            fontSize: baseFontSize * 1.25, // 20 when base is 16
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          l10n.selfDefense,
          style: TextStyle(
            fontSize: baseFontSize * 1.25,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          l10n.laws,
          style: TextStyle(
            fontSize: baseFontSize * 1.25,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          l10n.news,
          style: TextStyle(
            fontSize: baseFontSize * 1.25,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          l10n.map,
          style: TextStyle(
            fontSize: baseFontSize * 1.25,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          l10n.settings,
          style: TextStyle(
            fontSize: baseFontSize * 1.25,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGridButton(IconData icon, String text, VoidCallback onPressed) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
              width: 150, // Fixed width for consistency
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
                      fontSize: baseFontSize * 0.875, // 14 when base is 16
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.pinkAccent.withOpacity(0.8) : Colors.pinkAccent,
                    ),
                    maxLines: 2, // Allow up to 2 lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 