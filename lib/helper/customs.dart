import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Customs {
  void loading() {
    if (Platform.isIOS) {
      Get.dialog(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              CupertinoActivityIndicator(),
            ],
          ),
          barrierColor: Colors.black38,
          barrierDismissible: false);
    } else {
      Get.dialog(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          barrierColor: Colors.black38,
          barrierDismissible: false);
    }
  }

  void dataErrorOrNetwork() {
    HapticFeedback.mediumImpact();
    Get.defaultDialog(
        title: "error".tr,
        middleText: 'checkNetwork'.tr + ' ' + "errorData".tr,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ));
  }

  void showNetworkError() {
    HapticFeedback.mediumImpact();
    Get.snackbar('error'.tr, 'checkNetwork'.tr,
        icon: const Icon(
          Icons.wifi_off_outlined,
          color: Colors.amber,
        ),
        duration: const Duration(seconds: 10));
  }

  void showError() {
    HapticFeedback.mediumImpact();

    Get.snackbar('error'.tr, 'tryAgain'.tr,
        icon: Icon(
          Icons.error,
          color: Colors.red.shade800,
        ),
        duration: const Duration(seconds: 10));
  }

  void showHint(String title, message) {
    HapticFeedback.mediumImpact();

    Get.snackbar(title, '$message',
        icon: Icon(
          Icons.info,
          color: Colors.amber.shade800,
        ),
        duration: const Duration(seconds: 10));
  }
}
