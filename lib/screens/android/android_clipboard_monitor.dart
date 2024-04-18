import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sifra/screens/util/extensions.dart';


import '../widgets/ConfirmationDialog.dart';
import '../widgets/color_name_dialog.dart';

class AndroidController extends GetxController {
  // Observable variables
  RxString lastClipboardContent = ''.obs;
  RxBool isListening = false.obs;
  Rx<String?> selectedPath = Rx<String?>(null);
  RxBool autoCreateFile = true.obs;
  RxBool autoCreateColor = false.obs;

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
      List<String> lines =    lastClipboardContent.split('\n');
      print("ClipboardContent::::${clipboardContent}");
      if (lines[0].isValidColor()==true) {
        print("ClipboardContent::::Is valid");
       processForColorFound(lines[0]!.trim());
      }
      else if (lines[0]?.startsWith('// ')==true) {
        List<String>? pathAndContent = preprocessContent(clipboardContent);

        String filePath = pathAndContent?[0] ?? "";
        String fileContent = pathAndContent?[1] ?? "";
        createFile(filePath, fileContent);

      }
      else{
        print("ClipboardContent::::in Else");
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

  void toggleAutoCreateColor(bool value) {
    autoCreateColor.value = value;
  }

  Future<void> addColorToColorsFile(String colorName, String colorValue) async {
    if (selectedPath.value == null) {
      showErrorToast('No project location path selected.');
      return;
    }

    try {
      String colorsFilePath = path.join(selectedPath.value!, 'app', 'src', 'main', 'res', 'values', 'colors.xml');

      // Check if colors.xml file exists
      if (!await File(colorsFilePath).exists()) {
        showErrorToast('colors.xml file not found.');
        return;
      }

      // Read the existing colors.xml file
      String colorsFileContent = await File(colorsFilePath).readAsString();

      // Check if the color entry already exists
      if (colorsFileContent.contains('<color name="$colorName">$colorValue</color>')) {
        showErrorToast('Color entry already exists.');
        return;
      }

      // Find the closing </resources> tag
      int closingTagIndex = colorsFileContent.lastIndexOf('</resources>');
      if (closingTagIndex == -1) {
        showErrorToast('Invalid colors.xml file format.');
        return;
      }

      // Insert the new color entry before the closing tag
      String newColorEntry = '    <color name="$colorName">$colorValue</color>';
      colorsFileContent = colorsFileContent.replaceRange(closingTagIndex, closingTagIndex, newColorEntry + '\n');

      // Write the updated colors.xml file
      await File(colorsFilePath).writeAsString(colorsFileContent);

      showSuccessToast('Color entry added successfully.');
    } catch (e) {
      showErrorToast('Error adding color entry: $e');
    }
  }

  void showErrorToast(String message) {
   print(message);
  }

  void showSuccessToast(String message) {
    print(message);

   /* Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );*/
  }

  void processForColorFound(String color) async{

    if(autoCreateColor.value==true){
      addColorToColorsFile(color.getColorName(), color);
    }
    else{
      await Get.dialog(
        ColorNameDialog(
          colorCode: color,
          onConfirm: (colorName) {
            addColorToColorsFile(colorName, color);
          },
        ),
      );
    }

  }
}