import 'package:flutter/material.dart';

class PathPickerWidget extends StatelessWidget {
  final bool isListening;
  final String? selectedPath;
  final VoidCallback onTap;
  final String labelText;

  const PathPickerWidget({
    Key? key,
    required this.isListening,
    required this.selectedPath,
    required this.onTap,
    this.labelText = 'Select the project',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isListening ? null : onTap,
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: selectedPath ?? "",
          ),
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.folder_open),
          ),
        ),
      ),
    );
  }
}