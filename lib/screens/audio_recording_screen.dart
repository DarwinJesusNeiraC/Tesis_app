/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingScreen extends StatefulWidget {
  @override
  _AudioRecordingScreenState createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String _currentLetter = "A"; // Letra inicial
  String? _filePath;

  // Letras que se deben grabar
  final List<String> _letters = [
    "A",
    "E",
    "I",
    "O",
    "U",
    "Palabra 1",
    "Palabra 2"
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Permiso de micrófono denegado');
    }
    await _audioRecorder.openRecorder();
  }

  Future<void> _initPlayer() async {
    await _audioPlayer.openPlayer();
  }

  Future<void> _startRecording() async {
    try {
      // Carpeta de Downloads
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync();
      }

      // Archivo con el nombre simple basado en la letra
      String path = '${directory.path}/${_currentLetter}.aac';
      setState(() => _filePath = path);

      // Iniciar grabación
      await _audioRecorder.startRecorder(toFile: path);
      setState(() => _isRecording = true);
    } catch (e) {
      print('Error al iniciar grabación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar grabación: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      setState(() => _isRecording = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio guardado en: $_filePath')),
      );
    } catch (e) {
      print('Error al detener la grabación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al detener la grabación: $e')),
      );
    }
  }

  Future<void> _playAudio() async {
    try {
      if (_filePath != null && File(_filePath!).existsSync()) {
        await _audioPlayer.startPlayer(fromURI: _filePath);
        setState(() {
          _isPlaying = true;
        });

        // Use a delay to simulate waiting for the audio to finish
        await Future.delayed(
            Duration(seconds: 5)); // adjust based on your file length
        setState(() {
          _isPlaying = false;
        });
      } else {
        throw Exception('Archivo de audio no encontrado en $_filePath');
      }
    } catch (e) {
      print('Error al reproducir el audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir el audio: $e')),
      );
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stopPlayer();
      setState(() => _isPlaying = false);
    } catch (e) {
      print('Error al detener el audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al detener el audio: $e')),
      );
    }
  }

  void _nextLetter() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _letters.length;
      _currentLetter = _letters[_currentIndex];
    });
  }

  void _retryRecording() {
    if (_isRecording) {
      _stopRecording();
    }
    _startRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Grabación de Audio")),
      body: SingleChildScrollView(
        // Envolvemos todo el contenido en SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Por favor, diga la siguiente letra:",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                _currentLetter,
                style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300],
                ),
                height: 80,
                child: Center(
                  child: Icon(
                    Icons.graphic_eq,
                    size: 40,
                    color: _isRecording ? Colors.red : Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRecording ? null : _startRecording,
                    icon: Icon(Icons.mic),
                    label: Text("Grabar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isRecording ? _stopRecording : null,
                    icon: Icon(Icons.stop),
                    label: Text("Detener"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _retryRecording,
                    icon: Icon(Icons.refresh),
                    label: Text("Regrabar"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextLetter,
                    icon: Icon(Icons.arrow_forward),
                    label: Text("Siguiente"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? null : _playAudio,
                    icon: Icon(Icons.play_arrow),
                    label: Text("Reproducir"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? _stopAudio : null,
                    icon: Icon(Icons.stop),
                    label: Text("Detener Reproducción"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class AudioRecordingScreen extends StatefulWidget {
  @override
  _AudioRecordingScreenState createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String _currentLetter = "A"; // Letra inicial
  String? _filePath;
  List<double> _waveform = []; // Lista para almacenar las muestras de la onda

  // Letras que se deben grabar
  final List<String> _letters = [
    "A",
    "E",
    "I",
    "O",
    "U",
    "Palabra 1",
    "Palabra 2"
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Permiso de micrófono denegado');
    }
    await _audioRecorder.openRecorder();
  }

  Future<void> _initPlayer() async {
    await _audioPlayer.openPlayer();
  }

  Future<void> _startRecording() async {
    try {
      // Carpeta de Downloads
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync();
      }

      // Archivo con el nombre simple basado en la letra
      String path = '${directory.path}/${_currentLetter}.aac';
      setState(() => _filePath = path);

      // Iniciar grabación
      await _audioRecorder.startRecorder(toFile: path);
      setState(() => _isRecording = true);

      // Capturar las muestras de audio en tiempo real
      _audioRecorder.onProgress!.listen((e) {
        setState(() {
          if (e.decibels != null) {
            _waveform.add(e.decibels!); // Añadir la muestra de decibelios
            if (_waveform.length > 200) {
              _waveform
                  .removeAt(0); // Limitar el número de puntos en el gráfico
            }
          }
        });
      });
    } catch (e) {
      print('Error al iniciar grabación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar grabación: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      setState(() => _isRecording = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio guardado en: $_filePath')),
      );
    } catch (e) {
      print('Error al detener la grabación: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al detener la grabación: $e')),
      );
    }
  }

  Future<void> _playAudio() async {
    try {
      if (_filePath != null && File(_filePath!).existsSync()) {
        await _audioPlayer.startPlayer(fromURI: _filePath);
        setState(() {
          _isPlaying = true;
        });

        // Use a delay to simulate waiting for the audio to finish
        await Future.delayed(
            Duration(seconds: 5)); // adjust based on your file length
        setState(() {
          _isPlaying = false;
        });
      } else {
        throw Exception('Archivo de audio no encontrado en $_filePath');
      }
    } catch (e) {
      print('Error al reproducir el audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir el audio: $e')),
      );
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stopPlayer();
      setState(() => _isPlaying = false);
    } catch (e) {
      print('Error al detener el audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al detener el audio: $e')),
      );
    }
  }

  void _nextLetter() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _letters.length;
      _currentLetter = _letters[_currentIndex];
    });
  }

  void _retryRecording() {
    if (_isRecording) {
      _stopRecording();
    }
    _startRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Grabación de Audio")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Por favor, diga la siguiente letra:",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                _currentLetter,
                style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: 40),
              Container(
                height: 200,
                color: Colors.grey[300],
                child: CustomPaint(
                  size: Size(double.infinity, 200),
                  painter: WaveformPainter(_waveform),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRecording ? null : _startRecording,
                    icon: Icon(Icons.mic),
                    label: Text("Grabar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isRecording ? _stopRecording : null,
                    icon: Icon(Icons.stop),
                    label: Text("Detener"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _retryRecording,
                    icon: Icon(Icons.refresh),
                    label: Text("Regrabar"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextLetter,
                    icon: Icon(Icons.arrow_forward),
                    label: Text("Siguiente"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? null : _playAudio,
                    icon: Icon(Icons.play_arrow),
                    label: Text("Reproducir"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? _stopAudio : null,
                    icon: Icon(Icons.stop),
                    label: Text("Detener Reproducción"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;

  WaveformPainter(this.waveform);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    double width = size.width;
    double height = size.height;

    // Ajustar la amplitud y frecuencia de la onda
    double maxAmplitude = 50.0; // Ajuste del límite máximo de amplitud
    double scale = height / 2; // Escalar la onda verticalmente

    Path path = Path();
    for (int i = 0; i < waveform.length; i++) {
      double x = (i / waveform.length) * width;
      double y = size.height / 2 +
          (waveform[i] * scale / maxAmplitude); // Ajuste de escala

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
