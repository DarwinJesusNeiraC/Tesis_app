import 'package:drawtesis/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'screens/user_form_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/user_form': (context) => UserFormScreen(),
        //'/draw': (context) => DrawScreen(),
        //'/audio': (context) => AudioRecordingScreen(), // Nueva ruta
        //'/': (context) => AudioRecordingScreen(), // Nueva ruta
      },
    );
  }
}
