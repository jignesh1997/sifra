import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sifra/screens/flutter/flutter_screen.dart';

import '../android/android_screen.dart';
import '../general_clipborad_to_file/clipboard_screen.dart';

import '../widgets/custom_app_bar.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Main Screen',
      ),
      body: Center(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => ClipboardMonitor());
                  },
                  child: Text('General (All)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => AndroidClipboardMonitor(),
                    arguments: {"isForReact":false}
                    );
                  },
                  child: Text('Android'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => FlutterDeveloperScreen());
                  },
                  child: Text('Flutter'),
                ),
                ElevatedButton(
                  onPressed: () {
                      Get.to(() => AndroidClipboardMonitor(),
                        arguments: {"isForReact" : true }
                      );
                  },
                  child: Text('React native'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child:  Container(
          height: 50,
          child: const Center(
            child: Text(
              'Developed by Jignesh Shakya with ❤️',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
