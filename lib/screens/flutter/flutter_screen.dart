import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../util/image_constant_generato_helper.dart';
import '../widgets/copy_magic_prompt.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/image_constants_generator.dart';
import '../widgets/path_picker_widget.dart';
import 'flutter_controller.dart';

class FlutterDeveloperScreen extends StatelessWidget {
  final FlutterDeveloperController controller =
      Get.put(FlutterDeveloperController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: CustomAppBar(
          title: "Sifra android",
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                PathPickerWidget(
                  isListening: controller.isListening.value,
                  selectedPath: controller.selectedPath.value,
                  onTap: () async {
                    controller.showPathPickerDialog(controller.selectedPath);
                  },
                ),
                const SizedBox(
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
                          const SizedBox(
                            height: 12,
                          ),
                          ElevatedButton(
                                onPressed: () {
                                  controller.onGenerateConstants();
                                },
                                child: const Text("Genearte asset constant")),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: CopyMagicPromptWidget()),
                /* ExecuteScriptWidget(
                  selectedScriptPath:controller.selectedScriptPath.value,
                  onScriptSelected: (path){
                    controller.selectedScriptPath.value=path;
                  },
                  onScriptExecuted: (){

                  },
                ),*/
                Spacer(),
                Obx(() => ElevatedButton(
                      onPressed: controller.isListening.value ||
                              controller.selectedPath.value == null
                          ? null
                          : controller.startMonitoringClipboard,
                      child: Text('Start Listening'),
                    )),
                const SizedBox(height: 16),
                Obx(() => ElevatedButton(
                      onPressed: controller.isListening.value
                          ? controller.stopMonitoringClipboard
                          : null,
                      child: Text('Stop Listening'),
                    )),
                const SizedBox(height: 16),
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
