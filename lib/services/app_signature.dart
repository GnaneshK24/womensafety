import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AppSignature {
  static const MethodChannel _channel = MethodChannel('app_signature');

  static Future<String> getSignatureInfo() async {
    try {
      final String result = await _channel.invokeMethod('getSignatureInfo');
      return result;
    } on PlatformException catch (e) {
      return "Failed to get signature info: ${e.message}";
    }
  }

  static void showSignatureInfo(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('App Signature Info'),
        content: FutureBuilder<String>(
          future: getSignatureInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snapshot.data ?? 'No signature info available'),
                SizedBox(height: 20),
                Text('For Firebase, you need to configure your project with this SHA-1 certificate fingerprint.'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
} 