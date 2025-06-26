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
              'Este test consiste en dos pruebas:\n\n'
              '1. Prueba de dibujo: consiste en seguir la línea de la espiral.\n\n'
              '2. Prueba de audio: consiste en decir las vocales A, E, I, O, U.\n',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/user_form');
              },
              child: Text('ENTRAR'),
            ),
          ],
        ),
      ),
    );
  }
}
