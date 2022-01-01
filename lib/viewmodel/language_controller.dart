import 'package:flutter/cupertino.dart';
import 'package:garaj/utils/local_storage/local_sorage.dart';
import 'package:get/get.dart';

class LanguageControl extends GetxController {
  var appLanguage = "ar";

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    LocalStorage localStorage = LocalStorage();
    appLanguage = (await localStorage.languageSelected)!;
    Get.updateLocale(Locale(appLanguage));
    update();
  }

  void changeLanguage(String language) {
    LocalStorage localStorage = LocalStorage();

    if (language == appLanguage) return;
    if (language == 'ar') {
      appLanguage = 'ar';
      localStorage.saveLanguageToDisk('ar');
    } else {
      appLanguage = 'en';
      localStorage.saveLanguageToDisk('en');
    }
    Get.updateLocale(Locale(appLanguage));
    update();
  }
}
