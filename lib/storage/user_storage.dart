import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:drawtesis/models/user_data.dart';

class UserStorage {
  /// Obtiene el directorio raíz para guardar archivos de usuario.
  static Future<String> getUserFolder(UserData user) async {
    final Directory baseDir = await getApplicationDocumentsDirectory();
    final String userFolderName =
        '${user.id}_${user.firstName}_${user.lastName}';
    final String path = '${baseDir.path}/$userFolderName';

    final Directory userDir = Directory(path);
    if (!userDir.existsSync()) {
      await userDir.create(recursive: true);
    }

    return path;
  }

  /// Guarda un archivo temporal con un nombre específico dentro del folder del usuario
  static Future<File> createAudioFile({
    required UserData user,
    required String letter,
    required int repetition,
  }) async {
    final folder = await getUserFolder(user);
    final fileName = 'audio_${letter}_$repetition.wav';
    final fullPath = '$folder/$fileName';
    return File(fullPath);
  }

  /// Ruta del dibujo
  static Future<String> getDrawingPath(UserData user) async {
    final folder = await getUserFolder(user);
    return '$folder/dibujo.png';
  }

  /// Verifica si un archivo ya existe (por ejemplo, para evitar sobrescribir)
  static Future<bool> audioFileExists({
    required UserData user,
    required String letter,
    required int repetition,
  }) async {
    final file = await createAudioFile(
        user: user, letter: letter, repetition: repetition);
    return file.existsSync();
  }
}
