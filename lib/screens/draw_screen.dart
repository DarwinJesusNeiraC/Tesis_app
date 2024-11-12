import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/rendering.dart';

/*
class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<Offset?> _points = [];
  GlobalKey _globalKey = GlobalKey();

  Future<void> _saveToStorage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      File imgFile = File('$directory/$fileName');
      await imgFile.writeAsBytes(pngBytes);

      // Subir a Firebase Storage
      await FirebaseStorage.instance
          .ref('drawings/$fileName')
          .putFile(imgFile)
          .catchError((error) {
        print("Error al subir el archivo: $error");
      });
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Imagen guardada exitosamente')));
    } catch (e) {
      print('Error al guardar imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dibujar sobre la Espiral'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveToStorage,
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/spiral.png', fit: BoxFit.cover),
          ),
          RepaintBoundary(
            key: _globalKey,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  _points.add(renderBox.globalToLocal(details.globalPosition));
                });
              },
              onPanEnd: (details) {
                _points.add(null); // Marca el final de una línea
              },
              child: CustomPaint(
                painter: _DrawingPainter(points: _points),
                child: Container(),
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
      ..strokeWidth = 8.0;

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
*
class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<Offset?> _points = [];
  GlobalKey _globalKey = GlobalKey();

  Future<void> _saveToStorage() async {
    // Código para guardar la imagen (sin cambios)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dibujar sobre la Espiral'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveToStorage,
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              width: 300, // Cambia el tamaño aquí
              height: 300, // Cambia el tamaño aquí
              child: Image.asset('assets/spiral.png', fit: BoxFit.contain),
            ),
          ),
          RepaintBoundary(
            key: _globalKey,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);
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
              child: CustomPaint(
                painter: _DrawingPainter(points: _points),
                child: Container(),
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
      ..strokeWidth = 8.0;

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
*/
class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  List<Offset?> _points = [];
  GlobalKey _globalKey = GlobalKey();

  Future<void> _saveToStorage() async {
    // Código para guardar la imagen (sin cambios)
  }

  void _clearDrawing() {
    setState(() {
      _points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dibujar sobre la Espiral'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveToStorage,
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
