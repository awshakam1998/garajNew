import 'package:get/get.dart';

import 'lang/ar.dart';
import 'lang/en.dart';



class Translation extends Translations {
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys =>
      {
        'en': en,
        'ar': ar,
      };
}
