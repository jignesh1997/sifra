import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sifra/screens/util/extensions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../widgets/ConfirmationDialog.dart';
import '../widgets/color_name_dialog.dart';

class AndroidController extends GetxController {
  // Observable variables
  RxString lastClipboardContent = ''.obs;
  RxBool isListening = false.obs;
  Rx<String?> selectedPath = Rx<String?>(null);
  Rx<String?> svgVectorSelectedPath = Rx<String?>(null);
  RxBool autoCreateFile = true.obs;
  RxBool autoCreateColor = false.obs;
  RxBool autoCreateString = true.obs;

  RxString selectedScriptPath = ''.obs;


  Future<void> selectScriptFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sh'],
    );

    if (result != null && result.files.isNotEmpty) {
      selectedScriptPath.value = result.files.first.path!;
    }
  }


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
          addStringToStringsFile(clipboardContent);
        } else {
          String generatedStringName = generateStringName(clipboardContent);

          await Get.dialog(
            InputNameDialog(
              content: clipboardContent,
              generatedName: generatedStringName,
              title: 'Enter String Name',
              labelText: 'String Name',
              onConfirm: (stringName) {
                addStringToStringsFile(clipboardContent);
              },
            ),
          );
        }
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
        InputNameDialog(
          content: color,
          generatedName: color.getColorName(),
          title: 'Enter Color Name',
          labelText: 'Color Name',
          onConfirm: (colorName) {
            addColorToColorsFile(colorName, color);
          },
        ),
      );
    }
  }


  Future<void> addStringToStringsFile(String stringContent) async {
    if (selectedPath.value == null) {
      showErrorToast('No project location path selected.');
      return;
    }

    try {
      String stringsFilePath = path.join(selectedPath.value!, 'app', 'src', 'main', 'res', 'values', 'strings.xml');

      // Check if strings.xml file exists
      if (!await File(stringsFilePath).exists()) {
        showErrorToast('strings.xml file not found.');
        return;
      }

      // Read the existing strings.xml file
      String stringsFileContent = await File(stringsFilePath).readAsString();

      // Generate the string name based on the string content
      String stringName = generateStringName(stringContent);

      // Check if the string entry already exists
      if (stringsFileContent.contains('<string name="$stringName">')) {
        showErrorToast('String entry already exists.');
        return;
      }

      // Find the closing </resources> tag
      int closingTagIndex = stringsFileContent.lastIndexOf('</resources>');
      if (closingTagIndex == -1) {
        showErrorToast('Invalid strings.xml file format.');
        return;
      }

      // Insert the new string entry before the closing tag
      String newStringEntry = '    <string name="$stringName">$stringContent</string>';
      stringsFileContent = stringsFileContent.replaceRange(closingTagIndex, closingTagIndex, newStringEntry + '\n');

      // Write the updated strings.xml file
      await File(stringsFilePath).writeAsString(stringsFileContent);

      showSuccessToast('String entry added successfully.');
    } catch (e) {
      showErrorToast('Error adding string entry: $e');
    }
  }

  String generateStringName(String stringContent) {
    List<String> words = stringContent.split(' ');
    if (words.length <= 4) {
      return words.join('_').toLowerCase();
    } else {
      return words.take(4).join('_').toLowerCase();
    }
  }


  Future<void> generateVectorsFromFolder() async {
    if (selectedPath.value == null) {
      showErrorToast('No project location path selected.');
      return;
    }

    try {
      Directory svgFolder = Directory(svgVectorSelectedPath.string);
      List<FileSystemEntity> svgFiles = svgFolder.listSync(recursive: true)
          .where((entity) => entity is File && path.extension(entity.path).toLowerCase() == '.svg')
          .toList();

      if (svgFiles.isEmpty) {
        showErrorToast('No SVG files found in the selected folder.');
        return;
      }

      String drawablePath = path.join(selectedPath.value!, 'app', 'src', 'main', 'res', 'drawable');
      Directory drawableDirectory = Directory(drawablePath);
      if (!drawableDirectory.existsSync()) {
        drawableDirectory.createSync(recursive: true);
      }

      for (FileSystemEntity svgFile in svgFiles) {
        String svgFilePath = svgFile.path;
        String svgFileName = path.basenameWithoutExtension(svgFilePath);
        String vectorFileName = '${svgFileName}.xml';
        String vectorFilePath = path.join(drawablePath, vectorFileName);

        //DrawableRoot svgDrawableRoot = await svg.fromSvgString(await File(svgFilePath).readAsString(), svgFileName);
        //String vectorContent =   generateVectorContent(svgDrawableRoot);

     //  File(vectorFilePath).writeAsStringSync(vectorContent);

       convertSvgToVectorXml(svgFilePath, vectorFilePath);
      }

      showSuccessToast('Vector drawables generated successfully.');
    } catch (e) {
      showErrorToast('Error generating vector drawables: $e');
    }
  }

  Future<void> showSvgFolderPickerDialog() async {
    String? path = await FilePicker.platform.getDirectoryPath(
      initialDirectory: selectedPath.value,
    );
    if (path != null) {
      svgVectorSelectedPath.value = path;
    }
  }
}