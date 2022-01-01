import 'package:flutter/material.dart';
import 'package:garaj/viewmodel/auth_controller.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GetBuilder<AuthController>(
                  init: AuthController(),
                  builder: (auth) {
                    return Form(
                      key: auth.signUpFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 100,
                          ),
                          Row(
                            children: [
                              Text(
                                'signUp'.tr,
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
                                    auth.securePassword = !auth.securePassword;
                                    auth.update();
                                  },
                                  child: Icon(
                                    auth.securePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 18,
                                  )),
                            ),
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
                              auth.signUp();
                            },
                            child: Text(
                              'signUp'.tr,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
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
