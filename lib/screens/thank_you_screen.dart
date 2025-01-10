import 'package:flutter/material.dart';

// Pantalla de agradecimiento
class ThankYouScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gracias'),
      ),
      body: Center(
        child: Text(
          '¡Gracias por completar la prueba de audio!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
