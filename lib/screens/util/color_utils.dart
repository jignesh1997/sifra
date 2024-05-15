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



  static void addColorToRectNativeFile(String selectedProjectPath,  String colorValue) {
    try {
      String colorsFilePath = path.join(selectedProjectPath, 'src', 'constants', 'colors.tsx');

      // Check if colors.tsx file exists
      if (!File(colorsFilePath).existsSync()) {
        // Create a new colors.tsx file with the desired structure
        String initialContent = '''
const Colors = {
  solid: {
    black: '#0F111A',
    grey: '#21273B',
    red: '#FF3C3C',
    white: '#FFFFFF',
    green: '#11853a',
    lightGrey: 'rgba(152, 162, 179, 1)',
    lightBlack: 'rgba(33, 39, 59, 1)',
    bgColor: 'rgba(25, 29, 43, 1)',
    darkGradient: 'rgba(26, 27, 29, 1)',
    dark2Gradient: 'rgba(26, 27, 29, 0)',
    mediumGrey: 'rgba(150, 160, 181, 1)',
    greyTint: '#B6BEC9',
    primaryBlue: '#356AD1',
    transparent: 'transparent',
    blur0: 'rgba(0, 0, 0, 0.7)',
    blur1: 'rgba(25, 29, 43, 0)',
    blur2: 'rgba(25, 29, 43, 1)',
    blur3: 'rgba(240, 245, 249, 0.2)',
    blur4: 'rgba(240, 245, 249, 1)',
    blur8: 'rgba(255, 255, 255, 0.2)',
    blur255: 'rgba(255, 255, 255, 0.2)',
    blur251: 'rgba(251, 188, 5, 0.1)',
    radioFill: 'rgba(217, 217, 217, 0.1)',
  },
  transparent: 'rgba(24, 28, 43, 0.7)',
  BGTransperent: 'rgba(25, 28, 44, 0.8)',
 
};

export default Colors;
''';

        // Write the initial content to the colors.tsx file
        File(colorsFilePath).writeAsStringSync(initialContent);
      }

      // Read the existing colors.tsx file
      String colorsFileContent = File(colorsFilePath).readAsStringSync();

      String formattedColorName = 'C${colorValue.replaceAll('#', '')}';
      // Check if the color entry already exists
      if (colorsFileContent.contains('$formattedColorName:')) {
        print('Color entry already exists.');
        return;
      }

      // Find the position to insert the new color entry
      int insertPosition = colorsFileContent.lastIndexOf('};');
      if (insertPosition == -1) {
        print('Invalid colors.tsx file format.');
        return;
      }

      // Convert the color name to the desired format
      //String formattedColorName = 'C${colorName.replaceAll('#', '')}';

      // Insert the new color entry
      String newColorEntry = '  $formattedColorName: \'$colorValue\',\n';
      colorsFileContent = colorsFileContent.replaceRange(insertPosition, insertPosition, newColorEntry);

      // Write the updated colors.tsx file
      File(colorsFilePath).writeAsStringSync(colorsFileContent);

      print('Color entry added successfully.');
    } catch (e) {
      print('Error adding color entry: $e');
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
    processToCreateColor(color, selectedPath, coloForLanguage);
  } else {
    await Get.dialog(
      InputNameDialog(
        content: color,
        generatedName: color.getColorName(),
        title: 'Enter Color Name',
        labelText: 'Color Name',
        onConfirm: (colorName) {
          processToCreateColor(color, selectedPath, coloForLanguage);
        },
      ),
    );
  }
}

void processToCreateColor(String color, String selectedPath, ColorForLanguage coloForLanguage) {
  switch (coloForLanguage) {
    case ColorForLanguage.android:
      ColorUtils.addColorToAndroidColorsFile(
          selectedPath, color.getColorName(), color);
      break;
    case ColorForLanguage.flutter:
      break;
    case ColorForLanguage.rect:
      ColorUtils.addColorToRectNativeFile(selectedPath, color);
      break;
  }
}

enum ColorForLanguage { android, flutter, rect }
