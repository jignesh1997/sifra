import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:sifra/screens/util/extensions.dart';

class FlutterDeveloperController extends GetxController {
  Future<void> generateImageConstants() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      Directory directory = Directory(selectedDirectory);
      List<FileSystemEntity> files = directory.listSync(recursive: true);

      List<String> imageConstants = [];

      for (FileSystemEntity file in files) {
        if (file is File) {
          String extension = path.extension(file.path).toLowerCase();
          if (extension == '.png' || extension == '.jpg' || extension == '.jpeg' || extension == '.svg') {
            String fileName = path.basenameWithoutExtension(file.path);
            String constantName = _generateConstantName(fileName, extension);
            String constantValue = path.relative(file.path, from: 'lib');

            imageConstants.add("static const String $constantName = '$constantValue';");
          }
        }
      }

      _appendImageConstants(imageConstants);
    }
  }

  String _generateConstantName(String fileName, String extension) {
    String constantName = fileName.toSnakeCase();

    if (extension == '.svg') {
      return 'icIcon$constantName';
    } else {
      return 'imgImage$constantName';
    }
  }

  void _appendImageConstants(List<String> imageConstants) {
    String filePath = 'lib/resource_constant/image_constant.dart';
    File file = File(filePath);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    String fileContent = file.readAsStringSync();

    StringBuffer buffer = StringBuffer();
    buffer.writeln(fileContent.trimRight());
    buffer.writeln();

    for (String constant in imageConstants) {
      buffer.writeln(constant);
    }

    file.writeAsStringSync(buffer.toString());
  }
}