import 'dart:io';
import 'package:path/path.dart' as path;

class FileUtils {
  static Future<void> createFile(String filePath, String fileContent) async {
    try {
      String fullPath = filePath;

      // Create the directory if it doesn't exist
      Directory directory = Directory(path.dirname(fullPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create the file and write the content
      File file = File(fullPath);
      await file.writeAsString(fileContent);
      print('File created: $fullPath');
    } catch (e) {
      print('Error creating file: $e');
    }
  }
}