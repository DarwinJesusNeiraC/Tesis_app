import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:drawtesis/models/user_data.dart';
import 'package:permission_handler/permission_handler.dart';

class UserStorage {
  static Future<bool> _requestPermissions() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }
    return status.isGranted;
  }

  static Future<String?> getUserFolder(UserData user) async {
    if (!await _requestPermissions()) {
      print("Permiso de MANAGE_EXTERNAL_STORAGE denegado.");
      return null;
    }
    try {
      final Directory? baseDir = Directory('/storage/emulated/0/Download');
      if (baseDir == null) {
        print("Error: No se pudo acceder a la carpeta de Descargas.");
        return null;
      }

      final String appFolderName = 'DrawTesis_Recordings';
      final String userFolderName =
          '${user.id}_${user.firstName}_${user.lastName}';

      final String path = '${baseDir.path}/$appFolderName/$userFolderName';

      final Directory userDir = Directory(path);
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }

      return path;
    } catch (e) {
      print("Error en getUserFolder: $e");
      return null;
    }
  }

  /// Guarda un archivo temporal con un nombre específico dentro del folder del usuario
  static Future<File?> createAudioFile({
    required UserData user,
    required String letter,
    required int repetition,
  }) async {
    final folder = await getUserFolder(user);
    if (folder == null) return null;
    final fileName = 'audio_${letter}_$repetition.wav';
    final fullPath = '$folder/$fileName';
    return File(fullPath);
  }

  /// Ruta del dibujo
  static Future<String?> getDrawingPath(UserData user) async {
    final folder = await getUserFolder(user);
    if (folder == null) return null;
    return '$folder/espiral_1.png';
  }

  /// Verifica si un archivo ya existe (por ejemplo, para evitar sobrescribir)
  static Future<bool> audioFileExists({
    required UserData user,
    required String letter,
    required int repetition,
  }) async {
    final file = await createAudioFile(
        user: user, letter: letter, repetition: repetition);
    if (file == null) return false;
    return await file.existsSync();
  }

  static Future<void> saveUserData(UserData user) async {
    try {
      final folderPath = await getUserFolder(user);
      if (folderPath == null) {
        print(
            "Error: No se pudo obtener la carpeta para guardar los datos del usuario.");
        return;
      }
      final File file = File('$folderPath/user_data.json');
      // Convierte el objeto a un String JSON
      final String jsonString = jsonEncode(user.toJson());
      // Escribe el string en el archivo
      await file.writeAsString(jsonString);
      print("Datos del usuario guardados exitosamente en: ${file.path}");
    } catch (e) {
      print("Ocurrió un error al guardar los datos del usuario: $e");
    }
  }
}
