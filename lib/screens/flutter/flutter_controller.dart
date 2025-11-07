import 'package:get/get.dart';
import 'package:sifra/screens/base/base_sifra_controller.dart';
import 'package:sifra/screens/util/image_constant_generato_helper.dart';

import '../util/file_utils.dart';
import '../util/string_utils.dart';
import '../widgets/color_name_dialog.dart';

class FlutterDeveloperController extends BaseSifraController {
  Rx<String?> selectedPathImageConstant = Rx<String?>(null);
  RxBool autoCreateString = true.obs;
  @override
  void processClipboardContent(String content) {
    List<String> lines = content.split('\n');
    if (lines[0]?.startsWith('// ') == true) {
      FileUtils.processFileContent(
          content, selectedPath.value!, autoCreateFile.value);
    } else {
      processStringContent(content);
    }
  }

  void processStringContent(String content) async {
    if (autoCreateString.value) {
      String generatedStringName = stringContentToStringName(content);
      addStringToFlutterGetXFile(
          projectPath: selectedPath.value!,
          stringName: generatedStringName,
          stringContent: content);
    } else {
      String generatedStringName = stringContentToStringName(content);
      await Get.dialog(
        InputNameDialog(
          content: content,
          generatedName: generatedStringName,
          title: 'Enter String Name',
          labelText: 'String Name',
          onConfirm: (stringName) {
            // String stringName = stringContentToStringName(content);
            // String generatedStringName = stringContentToStringName(content);
            //if (colorForLanguage == ColorForLanguage.android) {
            addStringToFlutterGetXFile(
                projectPath: selectedPath.value!,
                stringName: stringName,
                stringContent: content);
            // }
          },
        ),
      );
    }
  }

  void onGenerateConstants() {
    ImageConstantGeneratorHelper.generateConstants(selectedPath.value ?? "");
  }
}
