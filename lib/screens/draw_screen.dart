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

  // Constructor modificado con parámetros nombrados requeridos
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

/*
  Future<void> _saveToStorage() async {
    try {
      // Obtiene el widget para capturar la imagen
      final RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(
            'No se pudo acceder al contexto del RenderRepaintBoundary');
      }
      //RenderRepaintBoundary boundary = _globalKey.currentContext!
      //    .findRenderObject() as RenderRepaintBoundary;
      final ui.Image originalImage = await boundary.toImage(pixelRatio: 3.0);
      final ui.Size size = boundary.size;

      // Crea un recorder para dibujar en un nuevo Canvas
      final recorder = ui.PictureRecorder();
      final canvas =
          Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));

      // Pinta el fondo blanco
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white,
      );
      // Dibuja la imagen original (los puntos)
      final paint = Paint();
      canvas.drawImage(originalImage, Offset.zero, paint);

      // Renderiza la imagen final
      final ui.Picture picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      ByteData? byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Guarda la imagen localmente
      //final directory = await getApplicationDocumentsDirectory();
      final directory = Directory('/storage/emulated/0/Download');
      String fileName =
          "${widget.userName}_${widget.gender}_${widget.age}_${widget.handUsed}_${widget.isDominant ? 'Dominante' : 'NoDominante'}.png";
      File imgFile = File('${directory.path}/$fileName');
      //await imgFile.writeAsBytes(pngBytes);

      await _saveToDownloads(pngBytes,
          "${widget.userName}_${widget.gender}_${widget.age}_${widget.handUsed}_${widget.isDominant ? 'Dominante' : 'NoDominante'}.png");
      print('Imagen guardada en: ${imgFile.path}');
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagen guardada: $fileName')),
      );
    */
      print('Imagen guardada');
    } catch (e) {
      print('Error al guardar la imagen: $e');
      /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la imagen: $e')),
      );
      */
    }
  }
  */

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

      /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dibujo guardado en: $filePath')),
      );
      */
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
      /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el dibujo: $e')),
      );
      */
    }
  }

  void _clearDrawing() {
    setState(() => _points.clear());
  }

  @override
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
