import 'dart:async';
import 'dart:io';
import 'package:drawtesis/screens/thank_you_screen.dart';
import 'package:drawtesis/services/prediction_service.dart';
import 'package:drawtesis/services/symptom_detection_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String folderPath;

  AudioRecordingScreen({
    required this.firstName,
    required this.lastName,
    required this.folderPath,
  });

  @override
  _AudioRecordingScreenState createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  late final SymptomDetectionService _symptomDetectionService;

  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isRecordingComplete = false;
  bool _navigationCompleted = false;
  String _currentLetter = "A"; // Letra inicial
  int _recordingCount = 1; // Contador de grabaciones por letra (1, 2, 3)
  String? _filePath;
  List<String> _recordedAudioPaths = []; // <-- NUEVO

  final List<String> _letters = ["A", "E", "I", "O", "U"];
  int _currentIndex = 0;

  // Timer para la grabación
  Timer? _recordingTimer;
  int _recordingDuration = 0; // Duración en segundos

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
    _symptomDetectionService = SymptomDetectionService(PredictionService());
  }

  @override
  void dispose() {
    if (!_navigationCompleted) {
      print(
          'DEBUG: AudioRecordingScreen is disposing. API calls will NOT be made if navigation did not complete.'); // <--- ADD THIS LINE
    }
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    _recordingTimer?.cancel();
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
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync();
      }

      //String fileName = '$_recordingCount$_currentLetter.aac';
      //String path = '${directory.path}/$fileName';
      String fileName =
          'audio_${widget.firstName}_${widget.lastName}_${_currentLetter}_$_recordingCount.wav';
      String path = '${widget.folderPath}/$fileName';
      setState(() {
        _filePath = path;
        _isRecordingComplete = false;
      });

      await _audioRecorder.startRecorder(toFile: path, codec: Codec.pcm16WAV);
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      // Inicia un temporizador para la grabación
      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });

        // Detener automáticamente a los 2 segundos
        if (_recordingDuration >= 2) {
          _stopRecording();
        }
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
      setState(() {
        _isRecording = false;
        _isRecordingComplete = true;
      });

      _recordingTimer?.cancel();

      if (_filePath != null) {
        _recordedAudioPaths.add(_filePath!);
      }

      // Detiene el temporizador de grabación

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
      if (!_isRecordingComplete) {
        throw Exception('Debe terminar de grabar antes de reproducir.');
      }

      if (_filePath != null && File(_filePath!).existsSync()) {
        await _audioPlayer.startPlayer(
          fromURI: _filePath,
          whenFinished: () {
            setState(() => _isPlaying = false);
          },
        );
        setState(() {
          _isPlaying = true;
          _isPaused = false;
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

  void _nextLetter() {
    setState(() {
      if (_recordingCount < 1) {
        _recordingCount++;
      } else if (_currentIndex < _letters.length - 1) {
        //_currentIndex = (_currentIndex + 1) % _letters.length;
        _currentIndex++;
        _currentLetter = _letters[_currentIndex];
        _recordingCount = 1;
      } else {
        _navigateToThankYouScreen();
      }
      _isRecordingComplete = false; // Resetear para la siguiente letra
    });
  }

  Future<void> _navigateToThankYouScreen() async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Analizando resultados..."),
            ],
          ),
        );
      },
    );

    // Get the drawing file path (assuming it's named 'dibujo.png' in the user's folder)
    final String drawingImagePath = '${widget.folderPath}/dibujo.png';
    // Get the final audio file path for the last recording (or adjust if you need all audio files)
    // For simplicity, we'll use the last recorded audio file path.
    // In a real scenario, you might want to send all audio files or average their results.
    final List<String> allAudioPaths = _recordedAudioPaths;

    print('Attempting to determine symptoms:');
    print('Drawing Image Path: $drawingImagePath');
    //print('Last Recorded Audio Path: $finalAudioPath');
    // Determine symptoms using the dedicated service
    //bool hasSymptoms = await _symptomDetectionService.determineSymptoms(drawingImagePath, finalAudioPath);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool hasSymptoms = false;
    double drawingProbability = 0.0;
    double audioProbability = 0.0;
    double combinedProbability = 0.0;
    try {
      //hasSymptoms = await _symptomDetectionService.determineSymptoms(
      //    drawingImagePath, finalAudioPath);
      //hasSymptoms = await _symptomDetectionService.determineSymptoms(drawingImagePath, allAudioPaths);
      final result = await _symptomDetectionService.determineSymptoms(
        drawingImagePath,
        allAudioPaths,
      );

      hasSymptoms = result['hasSymptoms'];
      drawingProbability = result['drawingProbability'];
      audioProbability = result['audioProbability'];
      combinedProbability = result['combinedProbability'];

      print('[DEBUG] Probabilidad (Dibujo): ${drawingProbability * 100}%');
      print('[DEBUG] Probabilidad (Audio): ${audioProbability * 100}%');
      print('[DEBUG] Probabilidad combinada: ${combinedProbability * 100}%');

      print('Determined hasSymptoms: $hasSymptoms');
      print('[DEBUG] Resultado del análisis: $hasSymptoms');
    } catch (e) {
      print('Error during symptom determination: $e');
      // Handle error gracefully, perhaps show a different message on ThankYouScreen
    } finally {
      // Cerrar el loader
      Navigator.of(context).pop();
    }

    _navigationCompleted = true;
    // Dismiss the loading indicator
    //Navigator.of(context).pop();
    /*
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ThankYouScreen(hasSymptoms: hasSymptoms)),
    );
    */
    /*
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThankYouScreen(hasSymptoms: hasSymptoms),
      ),
    );
    */
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThankYouScreen(
          hasSymptoms: hasSymptoms,
          drawingProbability: drawingProbability,
          audioProbability: audioProbability,
          combinedProbability: combinedProbability,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _pauseAudio() async {
    try {
      await _audioPlayer.pausePlayer();
      setState(() {
        _isPaused = true;
        _isPlaying = false;
      });
    } catch (e) {
      print('Error al pausar el audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al pausar el audio: $e')),
      );
    }
  }

  Future<void> _resumeAudio() async {
    try {
      if (_filePath != null && File(_filePath!).existsSync()) {
        await _audioPlayer.resumePlayer();
        setState(() {
          _isPaused = false;
          _isPlaying = true;
        });
      } else {
        throw Exception('Archivo de audio no encontrado en $_filePath');
      }
    } catch (e) {
      print('Error al reanudar la reproducción: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reanudar la reproducción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Prueba de Audio"),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 20),
              Text(
                "PRUEBA DE AUDIO (AUDIO TEST)",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  Text(
                    '$_currentLetter', // Mostrar letra
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Repetición: $_recordingCount de 3', // Mostrar contador de repetición
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Icon(Icons.mic, size: 100, color: Colors.black),
                  if (_isRecording)
                    Text(
                      "Tiempo: ${_formatDuration(_recordingDuration)}",
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isRecording ? null : _startRecording,
                              icon: Icon(Icons.mic),
                              label: Text("Grabar"),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isRecording ? _stopRecording : null,
                              icon: Icon(Icons.stop),
                              label: Text("Detener"),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  _isPlaying && !_isPaused ? _pauseAudio : null,
                              icon: Icon(Icons.pause),
                              label: Text("Pausar"),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isPaused
                                  ? _resumeAudio
                                  : (_isRecordingComplete ? _playAudio : null),
                              icon: Icon(Icons.play_arrow),
                              label: Text("Reproducir"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _startRecording,
                        child: Text("Regrabar"),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isRecordingComplete ? _nextLetter : null,
                        child: Text("Siguiente"),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ));
  }
}
