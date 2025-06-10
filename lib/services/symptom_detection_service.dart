// lib/services/symptom_detection_service.dart
import 'prediction_service.dart';

class SymptomDetectionService {
  final PredictionService _predictionService;

  SymptomDetectionService(this._predictionService);

  /// Determines if the user has symptoms based on handwriting and audio predictions.
  Future<bool> determineSymptoms(String drawingPath, String audioPath) async {
    double parkinsonProbabilityDrawing = 0.0;
    double parkinsonProbabilityAudio = 0.0;

    // Get handwriting prediction
    final handwritingResult = await _predictionService.predictHandwriting(drawingPath);
    if (handwritingResult != null && handwritingResult['probabilities'] != null) {
      String parkinsonProbStr = handwritingResult['probabilities']['Parkinson'];
      parkinsonProbStr = parkinsonProbStr.replaceAll('%', '');
      parkinsonProbabilityDrawing = double.parse(parkinsonProbStr) / 100.0;
      print('Parsed Parkinson Probability (Drawing): ${parkinsonProbabilityDrawing * 100}%'); // Added

    } else {
      print('Warning: Could not get valid handwriting prediction.');
    }

    // Get audio prediction
    final audioResult = await _predictionService.predictAudio(audioPath);
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
    final double combinedProbability = (parkinsonProbabilityDrawing + parkinsonProbabilityAudio) / 2.0;
    print('Parkinson Probability - Drawing: ${parkinsonProbabilityDrawing * 100}%');
    print('Parkinson Probability - Audio: ${parkinsonProbabilityAudio * 100}%');
    print('Combined Parkinson Probability: ${combinedProbability * 100}%');

    // Define your threshold for "hasSymptoms"
    const double symptomThreshold = 0.50; // 50%

    return combinedProbability >= symptomThreshold;
  }
}