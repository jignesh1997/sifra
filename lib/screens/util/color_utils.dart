import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sifra/screens/util/extensions.dart';

import 'mis_util.dart';

class ColorUtils {
  static Future<void> addColorToColorsFile(String projectPath, String colorName, String colorValue) async {
    try {
      String colorsFilePath = path.join(projectPath, 'app', 'src', 'main', 'res', 'values', 'colors.xml');

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
}