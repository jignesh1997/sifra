import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'flutter_controller.dart';

class FlutterDeveloperScreen extends StatelessWidget {
  final FlutterDeveloperController controller = Get.put(FlutterDeveloperController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sifra Flutter'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: controller.generateImageConstants,
          child: const Text('Generate Image Constants'),
        ),
      ),
    );
  }
}