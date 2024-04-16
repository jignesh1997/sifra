import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmationDialog extends StatelessWidget {
  final String fileName;

  ConfirmationDialog({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create File'),
      content: Text('Do you want to create the file: $fileName'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text('Create'),
        ),
      ],
    );
  }
}