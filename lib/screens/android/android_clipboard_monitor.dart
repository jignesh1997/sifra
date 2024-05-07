import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:sifra/screens/util/extensions.dart';
import 'package:sifra/screens/util/file_utils.dart';
import 'package:sifra/screens/util/string_utils.dart';
import '../util/color_utils.dart';
import '../util/mis_util.dart';
import '../widgets/ConfirmationDialog.dart';
import '../widgets/color_name_dialog.dart';

class AndroidController extends GetxController {
  // Observable variables
  RxString lastClipboardContent = ''.obs;
  RxBool isListening = false.obs;
  Rx<String?> selectedPath = Rx<String?>(null);
  RxBool autoCreateFile = true.obs;
  RxBool autoCreateColor = false.obs;
  RxBool autoCreateString = true.obs;

  RxString selectedScriptPath = ''.obs;


  // Timer for periodic clipboard checks
  Timer? timer;

  @override
  void onClose() {
    stopMonitoringClipboard();
    super.onClose();
  }

  void startMonitoringClipboard() async {
    isListening.value = true;
    timer = Timer.periodic(Duration(milliseconds: 400), (_) => checkClipboardContent());
  }

  void stopMonitoringClipboard() {
    isListening.value = false;
    timer?.cancel();
  }

  void checkClipboardContent() async {
    String clipboardContent = await FlutterClipboard.paste();
    if (clipboardContent != lastClipboardContent.value) {
      lastClipboardContent.value = clipboardContent;
      processClipboardContent(clipboardContent);
    }
  }

  void processClipboardContent(String content) {
    List<String> lines = content.split('\n');
    print("ClipboardContent::::$content");

    if (lines[0].isValidColor()) {
      print("ClipboardContent::::Is valid");
      String colorString = lines[0].trim();
      processColorString(colorString,autoCreateColor.value,selectedPath.value!);
    } else if (lines[0]?.startsWith('// ') == true) {
      FileUtils.processFileContent(content,selectedPath.value!,autoCreateFile.value);
    } else {
       processStringContent(content);
    }
  }

  void processStringContent(String content) async {
    if (autoCreateString.value) {
      String generatedStringName = stringContentToStringName(content);
      addStringToAndroidStringsFile(selectedPath.value!, content,generatedStringName);
    } else {
      String generatedStringName = stringContentToStringName(content);
      await showStringNameDialog(content, generatedStringName,selectedPath.value!);
    }
  }
/*  void checkClipboardContent() async {
    String clipboardContent = await FlutterClipboard.paste();
    if (clipboardContent != lastClipboardContent.value) {
      lastClipboardContent.value = clipboardContent;
      List<String> lines =    lastClipboardContent.split('\n');
      print("ClipboardContent::::${clipboardContent}");
      if (lines[0].isValidColor()==true) {
        print("ClipboardContent::::Is valid");

        String colorString = lines[0].trim();

        // Add '#' symbol if not present
        if (!colorString.startsWith('#')) {
          colorString = '#$colorString';
        }

        processForColorFound(colorString);
      }
      else if (lines[0]?.startsWith('// ')==true) {
        List<String>? pathAndContent = preprocessContent(clipboardContent);

        String filePath = pathAndContent?[0] ?? "";
        String fileContent = pathAndContent?[1] ?? "";
        createFile(filePath, fileContent);

      }
      else{
        if (autoCreateString.value) {
          addStringToAndroidStringsFile(selectedPath.value!,clipboardContent);
        } else {
          String generatedStringName = stringContentToStringName(clipboardContent);

          await Get.dialog(
            InputNameDialog(
              content: clipboardContent,
              generatedName: generatedStringName,
              title: 'Enter String Name',
              labelText: 'String Name',
              onConfirm: (stringName) {
                addStringToAndroidStringsFile(selectedPath.value!,clipboardContent);
              },
            ),
          );
        }
      }
    }
  }*/



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

  void toggleAutoCreateColor(bool value) {
    autoCreateColor.value = value;
  }




}