import 'package:flutter/material.dart';

class DescriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido a SignalsPD'),
        leading: Container(), // Oculta botón "atrás"
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Detección preventiva de señales de Parkinson',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Consta de dos pruebas:\n\n'
              '1. Prueba de dibujo: Traza la espiral con tu dedo, empezando desde el centro hacia afuera, siguiendo la línea lo más precisamente posible.\n\n'
              '2. Prueba de Audio: Pronuncia en voz alta las vocales: A, E, I, O, U, una por una. Cada vocal debe durar aproximadamente 3 segundos.\n',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user_form');
              },
              child: Text('SIGUIENTE'),
            ),
          ],
        ),
      ),
    );
  }
}
