import 'package:drawtesis/screens/description_screen.dart';
import 'package:drawtesis/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'screens/user_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Dibujo',

      debugShowCheckedModeBanner: false, // Elimina el banner "Debug"
  
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/description': (context) => DescriptionScreen(), // <-- NUEVA RUTA
        '/user_form': (context) => UserFormScreen(),
        //'/draw': (context) => DrawScreen(),
        //'/audio': (context) => AudioRecordingScreen(), // Nueva ruta
        //'/': (context) => AudioRecordingScreen(), // Nueva ruta
      },
    );
  }
}
