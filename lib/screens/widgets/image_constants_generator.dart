import 'package:flutter/material.dart';

class ImageConstantsGenerator extends StatelessWidget {
  final String? selectedFolderPath;
  final VoidCallback onSelectFolder;
  final VoidCallback onGenerateConstants;

  const ImageConstantsGenerator({
    Key? key,
    required this.selectedFolderPath,
    required this.onSelectFolder,
    required this.onGenerateConstants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onSelectFolder,
          child: Text('Select Folder'),
        ),
        SizedBox(height: 16),
        Text(
          selectedFolderPath != null ? 'Selected Folder: $selectedFolderPath' : 'No folder selected',
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: selectedFolderPath != null ? onGenerateConstants : null,
          child: Text('Generate Constants'),
        ),
      ],
    );
  }
}