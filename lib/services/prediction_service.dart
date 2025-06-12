// lib/services/prediction_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  final String _baseUrl =
      'https://8916-45-231-83-4.ngrok-free.app'; // IMPORTANT: Replace with your stable API URL

  /// Makes a prediction request for handwriting.
  /// Returns the parsed JSON response or null on error.
  Future<Map<String, dynamic>?> predictHandwriting(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        print('Error: Drawing image not found at $imagePath');
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/handwriting/predict'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        print(
            'Handwriting Prediction Raw Response: ${response.body}'); // Added for raw output
        //return json.decode(response.body) as Map<String, dynamic>;
        return jsonResponse;
      } else {
        print(
            'Error predicting handwriting: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception predicting handwriting: $e');
      return null;
    }
  }

  /// Makes a prediction request for audio.
  /// Returns the parsed JSON response or null on error.
  Future<Map<String, dynamic>?> predictAudio(String audioPath) async {
    try {
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        print('Error: Audio file not found at $audioPath');
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/audio/predict'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        //return json.decode(response.body) as Map<String, dynamic>;
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        print(
            'Audio Prediction Raw Response: ${response.body}'); // Added for raw output
        return jsonResponse;
      } else {
        print(
            'Error predicting audio: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception predicting audio: $e');
      return null;
    }
  }
}
