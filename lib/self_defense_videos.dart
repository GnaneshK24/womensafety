import 'package:flutter/material.dart';
import 'video_player_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelfDefenseVideos extends StatelessWidget {
  final List<Map<String, String>> videos = [
    {"title": "basicSelfDefense", "id": "ERMZRMqQmVI"},
    {"title": "escapeAttacker", "id": "q1pBBRi3XF8"},
    {"title": "easySelfDefenseMoves", "id": "B725c7vi1xk"},
    {"title": "knifeAttackDefense", "id": "kvlrnc7hlQI"},
    {"title": "breakFreeAttacker", "id": "0XcX1AAlj1M"},
    {"title": "simpleSelfDefenseTips", "id": "KVpxP3ZZtAc"},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selfDefenseTitle),
        backgroundColor: isDark ? Colors.pinkAccent : Colors.redAccent,
        elevation: 0,
      ),
      backgroundColor: isDark ? Color(0xFF121212) : Colors.grey[200],
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              l10n.selfDefenseDescription,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                String videoId = videos[index]['id']!;
                String thumbnailUrl = "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";
                String titleKey = videos[index]['title']!;

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: isDark ? Color(0xFF1E1E1E) : Colors.white,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.network(
                          thumbnailUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: isDark ? Colors.grey[600] : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          _getLocalizedTitle(l10n, titleKey),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        trailing: Icon(Icons.play_circle_fill, 
                          color: isDark ? Colors.pinkAccent : Colors.red, 
                          size: 30
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerPage(videoId: videoId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedTitle(AppLocalizations l10n, String key) {
    switch (key) {
      case 'basicSelfDefense':
        return l10n.basicSelfDefense;
      case 'escapeAttacker':
        return l10n.escapeAttacker;
      case 'easySelfDefenseMoves':
        return l10n.easySelfDefenseMoves;
      case 'knifeAttackDefense':
        return l10n.knifeAttackDefense;
      case 'breakFreeAttacker':
        return l10n.breakFreeAttacker;
      case 'simpleSelfDefenseTips':
        return l10n.simpleSelfDefenseTips;
      default:
        return key;
    }
  }
}
