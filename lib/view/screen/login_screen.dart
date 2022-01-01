import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:garaj/view/screen/forget_password_screen.dart';
import 'package:garaj/view/screen/sign_up_screen.dart';
import 'package:garaj/view/widgets/change_language_widget.dart';
import 'package:garaj/viewmodel/auth_controller.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GetBuilder<AuthController>(
                  init: AuthController(),
                  builder: (auth) {
                    return Form(
                      key: auth.loginFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 100,
                          ),
                          Image.asset(
                            'assets/icons/logo.png',
                            width: Get.width / 1.5,
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          Row(
                            children: [
                              Text(
                                'login'.tr,
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: auth.email,
                            validator: (v) {
                              if (GetUtils.isEmail(v!)) return null;
                              return 'invalidEmail'.tr;
                            },
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintText: 'email'.tr),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            obscureText: auth.securePassword,
                            validator: (v) {
                              if (v!.length > 5) return null;
                              return 'invalidPassword'.tr;
                            },
                            controller: auth.password,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                hintText: 'password'.tr,
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      auth.securePassword=!auth.securePassword;
                                      auth.update();
                                    },
                                    child: Icon(auth.securePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,size: 18,)),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Get.to(const ForgetPassword());
                                  },
                                  child: Text('forgetPassword'.tr)),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          MaterialButton(
                            height: 45,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            minWidth: Get.width,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              if (auth.loginFormKey.currentState!.validate()) {
                                auth.login();
                              }
                            },
                            child: Text(
                              'login'.tr,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text('dontHaveAccount'.tr + "\t"),
                              GestureDetector(
                                onTap: () {
                                  Get.to(const SignUpScreen());
                                },
                                child: Text(
                                  'signUp'.tr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          ChangeLanguageWidget(),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
