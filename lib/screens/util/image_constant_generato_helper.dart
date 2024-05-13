import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sifra/screens/util/file_utils.dart';
import 'package:sifra/screens/util/mis_util.dart';
class ImageConstantGeneratorHelper {

  static Future<void> generateConstants(String projectPath) async {

    var innerPath="assets/images/";
      Directory directory = Directory("$projectPath/$innerPath");
      if(await directory.exists()!=true){
        showErrorToast("asset directory does not exists");
        return;
      }
      List<FileSystemEntity> files = directory.listSync();

      List<String> imageConstants = [];

      for (FileSystemEntity file in files) {
        if (file is File) {
          String extension = path.extension(file.path).toLowerCase();
          if (extension == '.png' || extension == '.jpg' ||
              extension == '.jpeg' || extension == '.svg' ) {
            String iconPrefix= extension==".svg"  ? "ic" : "img";
            String fileName = path.basenameWithoutExtension(file.path);
            String constantName = '$iconPrefix${fileName.pascalCase}';
            String constantValue = innerPath+path.basename(file.path);

            imageConstants.add(
                "static const String $constantName = '$constantValue';");
          }
        }
      }
      String dartClass = '''
      class ImageConstants {
      ${imageConstants.join('\n')}
      }
      ''';
      FileUtils.createFile("lib/constant/image_constant.dart", dartClass, projectPath, true);
      showSuccessToast('Image constants generated successfully!');
    }

}
extension StringExtension on String {
  String get pascalCase => split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join();
}