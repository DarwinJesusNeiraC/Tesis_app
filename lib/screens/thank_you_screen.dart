import 'package:flutter/material.dart';

class ThankYouScreen extends StatelessWidget {
  final bool hasSymptoms;
  final double drawingProbability;
  final double audioProbability;
  final double combinedProbability;

  //onst ThankYouScreen({Key? key, required this.hasSymptoms}) : super(key: key);
  const ThankYouScreen({
    required this.hasSymptoms,
    required this.drawingProbability,
    required this.audioProbability,
    required this.combinedProbability,
  });

  // Mensajes y configuración visual por nivel de riesgo
  Map<String, dynamic> _getResultConfig(double combinedProbability) {
    if (combinedProbability < 0.30) {
      return {
        "icon": Icons.check_box_rounded,
        "iconColor": Colors.green,
        "title":
            "No se detectaron indicios significativos de Parkinson.",
        "subtitle":
            "Este es un análisis preventivo. ¡Sigue cuidando tu salud!",
      };
    } else if (combinedProbability < 0.70) {
      return {
        "icon": Icons.search_rounded,
        "iconColor": Colors.blueGrey,
        "title":
            "Se encontraron señales moderadas que podrían estar relacionadas con Parkinson.",
        "subtitle":
            "Te recomendamos consultar con un profesional médico para una evaluación más completa.",
      };
    } else {
      return {
        "icon": Icons.warning_amber_rounded,
        "iconColor": Colors.orange,
        "title":
            "Se detectaron indicios relevantes compatibles con síntomas de Parkinson.",
        "subtitle":
            "Por favor, consulta con un médico especialista para una evaluación clínica detallada.",
      };
    }
  }

  String _getRiskMessage(double combinedProbability) {
    // Rangos: <30% → Bajo, 30–70% → Moderado, >70% → Alto
    if (combinedProbability < 0.30) {
      return "No se detectaron indicios significativos de Parkinson.\n\n"
          "Este es un análisis preventivo. ¡Sigue cuidando tu salud!";
    } else if (combinedProbability < 0.70) {
      return "Se encontraron señales moderadas que podrían estar relacionadas con Parkinson.\n\n"
          "Te recomendamos consultar con un profesional médico para una evaluación más completa.";
    } else {
      return "Se detectaron indicios relevantes compatibles con síntomas de Parkinson.\n\n"
          "Por favor, consulta con un médico especialista para una evaluación clínica detallada.";
    }
  }

  IconData get _iconData => combinedProbability < 0.30
      ? Icons.check_circle_outline
      : combinedProbability < 0.70
          ? Icons.warning_amber_rounded
          : Icons.health_and_safety;

  Color get _iconColor => combinedProbability < 0.30
      ? Colors.green
      : combinedProbability < 0.70
          ? Colors.orange
          : Colors.red;

  @override
  Widget build(BuildContext context) {
    /*// Mensajes condicionales
    final String title = "Resultado Preliminar";
    final String message = hasSymptoms
        ? "Existe una posible presencia de síntomas relacionados con Parkinson. "
            "Recomendamos consultar con un especialista para una evaluación médica completa y la validación del resultado"
        : "No se detectan señales claras de Parkinson."
            "Sugerimos una revisión médica periódica para mantener su bienestar.";
    final IconData icon =
        hasSymptoms ? Icons.warning_amber_rounded : Icons.check_circle_outline;
    final Color iconColor = hasSymptoms ? Colors.orange : Colors.green;
    */
    //final message = _getRiskMessage(combinedProbability);
    final result = _getResultConfig(combinedProbability);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Resultado del Análisis'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(result["icon"], size: 70, color: result["iconColor"]),
              const SizedBox(height: 24),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    children: [
                      const Text(
                        "RESULTADO:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result["title"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF03257E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        result["subtitle"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF781344), // Color vino
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('SALIR'),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Probabilidades detectadas:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text("• Dibujo: ${(drawingProbability * 100).toStringAsFixed(1)}%"),
              Text("• Audio: ${(audioProbability * 100).toStringAsFixed(1)}%"),
              Text("• Promedio: ${(combinedProbability * 100).toStringAsFixed(1)}%"),
            ],
          ),
        ),
      ),
    );
  }
}
  /*
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del Analisis'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconData, size: 80, color: _iconColor),
              const SizedBox(height: 20),
              Text(
                "Analisis preventivo de Parkinson",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                "Probabilidades detectadas:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                "• Dibujo: ${(drawingProbability * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "• Audio: ${(audioProbability * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "• Promedio: ${(combinedProbability * 100).toStringAsFixed(1)}%",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                //onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Salir de la aplicación'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // Limpia la pila de pantallas y vuelve al inicio
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
