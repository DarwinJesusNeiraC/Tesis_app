// lib/services/symptom_detection_service.dart
import 'prediction_service.dart';

class SymptomDetectionService {
  final PredictionService _predictionService;

  SymptomDetectionService(this._predictionService);

  /// Determines if the user has symptoms based on handwriting and audio predictions.
  Future<Map<String, dynamic>> determineSymptoms(
      String drawingPath, List<String> audioPaths) async {
    print('[DEBUG] determineSymptoms() fue llamado');
    double parkinsonProbabilityDrawing = 0.0;
    double parkinsonProbabilityAudio = 0.0;

    // ======== 1. Get handwriting prediction ========
    // Get handwriting prediction
    final handwritingResult =
        await _predictionService.predictHandwriting(drawingPath);

    if (handwritingResult != null &&
        handwritingResult['probabilities'] != null) {
      String parkinsonProbStr = handwritingResult['probabilities']['Parkinson'];
      parkinsonProbStr = parkinsonProbStr.replaceAll('%', '');
      parkinsonProbabilityDrawing = double.parse(parkinsonProbStr) / 100.0;
      print(
          'Parsed Parkinson Probability (Drawing): ${parkinsonProbabilityDrawing * 100}%'); // Added
    } else {
      print('Warning: Could not get valid handwriting prediction.');
    }

    // ======== 2. Get audio predictions ========
    // Get audio prediction
    final audioResult = await _predictionService.predictAudio(audioPaths);

    if (audioResult != null && audioResult['individual_predictions'] is List) {
      int positivePredictions = 0;
      final predictions = audioResult['individual_predictions'] as List;

      for (var prediction in predictions) {
        if (prediction == 1) {
          positivePredictions++;
        }
      }

      if (predictions.isNotEmpty) {
        parkinsonProbabilityAudio = positivePredictions / predictions.length;
      }
    } else {
      print('Warning: Could not get valid audio prediction.');
    }

    // Combine results (you can adjust this logic as needed)
    double img_accuracy = 97.6 / 100;
    double audio_accuracy = 90.33 / 100;
    double peso_img = img_accuracy /(img_accuracy + audio_accuracy);
    double peso_audio = audio_accuracy /(img_accuracy + audio_accuracy);
    final double combinedProbability =
        //(parkinsonProbabilityDrawing + parkinsonProbabilityAudio) / 2.0;
        (parkinsonProbabilityDrawing * peso_img) + (parkinsonProbabilityAudio * peso_audio);
    print(
        'Parkinson Probability - Drawing: ${parkinsonProbabilityDrawing * 100}%');
    print('Parkinson Probability - Audio: ${parkinsonProbabilityAudio * 100}%');
    print('Combined Parkinson Probability: ${combinedProbability * 100}%');

    // Define your threshold for "hasSymptoms"
    const double symptomThreshold = 0.50; // 50%
    final bool hasSymptoms = combinedProbability >= symptomThreshold;

    //return combinedProbability >= symptomThreshold;
    return {
      'drawingProbability': parkinsonProbabilityDrawing,
      'audioProbability': parkinsonProbabilityAudio,
      'combinedProbability': combinedProbability,
      'hasSymptoms': hasSymptoms,
    };
  }
}
