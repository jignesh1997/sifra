import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../widgets/ConfirmationDialog.dart';

class AndroidController extends GetxController {
  // Observable variables
  RxString lastClipboardContent = ''.obs;
  RxBool isListening = false.obs;
  Rx<String?> selectedPath = Rx<String?>(null);
  RxBool autoCreateFile = true.obs;

  // Timer for periodic clipboard checks
  Timer? timer;

  @override
  void onClose() {
    stopMonitoringClipboard();
    super.onClose();
  }

  void startMonitoringClipboard() async {
    isListening.value = true;
    timer = Timer.periodic(Duration(seconds: 1), (_) => checkClipboardContent());
  }

  void stopMonitoringClipboard() {
    isListening.value = false;
    timer?.cancel();
  }

  void checkClipboardContent() async {
    String clipboardContent = await FlutterClipboard.paste();
    if (clipboardContent != lastClipboardContent.value) {
      lastClipboardContent.value = clipboardContent;
      List<String>? pathAndContent = preprocessContent(clipboardContent);
      if (pathAndContent != null) {
        String filePath = pathAndContent[0];
        String fileContent = pathAndContent[1];
        createFile(filePath, fileContent);
      }
    }
  }

  List<String>? preprocessContent(String content) {
    List<String> lines = content.split('\n');

    if (lines.isEmpty) {
      print('Clipboard content is empty.');
      return null;
    }

    String firstLine = lines[0].trim();

    if (!firstLine.startsWith('// ')) {
      print('First line does not contain a valid path.');
      return null;
    }

    String filePath = firstLine.substring(3).trim();

    if (filePath.isEmpty) {
      print('No path found in the first line.');
      return null;
    }

    // Remove the first line from the content
    String fileContent = lines.skip(1).join('\n');
    return [filePath, fileContent];
  }

  Future<void> createFile(String filePath, String fileContent) async {
    if (selectedPath.value == null) {
      print('No project location path selected.');
      return;
    }

    try {
      String parentPath = selectedPath.value!;
      String fullPath = path.join(parentPath, filePath);

      // Create the directory if it doesn't exist
      Directory directory = Directory(path.dirname(fullPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create the file and write the content
      File file = File(fullPath);

      if (autoCreateFile.value) {
        // Create the file automatically
        await file.writeAsString(fileContent);
        print('File created: $fullPath');
      } else {
        // Show a confirmation dialog with the file name
        bool shouldCreate = await showCreateConfirmationDialog(filePath);
        if (shouldCreate) {
          await file.writeAsString(fileContent);
          print('File created: $fullPath');
        } else {
          print('File creation cancelled.');
        }
      }
    } catch (e) {
      print('Error creating file: $e');
    }
  }

  Future<bool> showCreateConfirmationDialog(String filePath) async {
    bool? shouldCreate = await Get.dialog<bool>(
      ConfirmationDialog(fileName: filePath),
    );
    return shouldCreate ?? false;
  }

  Future<void> showPathPickerDialog() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      selectedPath.value = path;
    }
  }

  void toggleAutoCreateFile(bool value) {
    autoCreateFile.value = value;
  }
}