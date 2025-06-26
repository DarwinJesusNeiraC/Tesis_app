import 'package:flutter/material.dart';
import 'user_form_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navega a otra pantalla después de 3 segundos
    /*Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserFormScreen()),
      );
      
    });*/

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/description');
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logo.png', // Reemplaza esto con tu logo
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
