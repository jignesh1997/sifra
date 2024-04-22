import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputNameDialog extends StatelessWidget {
  final String content;
  final String generatedName;
  final String title;
  final String labelText;
  final Function(String) onConfirm;

  InputNameDialog({
    required this.content,
    required this.generatedName,
    required this.title,
    required this.labelText,
    required this.onConfirm,
  });

  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _nameController.text = generatedName;

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$labelText: $content'),
          SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: labelText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            String name = _nameController.text.trim();
            if (name.isNotEmpty) {
              onConfirm(name);
              Get.back();
            }
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}