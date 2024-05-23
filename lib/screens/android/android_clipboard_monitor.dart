import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sifra/screens/base/base_sifra_controller.dart';
import 'package:sifra/screens/util/extensions.dart';
import 'package:sifra/screens/util/file_utils.dart';
import 'package:sifra/screens/util/string_utils.dart';
import '../util/color_utils.dart';
import '../widgets/color_name_dialog.dart';

class AndroidController extends BaseSifraController {


  RxBool autoCreateColor = false.obs;
  RxBool autoCreateString = true.obs;
  RxString selectedScriptPath = ''.obs;
  var isForRect=false;
  var useCommonForString=true.obs;
  final TextEditingController screenName=TextEditingController();


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
       processStringContent(content,isForRect ? ColorForLanguage.rect : ColorForLanguage.android);
    }
  }

  void processStringContent(String content, ColorForLanguage colorForLanguage) async {
    if (autoCreateString.value) {
      String generatedStringName = stringContentToStringName(content);
      if(colorForLanguage==ColorForLanguage.android){
        addStringToAndroidStringsFile(selectedPath.value!, content,generatedStringName);
      }
      if(colorForLanguage==ColorForLanguage.rect){
       addStringToRectStringsFile(selectedPath.value!, getScreenNameForString(), generatedStringName, content) ;
      }
    } else {
      String generatedStringName = stringContentToStringName(content);
      await  Get.dialog(
        InputNameDialog(
          content: content,
          generatedName: generatedStringName,
          title: 'Enter String Name',
          labelText: 'String Name',
          onConfirm: (stringName) {
            // String stringName = stringContentToStringName(content);
           // String generatedStringName = stringContentToStringName(content);
            if(colorForLanguage==ColorForLanguage.android){
              addStringToAndroidStringsFile(selectedPath.value!, content,stringName);
            }
            if(colorForLanguage==ColorForLanguage.rect){
              addStringToRectStringsFile(selectedPath.value!, getScreenNameForString(), stringName, content) ;
            }
          },
        ),
      );
    }
  }
  void toggleAutoCreateColor(bool value) {
    autoCreateColor.value = value;
  }
  void toggleStringCommon(bool value) {
    useCommonForString.value = value;
  }
  String getScreenNameForString(){
    return useCommonForString.value ?  screenName.text : "common";
  }

  void generateReactImageConstant() {
    if(selectedScriptPath.value!=null){
      FileUtils.generateImageConstants(selectedPath.value ?? "" );
    }
  }
}