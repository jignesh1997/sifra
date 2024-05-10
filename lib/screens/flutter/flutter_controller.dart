import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:sifra/screens/base_sifra_controller.dart';
import 'package:sifra/screens/util/extensions.dart';
import 'package:sifra/screens/util/image_constant_generato_helper.dart';

import '../util/file_utils.dart';

class FlutterDeveloperController extends BaseSifraController {
  Rx<String?> selectedPathImageConstant = Rx<String?>(null);
  @override
  void processClipboardContent(String content) {
    List<String> lines = content.split('\n');
    if (lines[0]?.startsWith('// ') == true) {
      FileUtils.processFileContent(content,selectedPath.value!,autoCreateFile.value);
    } else {
      //processStringContent(content);
    }
  }

  void onGenerateConstants() {
    ImageConstantGeneratorHelper.generateConstants(selectedPathImageConstant.value ?? "");
  }
}