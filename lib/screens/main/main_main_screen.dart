import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../android/android_screen.dart';
import '../general_clipborad_to_file/clipboard_screen.dart';
import 'package:window_manager/window_manager.dart';


class MainScreen extends StatelessWidget {
  var _isAlwaysOnTop = false.obs;

  @override
  Widget build(BuildContext context) {
    return  Obx(
      ()=> Scaffold(
          appBar: AppBar(
            title: Text('Main Screen'),
          ),
          body: Center(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text("Always on Top"),
                      Checkbox(
                        value: _isAlwaysOnTop.value,
                        onChanged: (value) async {
                            _isAlwaysOnTop.value = value!;
                          await windowManager.setAlwaysOnTop(value!);
                        },
                      ),
                    ],
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => AndroidClipboardMonitor());
                      },
                      child: Text('Android'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => ClipboardMonitor());
                      },
                      child: Text('Flutter'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                      //  Get.to(() => AndroidClipboardMonitor());
                      },
                      child: Text('React native'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => ClipboardMonitor());
                      },
                      child: Text('Genral'),
                    ),
                    // Add more options here
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              height: 50,
              child: Center(
                child: Text(
                  'Developed by Jignesh Shakya with ❤️',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),

    );
  }
}