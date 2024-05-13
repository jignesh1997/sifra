import 'dart:io';
import 'dart:io';
import 'dart:io';
import 'package:flutter/material.dart';

class ExecuteScriptWidget extends StatelessWidget {
  final String selectedScriptPath;
  final Function(String) onScriptSelected;
  final VoidCallback onScriptExecuted;

  ExecuteScriptWidget({
    required this.selectedScriptPath,
    required this.onScriptSelected,
    required this.onScriptExecuted,
  });


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
       /* ElevatedButton(
          onPressed: _selectAndExecuteScript,
          child: Text('Select and Execute Script'),
        ),*/
      ],
    );
  }
}