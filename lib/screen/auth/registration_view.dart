import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


import '../../view_moedl/auth_view_model.dart';
import '../../widgets/my_text_field.dart';
import 'confirm_email.dart';
import 'login_view.dart';

class RegistrationView extends ConsumerStatefulWidget {
  const RegistrationView({Key? key}) : super(key: key);

  @override
  ConsumerState<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends ConsumerState<RegistrationView> {
  bool _isObscured = true;
  String? email;
  String? password;
  bool onPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 40.h,
          title: Text('登録'),
        ),
        body:onPressed?

        Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: Colors.green,
            )): SingleChildScrollView(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100.h,
              ),
              Text(
                '登録',
                style: TextStyle(fontSize: 40.sp),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginView()));
                },
                child: Text(
                  '既に登録済みの方はこちら(ログイン)',
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('メールアドレス', style: TextStyle(fontSize: 15.sp)),
                SizedBox(
                    height: 50.h,
                    width: 400.w,
                    child: MyTextField(
                        hintText: 'abc@example.com',
                        onChanged: (value) {
                          email = value;
                        })),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  'パスワード',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                ),
                SizedBox(
                    height: 50.h,
                    width: 360.w,
                    child: TextFormField(
                      // style: TextStyle(
                      //   color: Colors.black,
                      //   fontSize: 30.sp,
                      // ),
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        label: Text('パスワード'),
                        errorStyle: TextStyle(
                            // fontSize: 10.sp,
                            ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          // borderSide:
                          // BorderSide(width: 0.1.w, color: Colors.white)
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                              _isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 15.w),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'パスワードを入力してください';
                        }

                        // パスワードの長さが6文字以上でない場合はエラーを返す
                        if (value.length < 6) {
                          return 'パスワードは6文字以上';
                        }
                        password = value;
                        return null;
                      },
                    )),
              ]),
              SizedBox(
                height: 40.h,
              ),
              ElevatedButton(
                  child: Text('登録'),
                  onPressed: email != '' && password != '' && !onPressed
                      ? () async {
                          setState(() {
                            onPressed = true;
                          });
                          bool error = await ref
                              .read(authViewModelProvider.notifier)
                              .signUpWithEmailAndPassword(
                                  email: email!, password: password!);
                          sendOrError(
                            error,
                          );
                          setState(() {
                            onPressed = false;
                          });
                        }
                      : () {}),
            ],
          ),
        )));
  }

  void sendOrError(bool error) {
    if (!error) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const ConfirmEmail()));
    } else {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('エラーが発生しました。'),
            content: const Text("This is the content"),
            actions: [
              ElevatedButton(
                  child: Text("OK"), onPressed: () => Navigator.pop(context))
            ],
          );
        },
      );
    }
  }
}
