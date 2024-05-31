import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sifra/screens/flutter/flutter_screen.dart';

import '../android/android_screen.dart';
import '../general_clipborad_to_file/clipboard_screen.dart';

import '../widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sifra',
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
        child:  InkWell(
          onTap: (){
            redirectToLinkedInProfile();
          },
          child: Container(
            height: 50,
            child:  Center(
              child: RichText(
                text: const TextSpan(
                  text: 'Developed by ',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Jignesh Shakya',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: ' with AI️',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
            )),
          ),
        ),
      ),
    );
  }

  void redirectToLinkedInProfile() async {
    const url = 'https://www.linkedin.com/in/jigneshshakya1997';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
