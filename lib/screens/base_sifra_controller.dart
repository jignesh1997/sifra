
import 'dart:async';
import 'package:clipboard/clipboard.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
abstract class BaseSifraController extends GetxController{
  RxString lastClipboardContent = ''.obs;
  RxBool isListening = false.obs;
  Rx<String?> selectedPath = Rx<String?>(null);
  Timer? timer;
  RxBool autoCreateFile = true.obs;
  void processClipboardContent(String content);

  void startMonitoringClipboard() async {
    isListening.value = true;
    timer = Timer.periodic(Duration(milliseconds: 400), (_) => checkClipboardContent());
  }

  void checkClipboardContent() async {
    String clipboardContent = await FlutterClipboard.paste();
    if (clipboardContent != lastClipboardContent.value) {
      lastClipboardContent.value = clipboardContent;
      processClipboardContent(clipboardContent);
    }
  }
  void stopMonitoringClipboard() {
    isListening.value = false;
    timer?.cancel();
  }
  Future<void> showPathPickerDialog() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      selectedPath.value = path;
    }
  }
  @override
  void onClose() {
    stopMonitoringClipboard();
    super.onClose();
  }

  void toggleAutoCreateFile(bool value) {
    autoCreateFile.value = value;
  }
}