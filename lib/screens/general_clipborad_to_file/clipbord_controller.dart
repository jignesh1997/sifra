import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sifra/screens/base/base_sifra_controller.dart';

import '../util/file_utils.dart';
import '../util/script_utils.dart';

class ClipboardController extends BaseSifraController {

  @override
  void processClipboardContent(String content) {
    List<String> lines = content.split('\n');
    if (lines[0]?.startsWith('// ') == true) {
      FileUtils.processFileContent(content,selectedPath.value!,autoCreateFile.value);
    } else {

    }
  }

}