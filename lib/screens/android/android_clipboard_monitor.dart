import 'package:get/get.dart';
import 'package:sifra/screens/base/base_sifra_controller.dart';
import 'package:sifra/screens/util/extensions.dart';
import 'package:sifra/screens/util/file_utils.dart';
import 'package:sifra/screens/util/string_utils.dart';
import '../util/color_utils.dart';

class AndroidController extends BaseSifraController {


  RxBool autoCreateColor = false.obs;
  RxBool autoCreateString = true.obs;
  RxString selectedScriptPath = ''.obs;
  var isForRect=false;

  @override
  void onInit() {
    super.onInit();
    isForRect= Get.arguments["isForReact"];
    print(isForRect);

  }
  @override
  void processClipboardContent(String content) {
    List<String> lines = content.split('\n');
    if (lines[0].isValidColor()) {
      String colorString = lines[0].trim();
      processColorString(colorString,autoCreateColor.value,selectedPath.value!,isForRect ? ColorForLanguage.rect : ColorForLanguage.android);
    } else if (lines[0]?.startsWith('// ') == true) {
      FileUtils.processFileContent(content,selectedPath.value!,autoCreateFile.value);
    } else {
       processStringContent(content);
    }
  }

  void processStringContent(String content) async {
    if (autoCreateString.value) {
      String generatedStringName = stringContentToStringName(content);
      addStringToAndroidStringsFile(selectedPath.value!, content,generatedStringName);
    } else {
      String generatedStringName = stringContentToStringName(content);
      await showStringNameDialog(content, generatedStringName,selectedPath.value!);
    }
  }
  void toggleAutoCreateColor(bool value) {
    autoCreateColor.value = value;
  }

  void generateReactImageConstant() {
    if(selectedScriptPath.value!=null){
      FileUtils.generateImageConstants(selectedPath.value ?? "" );
    }

  }
}