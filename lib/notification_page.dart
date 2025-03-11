import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Text(
          "No new notifications",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
