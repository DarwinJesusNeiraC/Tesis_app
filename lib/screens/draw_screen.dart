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
  GlobalKey _globalKey = GlobalKey();

  Future<String> _createUserFolder() async {
    final directory = Directory('/storage/emulated/0/Download');
    String folderName = "${widget.firstName}_${widget.lastName}";
    final userFolder = Directory('${directory.path}/$folderName');

    if (!userFolder.existsSync()) {
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

  Future<void> _saveToDownloads(Uint8List bytes, String fileName) async {
    // Verificar permiso para Android
    if (await Permission.storage.request().isGranted) {
      final dir = Directory('/storage/emulated/0/Download');
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      print('Archivo guardado en ${file.path}');
    } else {
      throw Exception('No se otorgaron permisos de almacenamiento.');
    }
  }

  Future<void> _saveDrawing(BuildContext context) async {
    try {
      final folderPath = await _createUserFolder();
      await _saveUserInfo(folderPath);

      final RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(
            'No se pudo acceder al contexto del RenderRepaintBoundary');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final fileName = 'dibujo.png';
      final filePath = '$folderPath/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      print('Imagen guardada en: $filePath');

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
      print('Error al guardar el dibujo: $e');
    }
  }

  void _clearDrawing() {
    setState(() => _points.clear());
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dibujar sobre la Espiral'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveDrawing(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearDrawing,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              width: 300, // Ajusta el tamaño aquí
              height: 300, // Ajusta el tamaño aquí
              child: Image.asset('assets/spiral.png', fit: BoxFit.contain),
            ),
          ),
          RepaintBoundary(
            key: _globalKey,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = _globalKey.currentContext!
                      .findRenderObject() as RenderBox;

                  // Ajusta el cálculo de la posición
                  Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);

                  // Asegúrate de que las coordenadas estén dentro del límite
                  if (localPosition.dx >= 0 &&
                      localPosition.dy >= 0 &&
                      localPosition.dx <= renderBox.size.width &&
                      localPosition.dy <= renderBox.size.height) {
                    _points.add(localPosition);
                  }
                });
              },
              onPanEnd: (details) {
                _points.add(null); // Marca el final de una línea
              },
              child: Container(
                width:
                    800, // Asegúrate de que coincida con el tamaño de la imagen
                height:
                    800, // Asegúrate de que coincida con el tamaño de la imagen
                child: CustomPaint(
                  painter: _DrawingPainter(points: _points),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dibujar sobre la Espiral'),
        automaticallyImplyLeading: true, // <- habilita la flecha
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
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
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
                    /*ElevatedButton.icon(
                      onPressed: () => _saveDrawing(context),
                      icon: Icon(Icons.save),
                      label: Text('GUARDAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(120, 50),
                      ),
                    ),
                    */
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _clearDrawing,
                      icon: Icon(Icons.delete),
                      label: Text('LIMPIAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size(120, 50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            )),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _saveDrawing(context),
              child: const Text('SIGUIENTE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[800],
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
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
