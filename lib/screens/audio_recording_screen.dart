import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart'; //audioplayers package
import 'package:drawtesis/helpers/symptom_helper.dart';
import 'package:drawtesis/models/user_data.dart';
import 'package:drawtesis/screens/thank_you_screen.dart';
import 'package:drawtesis/services/prediction_service.dart';
import 'package:drawtesis/services/symptom_detection_service.dart';
import 'package:drawtesis/storage/user_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingScreen extends StatefulWidget {
  final UserData user;

  const AudioRecordingScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AudioRecordingScreenState createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  // --- Sound and Service Instances ---
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  final AudioPlayer _examplePlayer = AudioPlayer(); // Player for example sounds
  late final SymptomHelper _symptomHelper;

  // --- State Management ---
  bool _isRecording = false;
  bool _isRecordingComplete = false;
  bool _navigationCompleted = false; // Prevents duplicate API calls on dispose
  String _currentLetter = "A";
  int _recordingCount = 1; // Repetition counter (1, 2, or 3)
  String? _filePath;
  final List<String> _recordedAudioPaths =
      []; // Stores paths for all recordings

  final List<String> _letters = ["A", "E", "I", "O", "U"];
  int _currentIndex = 0;

  // --- Recording Timer ---
  Timer? _recordingTimer;
  int _recordingDuration = 0; // Duration in seconds

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initPlayer();
    _symptomHelper =
        SymptomHelper(SymptomDetectionService(PredictionService()));
    //_symptomDetectionService = SymptomDetectionService(PredictionService());
  }

  @override
  void dispose() {
    if (!_navigationCompleted) {
      print(
          'DEBUG: AudioRecordingScreen is disposing. API calls will NOT be made if navigation did not complete.');
    }
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    _examplePlayer.dispose(); // Dispose the example player
    _recordingTimer?.cancel();
    super.dispose();
  }

  // --- Initialization Methods ---
  Future<void> _initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission denied');
    }
    await _audioRecorder.openRecorder();
  }

  Future<void> _initPlayer() async {
    await _audioPlayer.openPlayer();
  }

  // --- NEW: Function to play example audio ---
  Future<void> _playExampleSound() async {
    try {
      // Assumes audio files are in 'assets/audio/' and named like 'A.wav', 'E.wav', etc.
      String assetPath = 'audio/${_currentLetter}.wav';
      await _examplePlayer.play(AssetSource(assetPath));
    } catch (e) {
      print("Error playing example sound: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play example audio: $e')),
      );
    }
  }

  // --- Core Audio Logic ---
  Future<void> _startRecording() async {
    try {
      // Defines the file path for the new recording.
      String fileName =
          'audio_${widget.user.firstName}_${widget.user.lastName}_${_currentLetter}_$_recordingCount.wav';
      String folderPath = await UserStorage.getUserFolder(widget.user);
      String path = '$folderPath/$fileName';

      setState(() {
        _filePath = path;
        // Reset completion status for the new recording.
        _isRecordingComplete = false;
      });

      await _audioRecorder.startRecorder(toFile: path, codec: Codec.pcm16WAV);

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      // Start a timer to automatically stop the recording after 2 seconds.
      _recordingTimer?.cancel(); // Cancel any existing timer.
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });

        if (_recordingDuration >= 2) {
          _stopRecording();
        }
      });
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      _recordingTimer?.cancel();

      setState(() {
        _isRecording = false;
        _isRecordingComplete = true; // Mark recording as complete.
      });

      // Add the file path to our list for final analysis.
      if (_filePath != null && !_recordedAudioPaths.contains(_filePath)) {
        _recordedAudioPaths.add(_filePath!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio saved successfully: $_filePath')),
      );
    } catch (e) {
      print('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  Future<void> _playAudio() async {
    // This button is disabled if recording isn't complete, so this check is a safeguard.
    if (!_isRecordingComplete || _filePath == null) return;

    try {
      if (File(_filePath!).existsSync()) {
        await _audioPlayer.startPlayer(
          fromURI: _filePath,
          whenFinished: () {
            // You can add logic here for when playback finishes if needed.
            setState(() {});
          },
        );
      } else {
        throw Exception('Audio file not found at $_filePath');
      }
    } catch (e) {
      print('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  // --- Navigation Logic ---

  /// Moves to the next repetition or the next letter.
  void _nextStep() {
    setState(() {
      // We have 3 repetitions per letter.
      if (_recordingCount < 1) {
        _recordingCount++;
      } else {
        // Move to the next letter if available.
        if (_currentIndex < _letters.length - 1) {
          _currentIndex++;
          _currentLetter = _letters[_currentIndex];
          _recordingCount = 1; // Reset repetition count for the new letter.
        } else {
          // All letters and repetitions are done, navigate to results.
          _navigateToThankYouScreen();
          return;
        }
      }
      // Reset the state for the next recording.
      _isRecordingComplete = false;
      _filePath = null;
    });
  }

  /// Navigates to the results screen after processing the data.
  Future<void> _navigateToThankYouScreen() async {
    // Show a loading indicator while processing.
    final String folderPath = await UserStorage.getUserFolder(widget.user);
    final String drawingImagePath = '$folderPath/dibujo.png';
    final List<String> allAudioPaths = _recordedAudioPaths;
    await _symptomHelper.analyzeAndNavigate(
      context: context,
      drawingPath: drawingImagePath,
      audioPaths: allAudioPaths,
    );
  }

  // --- Helper Methods ---
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // --- Build Method for UI ---
  @override
  Widget build(BuildContext context) {
    // Determines if the main action buttons should be enabled.
    final bool canInteract = !_isRecording;
    final bool canProceed = _isRecordingComplete && canInteract;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prueba de Audio"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "PRUEBA DE AUDIO (AUDIO TEST)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Main content area
            Expanded(
              child: Row(
                children: [
                  // Central display box
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${_currentLetter * 7}...",
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Repetición: $_recordingCount de 3',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Icon(
                            Icons.mic,
                            size: 80,
                            // Animate color when recording
                            color:
                                _isRecording ? Colors.redAccent : Colors.black,
                          ),
                          if (_isRecording)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                "Grabando... ${_formatDuration(_recordingDuration)}",
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Side action buttons
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSideButton(
                        icon: Icons.lightbulb_outline,
                        label: 'EJEMPLO',
                        // UPDATED: Now calls the function to play example audio
                        onPressed: _playExampleSound,
                      ),
                      const SizedBox(height: 20),
                      _buildSideButton(
                        icon: Icons.mic,
                        label: _isRecordingComplete ? 'REGRABAR' : 'GRABAR',
                        onPressed: canInteract ? _startRecording : null,
                      ),
                      const SizedBox(height: 20),
                      _buildSideButton(
                        icon: Icons.play_arrow,
                        label: 'REPRODUCIR',
                        onPressed: canProceed ? _playAudio : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Bottom "Next" button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canProceed ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A), // Purple color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "SIGUIENTE",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A helper widget to create the styled side buttons.
  Widget _buildSideButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(16),
            elevation: 0,
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
