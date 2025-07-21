import 'package:flutter/material.dart';

class ThankYouScreen extends StatelessWidget {
  final bool hasSymptoms;
  final double drawingProbability;
  final double audioProbability;
  final double combinedProbability;

  //onst ThankYouScreen({Key? key, required this.hasSymptoms}) : super(key: key);
  const ThankYouScreen({
    super.key,
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
/*
  @override
  Widget build(BuildContext context) {
    final result = _getResultConfig(combinedProbability);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                  backgroundColor: Color(0xFF6A1B9A), // Color vino
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('VOLVER AL INICIO'),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Porcentajes de señales de Parkinson:",
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

  @override
  Widget build(BuildContext context) {
    final result = _getResultConfig(combinedProbability);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- Custom Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Image.asset('assets/logo.png', height: 40),
                ],
              ),

              const Spacer(flex: 2),

              // --- Main Result Section (Unchanged) ---
              Icon(result["icon"], size: 100, color: result["iconColor"]),
              const SizedBox(height: 24),
              
              Text(
                result["title"],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  //color: Color.fromARGB(255, 196, 46, 114),
                  color: Color.fromARGB(255, 24, 165, 193),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                result["subtitle"],
                style: const TextStyle(
                  fontSize: 16, 
                  color: Colors.black54, 
                  height: 1.5),
                  textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // --- UPDATED: Detailed Analysis Card ---
              _buildProbabilityDetails(),

              const Spacer(flex: 3),

              // --- UPDATED: "Finalize" Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('VOLVER AL INICIO', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW: Helper widget for the detailed analysis card ---
  Widget _buildProbabilityDetails() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "Análisis Detallado",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem("Dibujo", drawingProbability),
              _buildDetailItem("Audio", audioProbability),
              _buildDetailItem("General", combinedProbability, isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  // --- NEW: Helper widget for each item in the analysis card ---
  Widget _buildDetailItem(String label, double probability, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          "${(probability * 100).toStringAsFixed(1)}%",
          style: TextStyle(
            fontSize: isBold ? 20 : 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF4A148C),
          ),
        ),
      ],
    );
  }
}

