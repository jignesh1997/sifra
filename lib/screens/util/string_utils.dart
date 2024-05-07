import 'dart:io';
import 'package:path/path.dart' as path;

import 'mis_util.dart';

class StringUtils {
  static Future<void> addStringToStringsFile(String projectPath, String stringContent) async {
    try {
      String stringsFilePath = path.join(projectPath, 'app', 'src', 'main', 'res', 'values', 'strings.xml');

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

  static String generateStringName(String stringContent) {
    List<String> words = stringContent.split(' ');
    if (words.length <= 4) {
      return words.join('_').toLowerCase();
    } else {
      return words.take(4).join('_').toLowerCase();
    }
  }
}