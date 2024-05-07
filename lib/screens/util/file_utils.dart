import 'dart:io';
import 'package:path/path.dart' as path;

import '../widgets/ConfirmationDialog.dart';
import 'package:get/get.dart';

class FileUtils {
  static Future<void> createFile(
      String filePath, String fileContent, String projectPath,bool autoCreate) async {
    if (projectPath == null) {
      print('No project location path selected.');
      return;
    }

    String fullPath = getFullPath(projectPath!, filePath);
    bool shouldCreate = await shouldCreateFile(fullPath,autoCreate);

    if (shouldCreate) {
      await writeFileContent(fullPath, fileContent);
      print('File created: $fullPath');
    } else {
      print('File creation cancelled.');
    }
  }

  static Future<void> writeFileContent(String fullPath, String fileContent) async {
    try {
      Directory directory = Directory(path.dirname(fullPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      File file = File(fullPath);
      await file.writeAsString(fileContent);
    } catch (e) {
      print('Error creating file: $e');
    }
  }

  static String getFullPath(String parentPath, String filePath) {
    return path.join(parentPath, filePath);
  }

  static Future<bool> shouldCreateFile(String fullPath, bool autoCreate) async {
    if (autoCreate) {
      return true;
    } else {
      return await showCreateConfirmationDialog(fullPath);
    }
  }

  static Future<bool> showCreateConfirmationDialog(String filePath) async {
    bool? shouldCreate = await Get.dialog<bool>(
      ConfirmationDialog(fileName: filePath),
    );
    return shouldCreate ?? false;
  }

  static void processFileContent(String content,String projectPath,bool autoCreate) {
    List<String>? pathAndContent = preprocessContent(content);
    String filePath = pathAndContent?[0] ?? "";
    String fileContent = pathAndContent?[1] ?? "";
    createFile(filePath, fileContent,projectPath,autoCreate);
  }

  static List<String>? preprocessContent(String content) {
    List<String> lines = content.split('\n');

    if (lines.isEmpty) {
      print('Clipboard content is empty.');
      return null;
    }

    String firstLine = lines[0].trim();
    String filePath = firstLine.substring(3).trim();

    if (filePath.isEmpty) {
      print('No path found in the first line.');
      return null;
    }

    // Remove the first line from the content
    String fileContent = lines.skip(1).join('\n');
    return [filePath, fileContent];
  }
}
