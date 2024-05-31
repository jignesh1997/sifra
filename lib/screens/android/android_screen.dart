import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sifra/screens/widgets/copy_magic_prompt.dart';
import 'package:sifra/screens/widgets/custom_app_bar.dart';

import '../widgets/execute_script_widget.dart';
import '../widgets/path_picker_widget.dart';
import 'android_clipboard_monitor.dart';

class AndroidClipboardMonitor extends StatelessWidget {
  final AndroidController controller = Get.put(AndroidController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: CustomAppBar(title: controller.isForRect ? "Sifra React" : "Sifra android",),
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
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text('Auto create Color'),
                            value: controller.autoCreateColor.value,
                            onChanged: (value) {
                              controller.toggleAutoCreateColor(value!);
                            },
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text('Auto create String'),
                            value: controller.autoCreateString.value,
                            onChanged: (value) {
                              controller.autoCreateString.value=!(controller.autoCreateString.value);
                             // controller.toggleAutoCreateFile(value!);
                            },
                          ),
                          SizedBox(height: 12,),
                          Visibility(
                            visible: controller.isForRect,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Specify Screen Name: - "),
                                Row(
                                  children: [
                                    Text("Use common"),

                                    Switch(value: controller.useCommonForString.value, onChanged: (bool){
                                      controller.toggleStringCommon(bool);
                                    }),
                                    SizedBox(width: 20,),
                                    Expanded(child: TextField(controller: controller.screenName,))
                                  ],
                                ),

                               // TextField()
                              ],
                            ),
                          ),
                          SizedBox(height: 12,),
                        Visibility(
                          visible: controller.isForRect,
                          child: ElevatedButton(
                            onPressed:(){
                              controller.generateReactImageConstant();
                            },
                            child: Text('Generate Image Constants'),
                          ),
                        )


                        ],
                      ),
                    ),
                  ]),
                ),
                SizedBox(height: 20,),

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
                  onPressed: controller.isListening.value || controller.selectedPath.value == null
                      ? null
                      : controller.startMonitoringClipboard,
                  child: Text('Start Listening'),
                )),
                const SizedBox(height: 16),
                Obx(() => ElevatedButton(
                  onPressed: controller.isListening.value ? controller.stopMonitoringClipboard : null,
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
