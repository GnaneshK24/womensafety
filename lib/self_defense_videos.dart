import 'package:flutter/material.dart';
import 'video_player_page.dart';

class SelfDefenseVideos extends StatelessWidget {
  final List<Map<String, String>> videos = [
    {"title": "Basic Self Defense", "id": "ERMZRMqQmVI"},
    {"title": "Escape an Attacker", "id": "q1pBBRi3XF8"},
    {"title": "5 Easy Self-Defense Moves", "id": "B725c7vi1xk"},
    {"title": "Self Defense Against Knife Attack", "id": "kvlrnc7hlQI"},
    {"title": "How to Break Free from an Attacker", "id": "0XcX1AAlj1M"},
    {"title": "Simple Self-Defense Tips for Women", "id": "KVpxP3ZZtAc"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Self-Defense Videos")),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          String videoId = videos[index]['id']!;
          String thumbnailUrl = "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";

          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    thumbnailUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                ListTile(
                  title: Text(
                    videos[index]['title']!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.play_circle_fill, color: Colors.red, size: 30),
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
    );
  }
}
