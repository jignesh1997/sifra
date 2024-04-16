import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class ClipboardController extends GetxController {
  RxString lastClipboardContent = ''.obs;
  RxBool isListening = false.obs;
  Rx<String?> selectedPath = Rx<String?>(null);
  Timer? timer;

  @override
  void onClose() {
    stopMonitoringClipboard();
    super.onClose();
  }

  void startMonitoringClipboard() async {
    isListening.value = true;
    timer = Timer.periodic(Duration(milliseconds: 500), (_) => checkClipboardContent());
  }

  void stopMonitoringClipboard() {
    isListening.value = false;
    timer?.cancel();
  }

  void checkClipboardContent() async {
    String clipboardContent = await FlutterClipboard.paste();
    if (clipboardContent != lastClipboardContent.value) {
      lastClipboardContent.value = clipboardContent;
      createFile(lastClipboardContent.value);
    }
  }


  Future<void> createFile(String content) async {
    if (selectedPath.value == null) {
      print('No project location path selected.');
      return;
    }

    try {
      List<String> lines = content.split('\n');
      String subPath = '';

      // Find the line starting with "// " and extract the subpath
      for (String line in lines) {
        if (line.startsWith('// ')) {
          subPath = line.substring(3).trim();
          break;
        }
      }

      if (subPath.isEmpty) {
        print('No subpath found in the clipboard content.');
        return;
      }

      String parentPath = selectedPath.value!;
      String filePath = path.join(parentPath, subPath);

      // Create the directory if it doesn't exist
      Directory directory = Directory(path.dirname(filePath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create the file and write the content (excluding the subpath line)
      File file = File(filePath);
      String fileContent = lines.where((line) => !line.startsWith('// ')).join('\n');
      await file.writeAsString(fileContent);

      print('File created: $filePath');
    } catch (e) {
      print('Error creating file: $e');
    }
  }



  Future<void> showPathPickerDialog() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      selectedPath.value = path;
    }
  }
}