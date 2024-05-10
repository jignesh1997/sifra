import 'dart:io';
import 'package:path/path.dart' as path;
class ImageConstantGeneratorHelper {

  static Future<void> generateConstants(String selectedPath) async {
    if (selectedPath.isNotEmpty) {
      Directory directory = Directory(selectedPath);
      List<FileSystemEntity> files = directory.listSync();

      List<String> imageConstants = [];

      for (FileSystemEntity file in files) {
        if (file is File) {
          String extension = path.extension(file.path).toLowerCase();
          if (extension == '.png' || extension == '.jpg' ||
              extension == '.jpeg') {
            String fileName = path.basenameWithoutExtension(file.path);
            String constantName = 'kIcon${fileName.pascalCase}';
            String constantValue = path.basename(file.path);

            imageConstants.add(
                "static const String $constantName = '$constantValue';");
          }
        }
      }
    }
  }
}
extension StringExtension on String {
  String get pascalCase => split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join();
}