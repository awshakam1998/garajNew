import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {

  ///Write on Disk
  void saveLanguageToDisk(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', language);
  }
 ///Check key
  Future<bool> checkLanguage(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  ///Read from Disk
  Future<String?> get languageSelected async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('lang');
  }
}
