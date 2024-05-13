import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sifra/screens/base_sifra_controller.dart';

import '../util/script_utils.dart';

class ClipboardController extends BaseSifraController {
  @override
  void processClipboardContent(String content) {

  }

  Rx<String?> scriptPath = Rx<String?>(null);

  void executeScript() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sh'],
    );

    if (result != null && result.files.single.path != null) {
      scriptPath.value = result.files.single.path!;
      executeShellScript(scriptPath.value!);
    }
  }
}