import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;

  VideoPlayerPage({required this.videoId});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(autoPlay: true),
    )..addListener(() {
      if (_controller.value.hasError) {
        setState(() {
          _errorMessage = "This video is restricted. Open in YouTube.";
        });
      }
    });
  }

  void _openInYouTube() async {
    String url = "https://www.youtube.com/watch?v=${widget.videoId}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      setState(() {
        _errorMessage = "Cannot open YouTube.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Playing Video")),
      body: _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openInYouTube,
              child: Text("Open in YouTube"),
            ),
          ],
        ),
      )
          : YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
