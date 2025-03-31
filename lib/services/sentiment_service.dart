import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentService {
  static const String _apiUrl = "https://api.aixplain.com"; // Update with the correct API endpoint
  static const String _apiKey = "cb0712ffafa2b408fb5a54d916bbf9be576bfe26592a293120285015d14f1ae3";

  static Future<String> analyzeSentiment(String text) async {
    final url = Uri.parse("$_apiUrl/v1/sentiment"); // Update if needed
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["sentiment"]; // Update based on actual response format
    } else {
      return "Error: ${response.statusCode}";
    }
  }
}
