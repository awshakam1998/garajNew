import 'package:flutter/material.dart';
import 'package:garaj/viewmodel/language_controller.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class ChangeLanguageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('EN'),
          GetBuilder<LanguageControl>(
              init: LanguageControl(),
              builder: (lang) {
                return Switch(
                    value: lang.appLanguage == 'ar' ? true : false,
                    onChanged: (v) {
                      if (v) {
                        lang.changeLanguage('ar');
                      } else {
                        lang.changeLanguage('en');
                      }
                      lang.update();
                    });
              }),
          const Text(
            'ع',
            style: TextStyle(fontFamily: 'casual'),
          ),
        ],
      ),
    );
  }
}
