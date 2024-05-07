import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/path_picker_widget.dart';
import 'flutter_controller.dart';

class FlutterDeveloperScreen extends StatelessWidget {
  final FlutterDeveloperController controller = Get.put(FlutterDeveloperController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sifra Flutter",),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
             /* PathPickerWidget(
                isListening: controller.isListening.value,
                selectedPath: controller.selectedPath.value,
                onTap: () async {
                  controller.showPathPickerDialog();
                },
              ),*/
              ElevatedButton(
                onPressed: controller.generateImageConstants,
                child: const Text('Generate Image Constants'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}