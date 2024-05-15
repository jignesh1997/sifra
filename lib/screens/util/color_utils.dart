import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sifra/screens/util/extensions.dart';

import '../widgets/color_name_dialog.dart';
import 'mis_util.dart';
import 'package:get/get.dart';

class ColorUtils {
  static Future<void> addColorToAndroidColorsFile(
      String selectedProjectPath, String colorName, String colorValue) async {
    if (selectedProjectPath == null) {
      showErrorToast('No project location path selected.');
      return;
    }

    try {
      String colorsFilePath = path.join(selectedProjectPath, 'app', 'src',
          'main', 'res', 'values', 'colors.xml');

      // Check if colors.xml file exists
      if (!await File(colorsFilePath).exists()) {
        showErrorToast('colors.xml file not found.');
        return;
      }

      // Read the existing colors.xml file
      String colorsFileContent = await File(colorsFilePath).readAsString();

      // Check if the color entry already exists
      if (colorsFileContent
          .contains('<color name="$colorName">$colorValue</color>')) {
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
      colorsFileContent = colorsFileContent.replaceRange(
          closingTagIndex, closingTagIndex, newColorEntry + '\n');

      // Write the updated colors.xml file
      await File(colorsFilePath).writeAsString(colorsFileContent);

      showSuccessToast('Color entry added successfully.');
    } catch (e) {
      showErrorToast('Error adding color entry: $e');
    }
  }
}

void processColorString(String colorString, bool autoCreateColor,
    String selectedPath, ColorForLanguage colorForLanguage) {
  if (!colorString.startsWith('#')) {
    colorString = '#$colorString';
  }
  processForColorFound(
      colorString, autoCreateColor, selectedPath, colorForLanguage);
}

void processForColorFound(String color, bool autoCreateColor,
    String selectedPath, ColorForLanguage coloForLanguage) async {
  if (autoCreateColor == true) {
    switch (coloForLanguage) {
      case ColorForLanguage.android:
        ColorUtils.addColorToAndroidColorsFile(
            selectedPath, color.getColorName(), color);
        break;
      case ColorForLanguage.flutter:
        break;
      case ColorForLanguage.rect:

    }
  } else {
    await Get.dialog(
      InputNameDialog(
        content: color,
        generatedName: color.getColorName(),
        title: 'Enter Color Name',
        labelText: 'Color Name',
        onConfirm: (colorName) {
          ColorUtils.addColorToAndroidColorsFile(
              selectedPath!, colorName, color);
        },
      ),
    );
  }
}

enum ColorForLanguage { android, flutter, rect }
