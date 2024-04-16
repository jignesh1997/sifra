import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import 'clipbord_controller.dart';
class ClipboardMonitor extends StatelessWidget {
  final ClipboardController controller = Get.put(ClipboardController());

  @override
  Widget build(BuildContext context) {
    return Obx(
        ()=> Scaffold(
        appBar: AppBar(
          title: Text('Clipboard Monitor'),
        ),
        body: Center(
          child: Container(
            padding:EdgeInsets.all(22),
            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: controller.isListening.value ? null : controller.showPathPickerDialog,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(text: controller.selectedPath.value ?? ""),
                      decoration: InputDecoration(
                        labelText: 'Select the project',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.folder_open),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: controller.isListening.value ? null : controller.startMonitoringClipboard,
                  child: Text('Start Listening'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.isListening.value ? controller.stopMonitoringClipboard : null,
                  child: Text('Stop Listening'),
                ),
                SizedBox(height: 16),
                Obx(() => Text(
                  controller.isListening.value ? 'Monitoring clipboard changes...' : 'Not monitoring',
                  style: TextStyle(fontSize: 18),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}