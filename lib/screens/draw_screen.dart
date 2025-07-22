import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:drawtesis/models/user_data.dart';
import 'package:drawtesis/screens/audio_recording_screen.dart';
import 'package:drawtesis/storage/user_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';

class DrawScreen extends StatefulWidget {
  final UserData user;
  const DrawScreen({super.key, required this.user});

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  final List<Offset?> _points = [];
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _saveDrawingAndNavigate() async {
    try {
      final folderPath = await UserStorage.getUserFolder(widget.user);
      final RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Could not access drawing canvas');

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final file = File('$folderPath/dibujo.png');
      await file.writeAsBytes(pngBytes);
      print('Imagen guardada en: ${file.path}');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioRecordingScreen(user: widget.user),
          ),
        );
      }
    } catch (e) {
      print('Error saving drawing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el dibujo: $e')),
        );
      }
    }
  }

  void _clearDrawing() {
    setState(() => _points.clear());
  }

  bool get _hasDrawing {
    return _points.any((point) => point != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- Custom Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back_ios, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Image.asset('assets/logo.png', height: 40),
                ],
              ),
              const SizedBox(height: 20),
              // --- Titles ---
              const Text(
                'PRUEBA DE LA ESPIRAL',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor, sigue la línea iniciando desde el centro.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // --- Drawing Area ---
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade200, width: 2),
                          ),
                          child: RepaintBoundary(
                            key: _globalKey,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanUpdate: (details) {
                                RenderBox box = _globalKey.currentContext!
                                    .findRenderObject() as RenderBox;
                                Offset localPosition =
                                    box.globalToLocal(details.globalPosition);
                                setState(() => _points.add(localPosition));
                              },
                              onPanEnd: (_) =>
                                  setState(() => _points.add(null)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                        child: Image.asset('assets/spiral.png',
                                            fit: BoxFit.contain)),
                                    CustomPaint(
                                        painter:
                                            _DrawingPainter(points: _points)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildSideButton(
                      icon: Icons.delete_outline,
                      label: 'LIMPIAR',
                      onPressed: _clearDrawing,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // --- "Next" Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasDrawing ? _saveDrawingAndNavigate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _hasDrawing ? const Color(0xFF6A1B9A) : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SIGUIENTE',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideButton(
      {required IconData icon,
      required String label,
      VoidCallback? onPressed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black54,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(20),
            elevation: 2,
            shadowColor: Colors.grey.withOpacity(0.2),
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  _DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
