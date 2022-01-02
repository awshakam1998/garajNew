import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:garaj/is_logged_in.dart';
import 'package:garaj/utils/translation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

var appLanguage = 'en';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('lang')) {
    appLanguage = prefs.getString('lang')!;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Translation(),
      locale: Locale('en'),
      fallbackLocale: Locale('en'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.blueAccent.shade700.withOpacity(0.1),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(width: 1, color: Colors.transparent),
            ),
            disabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(width: 1, color: Colors.transparent),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(width: 1, color: Colors.transparent),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(width: 1, color: Colors.transparent),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(width: 1, color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(width: 1, color: Colors.red),
            ),
          ),
          primaryColor: Colors.blueAccent.shade700,
          fontFamily: 'alfont',
          scaffoldBackgroundColor: Colors.white,
          hintColor: Colors.blueGrey,
          appBarTheme: AppBarTheme(
              backgroundColor: Colors.blueAccent.shade700,
              elevation: 0.0,
              centerTitle: true,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20))),
      home: const IsLoggedIn(),
    );
  }
}
