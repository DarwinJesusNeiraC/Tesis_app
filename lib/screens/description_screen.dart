import 'package:flutter/material.dart';

class DescriptionScreen extends StatelessWidget {
  const DescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // --- Header with back arrow and logo ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                    onPressed: () {
                      // If you want the back button to work, you might need to change
                      // how you handle navigation, e.g., using Navigator.pop(context)
                      // For now, it's just a visual element.
                    },
                  ),
                  // Placeholder for your logo
                  const Icon(Icons.biotech, color: Colors.purple, size: 30),
                ],
              ),
              const Spacer(flex: 1),

              // --- Main Content ---
              const Text(
                'SignalsPD',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C), // A deep purple color
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Detección preventiva de señales de Parkinson',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigo,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // --- Instructions Section ---
              _buildInstructionSection(
                title: 'Consta de dos pruebas:',
                instructions: [
                  'Prueba de dibujo: Traza la espiral con tu dedo, empezando desde el centro hacia afuera, siguiendo la línea lo más precisamente posible.',
                  'Prueba de Audio: Pronuncia en voz alta las vocales: A, E, I, O, U, una por una. Cada vocal debe durar aproximadamente 3 segundos.',
                ],
              ),
              
              const Spacer(flex: 2),

              // --- "Next" Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/user_form');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A), // Purple color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIGUIENTE',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget to build the instruction section for better readability.
  Widget _buildInstructionSection({required String title, required List<String> instructions}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(instructions.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                Expanded(
                  child: Text(
                    instructions[index],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4, // Improved line spacing
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
