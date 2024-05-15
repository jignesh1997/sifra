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
  static String _extractPath(String content, String pathVariable) {
    RegExp regExp = RegExp('const $pathVariable = \'(.*)\';');
    Match? match = regExp.firstMatch(content);
    return match?.group(1) ?? '';
  }

  static String _generateConstantName(String fileName) {
    return fileName.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join();
  }

  static void generateImageConstantsFile(String selectedProjectPath) {
    try {
      String imageConstantsFilePath = path.join(selectedProjectPath, 'src', 'constants', 'images.tsx');

      // Create the file if it doesn't exist
      if (!File(imageConstantsFilePath).existsSync()) {
        String initialContent = '''
const pngPath = '../assets/images/png/';
const gifPath = '../assets/images/gif/';
export default {
  //PNG
  
  //GIF
  
};
''';
        File(imageConstantsFilePath).writeAsStringSync(initialContent);
      }

      // Read the existing imageConstants.js file
      String imageConstantsContent = File(imageConstantsFilePath).readAsStringSync();

      // Extract pngPath and gifPath from the file
      String pngPath = _extractPath(imageConstantsContent, 'pngPath');
      String gifPath = _extractPath(imageConstantsContent, 'gifPath');

      // Find the position to insert PNG constants
      int pngInsertPosition = imageConstantsContent.indexOf('  //PNG') + '  //PNG'.length;

      // Find the position to insert GIF constants
      int gifInsertPosition = imageConstantsContent.indexOf('  //GIF') + '  //GIF'.length;

      // Read PNG image files
      Directory pngDirectory = Directory(path.join(selectedProjectPath, pngPath));
      List<FileSystemEntity> pngFiles = pngDirectory.listSync();

      // Generate PNG constants
      String pngConstants = '';
      for (FileSystemEntity pngFile in pngFiles) {
        if (pngFile is File && path.extension(pngFile.path) == '.png') {
          String pngFileName = path.basenameWithoutExtension(pngFile.path);
          String constantName = _generateConstantName(pngFileName);
          pngConstants += '  $constantName: require(pngPath + \'$pngFileName.png\'),\n';
        }
      }

      // Insert PNG constants
      imageConstantsContent = imageConstantsContent.replaceRange(
        pngInsertPosition,
        pngInsertPosition,
        '\n$pngConstants',
      );

      // Read GIF image files
      Directory gifDirectory = Directory(path.join(selectedProjectPath, gifPath));
      List<FileSystemEntity> gifFiles = gifDirectory.listSync();

      // Generate GIF constants
      String gifConstants = '';
      for (FileSystemEntity gifFile in gifFiles) {
        if (gifFile is File && path.extension(gifFile.path) == '.gif') {
          String gifFileName = path.basenameWithoutExtension(gifFile.path);
          String constantName = _generateConstantName(gifFileName);
          gifConstants += '  $constantName: require(gifPath + \'$gifFileName.gif\'),\n';
        }
      }

      // Insert GIF constants
      imageConstantsContent = imageConstantsContent.replaceRange(
        gifInsertPosition,
        gifInsertPosition,
        '\n$gifConstants',
      );

      // Write the updated imageConstants.js file
      File(imageConstantsFilePath).writeAsStringSync(imageConstantsContent);

      print('Image constants generated successfully.');
    } catch (e) {
      print('Error generating image constants: $e');
    }
  }


}
