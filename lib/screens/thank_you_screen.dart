import 'package:flutter/material.dart';

class ThankYouScreen extends StatelessWidget {
  final bool hasSymptoms;

  const ThankYouScreen({Key? key, required this.hasSymptoms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mensajes condicionales
    final String title = "Resultado Preliminar";
    final String message = hasSymptoms
        ? "Existe una posible presencia de síntomas relacionados con Parkinson. "
          "Recomendamos consultar con un especialista para una evaluación médica completa y la validación del resultado"
        : "No se detectan señales claras de Parkinson."
          "Sugerimos una revisión médica periódica para mantener su bienestar.";
    final IconData icon = hasSymptoms ? Icons.warning_amber_rounded : Icons.check_circle_outline;
    final Color iconColor = hasSymptoms ? Colors.orange : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: iconColor),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Salir de la aplicación'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
