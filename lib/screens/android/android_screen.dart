import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import 'android_clipboard_monitor.dart';

class AndroidClipboardMonitor extends StatelessWidget {
  final AndroidController controller = Get.put(AndroidController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text('Clipboard Monitor'),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                  onTap: controller.isListening.value
                      ? null
                      : controller.showPathPickerDialog,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                          text: controller.selectedPath.value ?? ""),
                      decoration: InputDecoration(
                        labelText: 'Select the project',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.folder_open),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text('Auto create file'),
                            value: controller.autoCreateFile.value,
                            onChanged: (value) {
                              controller.toggleAutoCreateFile(value!);
                            },
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text('Auto create Color'),
                            value: false,
                            onChanged: (value) {
                              // TODO: Implement checkbox 2 functionality
                            },
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text('Auto create String'),
                            value: false,
                            onChanged: (value) {
                             // controller.toggleAutoCreateFile(value!);
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                Spacer(),

                Obx(() => ElevatedButton(
                  onPressed: controller.isListening.value || controller.selectedPath.value == null
                      ? null
                      : controller.startMonitoringClipboard,
                  child: Text('Start Listening'),
                )),
                SizedBox(height: 16),
                Obx(() => ElevatedButton(
                  onPressed: controller.isListening.value ? controller.stopMonitoringClipboard : null,
                  child: Text('Stop Listening'),
                )),
                SizedBox(height: 16),
                Obx(() => Text(
                      controller.isListening.value
                          ? 'Monitoring clipboard changes...'
                          : 'Not monitoring',
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
