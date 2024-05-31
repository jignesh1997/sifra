import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sifra/screens/util/script_utils.dart';
import 'package:sifra/screens/widgets/execute_script_widget.dart';

import '../widgets/copy_magic_prompt.dart';
import '../widgets/path_picker_widget.dart';
import 'clipbord_controller.dart';

class ClipboardMonitor extends StatelessWidget {
  final ClipboardController controller = Get.put(ClipboardController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text('Sifra'),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PathPickerWidget(
                  isListening: controller.isListening.value,
                  selectedPath: controller.selectedPath.value,
                  onTap: () async {
                    controller.showPathPickerDialog(controller.selectedPath);
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Auto create file'),
                  value: controller.autoCreateFile.value,
                  onChanged: (value) {
                    controller.toggleAutoCreateFile(value!);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: CopyMagicPromptWidget()),
                const Spacer(),
                ElevatedButton(
                  onPressed: controller.isListening.value
                      ? null
                      : controller.startMonitoringClipboard,
                  child: const Text('Start Listening'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.isListening.value
                      ? controller.stopMonitoringClipboard
                      : null,
                  child: const  Text('Stop Listening'),
                ),
                const SizedBox(height: 16),
                Obx(() => Text(
                      controller.isListening.value
                          ? 'Monitoring clipboard changes...'
                          : 'Not monitoring',
                      style: const TextStyle(fontSize: 18),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
