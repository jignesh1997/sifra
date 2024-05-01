import 'dart:io';
import 'dart:io';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/shell.dart';
import 'package:sifra/screens/util/extensions.dart';

class ExecuteScriptWidget extends StatelessWidget {
  final String selectedScriptPath;
  final Function(String) onScriptSelected;
  final VoidCallback onScriptExecuted;

  ExecuteScriptWidget({
    required this.selectedScriptPath,
    required this.onScriptSelected,
    required this.onScriptExecuted,
  });

  Future<void> _selectAndExecuteScript() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sh'],
    );

    if (result != null && result.files.isNotEmpty) {
      String scriptPath = convertPathWithSpaces( result.files.first.path!);
      onScriptSelected(scriptPath);

      try {
        // Make the script file executable
        await Process.run('chmod', ['+x', scriptPath]);

        // Execute the script
        var result = await Shell().run(scriptPath);
        print(result.outText);
        print(result.errLines);
        onScriptExecuted();
      } catch (e) {
        print('Error executing script: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          selectedScriptPath.isEmpty
              ? 'No script file selected'
              : 'Selected script: $selectedScriptPath',
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _selectAndExecuteScript,
          child: Text('Select and Execute Script'),
        ),
      ],
    );
  }
}