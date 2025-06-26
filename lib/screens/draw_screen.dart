import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:drawtesis/screens/audio_recording_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

class DrawScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final String handUsed;
  final bool isDominant;

  DrawScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.handUsed,
    required this.isDominant,
  });

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<Offset?> _points = [];
  final GlobalKey _globalKey = GlobalKey();

  Future<String> _createUserFolder() async {
    final directory = Directory('/storage/emulated/0/Download');
    String folderName = "${widget.firstName}_${widget.lastName}";
    final userFolder = Directory('${directory.path}/$folderName');

    if (!await userFolder.exists()) {
      await userFolder.create(recursive: true);
    }
    return userFolder.path;
  }

  Future<void> _saveUserInfo(String folderPath) async {
    final file = File('$folderPath/user_info.txt');
    final content = """
      Nombre: ${widget.firstName}
      Apellido: ${widget.lastName}
      Género: ${widget.gender}
      Edad: ${widget.age}
      Mano utilizada: ${widget.handUsed}
      Es dominante: ${widget.isDominant ? "Si" : "No"}
      """;
    await file.writeAsString(content);
  }

  Future<void> _saveDrawing(BuildContext context) async {
    try {
      final folderPath = await _createUserFolder();
      await _saveUserInfo(folderPath);

      final RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(
            'Could not access the RenderRepaintBoundary context');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final fileName = 'dibujo.png';
      final filePath = '$folderPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      print('Image saved at: $filePath');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (innerContext) => AudioRecordingScreen(
            firstName: widget.firstName,
            lastName: widget.lastName,
            folderPath: folderPath,
          ),
        ),
      );
    } catch (e) {
      print('Error saving drawing: $e');
    }
  }

  void _clearDrawing() {
    setState(() => _points.clear());
  }
  
  // --- Helper widget for styled buttons (copied from AudioRecordingScreen) ---
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dibujar sobre la Espiral'),
        automaticallyImplyLeading: true, // <- enable back arrow
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'PRUEBA ASPIRAL (ASPIRAL TEST)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Por favor, sigue las líneas iniciando del centro para afuera',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Expanded(
                child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1, // Make it a square
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/spiral.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            RepaintBoundary(
                              key: _globalKey,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  RenderBox box = _globalKey.currentContext!
                                      .findRenderObject() as RenderBox;
                                  Offset localPosition =
                                      box.globalToLocal(details.globalPosition);

                                  if (localPosition.dx >= 0 &&
                                      localPosition.dy >= 0 &&
                                      localPosition.dx <= box.size.width &&
                                      localPosition.dy <= box.size.height) {
                                    setState(() {
                                      _points.add(localPosition);
                                    });
                                  }
                                },
                                onPanEnd: (_) => _points.add(null),
                                child: CustomPaint(
                                  painter: _DrawingPainter(points: _points),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- UPDATED: Using the helper method for the clear button ---
                    _buildSideButton(
                      icon: Icons.delete,
                      label: 'LIMPIAR',
                      onPressed: _clearDrawing,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            )),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _saveDrawing(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('SIGUIENTE', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
