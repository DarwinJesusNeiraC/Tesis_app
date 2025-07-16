import 'package:flutter/material.dart';
import '../services/symptom_detection_service.dart';
import '../utils/dialog_utils.dart';
import '../utils/network_utils.dart';
import '../screens/thank_you_screen.dart';

class SymptomHelper {
  final SymptomDetectionService _detectionService;

  SymptomHelper(this._detectionService);

  Future<void> analyzeAndNavigate({
    required BuildContext context,
    required String drawingPath,
    required List<String> audioPaths,
  }) async {
    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      await DialogUtils.showErrorDialog(
          context, 'No hay conexión a internet. Conéctate para continuar.');
      return;
    }

    DialogUtils.showLoadingDialog(context, "Analizando resultados...");

    try {
      final result =
          await _detectionService.determineSymptoms(drawingPath, audioPaths);

      Navigator.of(context).pop(); // Cierra loading
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ThankYouScreen(
            hasSymptoms: result['hasSymptoms'],
            drawingProbability: result['drawingProbability'],
            audioProbability: result['audioProbability'],
            combinedProbability: result['combinedProbability'],
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Cierra loading
      DialogUtils.showErrorDialog(
          context, 'Ocurrió un error al analizar los resultados.');
    }
  }
}
