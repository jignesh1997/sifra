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




 static  void generateImageConstants(String selectedPath) async {
    // Define the base paths
    final imagesBasePath = path.join(selectedPath, 'assets', 'images');
    final constantsFilePath = path.join(selectedPath, 'src', 'constants', 'imageconstants.js');

    print('Images base path: $imagesBasePath');
    print('Constants file path: $constantsFilePath');

    // Ensure the constants directory exists
    final constantsDirectory = Directory(path.dirname(constantsFilePath));
    if (!constantsDirectory.existsSync()) {
      constantsDirectory.createSync(recursive: true);
      print('Constants directory created.');
    }

    // Initialize the file with path constants
    final file = File(constantsFilePath);
    IOSink fileSink = file.openWrite();

    // Prepare to collect and organize image requires by type
    final Map<String, List<String>> imageRequires = {};

    // Traverse the images directory
    final imagesDirectory = Directory(imagesBasePath);
    if (imagesDirectory.existsSync()) {
      List<FileSystemEntity> folders = imagesDirectory.listSync();

      for (var folder in folders) {
        if (folder is Directory) {
          String folderName = path.basename(folder.path);
          String variableName = '${folderName}Path';
          String relativePath = '\'../assets/images/$folderName/\'';

          // Write the path variable
          fileSink.write('const $variableName = $relativePath;\n');

          // Prepare to collect image requires
          imageRequires[folderName.toUpperCase()] = [];

          // List image files in the directory
          List<FileSystemEntity> files = folder.listSync();
          for (var file in files) {
            if (file is File && !path.basename(file.path).startsWith('.')) {
              String fileName = path.basename(file.path);
              String imageName = path.basenameWithoutExtension(file.path);
              String requireString = '$imageName: require($variableName + \'$fileName\'),';

              // Collect image requires under the appropriate type
              imageRequires[folderName.toUpperCase()]?.add(requireString);
            }
          }
        }
      }

      // Ensure we add an empty line between path constants and image requires
      fileSink.write('\nexport default {\n');

      // Write out the image requires organized by type
      imageRequires.forEach((type, requires) {
        if (requires.isNotEmpty) {
          fileSink.write('  //${type}\n');
          requires.forEach((require) {
            fileSink.write('  $require\n');
          });
          fileSink.write('\n');
        }
      });

      fileSink.write('};\n');
    } else {
      print('Images directory does not exist.');
    }

    // Close the file sink
    await fileSink.flush();
    await fileSink.close();
    print('File write complete. Check $constantsFilePath');
  }



}
