import 'package:flutter/material.dart';
import 'package:get/get.dart';
void showErrorToast(String message){
  Get.rawSnackbar(message: message,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(milliseconds:1500 ),
    backgroundColor: Colors.redAccent,
    snackStyle: SnackStyle.FLOATING,
    margin: const EdgeInsets.all(0),
    padding: const EdgeInsets.all(16),
  );
}


void showSuccessToast(String message){

  Get.rawSnackbar(message: message,
    snackPosition: SnackPosition.BOTTOM,
    duration: Duration(milliseconds: 1500),
    backgroundColor: Colors.green,
    snackStyle: SnackStyle.FLOATING,
    margin: EdgeInsets.all(0),
    padding: EdgeInsets.all(16),
  );
}