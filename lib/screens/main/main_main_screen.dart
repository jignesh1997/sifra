import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../android/android_screen.dart';
import '../general_clipborad_to_file/clipboard_screen.dart';


class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
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
                Get.to(() => ClipboardMonitor());
              },
              child: Text('Genral'),
            ),
            // Add more options here
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
    );
  }
}