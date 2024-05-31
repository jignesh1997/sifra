import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sifra/screens/util/extensions.dart';
import 'mis_util.dart';

String stringContentToStringName(String stringContent) {
  List<String> words = stringContent.split(' ');
  if (words.length <= 2) {
    return words.join('_').toLowerCase();
  } else {
    return words.take(2).join('_').toLowerCase();
  }
}

Future<void> addStringToAndroidStringsFile(
    String projectPath, String stringContent,String stringName) async {
  if (projectPath == null) {
    showErrorToast('No project location path selected.');
    return;
  }

  try {
    String stringsFilePath = path.join(
        projectPath!, 'app', 'src', 'main', 'res', 'values', 'strings.xml');

    // Check if strings.xml file exists
    if (!await File(stringsFilePath).exists()) {
      showErrorToast('strings.xml file not found.');
      return;
    }

    // Read the existing strings.xml file
    String stringsFileContent = await File(stringsFilePath).readAsString();

    // Generate the string name based on the string content
   // String stringName = stringContentToStringName(stringContent);

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
    String newStringEntry =
        '    <string name="$stringName">$stringContent</string>';
    stringsFileContent = stringsFileContent.replaceRange(
        closingTagIndex, closingTagIndex, newStringEntry + '\n');

    // Write the updated strings.xml file
    await File(stringsFilePath).writeAsString(stringsFileContent);

    showSuccessToast('String entry added successfully.');
  } catch (e) {
    showErrorToast('Error adding string entry: $e');
  }
}



Future<void> addStringToRectStringsFile(String projectPath, String screenName, String stringKey, String stringValue) async {
  if (screenName.isEmpty) {
    print("Please enter Screen name");
    return;
  }
  var stringCamelKey=stringKey.snakeToCamelCase();
  var screenNameCamelKey=screenName.toLowerCase().snakeToCamelCase();

  final filePath = '$projectPath/src/constants/strings.tsx';
  final file = File(filePath);

  String existingContent = '';

  if (await file.exists()) {
    existingContent = await file.readAsString();
  } else {
    existingContent = "import { AppImages } from \".\";\n\nexport const Strings = {\n};\n";
    await file.writeAsString(existingContent);
  }

  final buffer = StringBuffer();

  final screenPattern = RegExp(r'(\b' + RegExp.escape(screenNameCamelKey) + r'\b\s*:\s*{[\s\S]*?}),', multiLine: true);
  final match = screenPattern.firstMatch(existingContent);

  if (match != null) {
    final screenContent = match.group(0)!;
    final updatedScreenContent = screenContent.replaceFirst(RegExp(r'},\s*$'), "  $stringCamelKey: '$stringValue',\n},");
    existingContent = existingContent.replaceFirst(screenPattern, updatedScreenContent);
  } else {
    final insertIndex = existingContent.lastIndexOf('};');
    final newScreenContent = "  $screenNameCamelKey: {\n    $stringCamelKey: '$stringValue',\n  },\n";
    existingContent = existingContent.substring(0, insertIndex) + newScreenContent + existingContent.substring(insertIndex);
  }

  buffer.write(existingContent);

  await file.writeAsString(buffer.toString());
  print('Strings file updated successfully: $filePath');
}

