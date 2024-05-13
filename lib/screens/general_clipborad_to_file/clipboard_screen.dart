import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sifra/screens/util/script_utils.dart';
import 'package:sifra/screens/widgets/execute_script_widget.dart';

import '../widgets/path_picker_widget.dart';
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
                PathPickerWidget(
                  isListening: controller.isListening.value,
                  selectedPath: controller.selectedPath.value,
                  onTap: () async {
                    controller.showPathPickerDialog(controller.selectedPath);
                  },
                ),
                ElevatedButton(onPressed: ()async{
                  controller.executeScript();
                }, child: Text("Select script to execute")),
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