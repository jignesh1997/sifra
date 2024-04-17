import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sifra/screens/util/extensions.dart';

class ColorNameDialog extends StatelessWidget {
  final String colorCode;
  final Function(String) onConfirm;

  ColorNameDialog({
    required this.colorCode,
    required this.onConfirm,
  });

  final TextEditingController _colorNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _colorNameController.text = colorCode.getColorName();

    return AlertDialog(
      title: Text('Enter Color Name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Color Code: $colorCode'),
          SizedBox(height: 16),
          TextField(
            controller: _colorNameController,
            decoration: InputDecoration(
              labelText: 'Color Name',
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
            String colorName = _colorNameController.text.trim();
            if (colorName.isNotEmpty) {
              onConfirm(colorName);
              Get.back();
            }
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}