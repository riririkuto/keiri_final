import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:keiri_new/main.dart';
import 'package:keiri_new/screen/auth/password_reset_screen.dart';
import 'package:keiri_new/screen/auth/registration_view.dart';

import '../../view_moedl/auth_view_model.dart';
import '../../widgets/alert_message.dart';
import '../../widgets/my_text_field.dart';
import '../employee/shift_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  bool _isObscured = true;
  String? email;
  String? password;
  bool onTap = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('ログイン'), automaticallyImplyLeading: false),
        body: onTap
            ? Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Colors.green,
                ))
            : SingleChildScrollView(
                child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100.h,
                    ),
                    Text(
                      'ログイン',
                      style: TextStyle(fontSize: 40.sp),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RegistrationView()));
                      },
                      child: const Text('まだ登録がお済みでない方はこちら'),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                  'メールアドレス',
                                ),
                                SizedBox(
                                    height: 55.h,
                                    width: 400.w,
                                    child: MyTextField(
                                        hintText: 'abc@example.com',
                                        onChanged: (value) {
                                          email = value;
                                        })),
                                SizedBox(
                                  height: 30.h,
                                ),
                                const Text(
                                  'パスワード',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                    width: 400.w,
                                    child: TextFormField(
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      obscureText: _isObscured,
                                      decoration: InputDecoration(
                                        label: Text('パスワード'),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        suffixIcon: IconButton(
                                          icon: Icon(_isObscured
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                          onPressed: () {
                                            setState(() {
                                              _isObscured = !_isObscured;
                                            });
                                          },
                                        ),
                                      ),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
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
                        child: Text('ログイン'),
                        onPressed: () async {
                          if (onTap) {
                            null;
                          } else {
                            if (email == '' || password == null) {
                              AlertMessageDialog.show(
                                  context, 'メールアドレスまたはパスワードが正しく入力されていません', '');
                            } else {
                              setState(() {
                                onTap = true;
                              });
                              String error = await ref
                                  .read(authViewModelProvider.notifier)
                                  .signInWithEmailAndPassword(
                                      email: email!, password: password!);
                              if (error == '成功') {
                                // await ref.read(joinGroupsProvider.notifier).login();
                                // await ref.read(todoProvider.notifier).readTodo();
                                await ref
                                    .read(authViewModelProvider.notifier)
                                    .readProfile();
                                if (!mounted) return;
                                ref.read(drawerIndexProvider.notifier).state=0;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ShiftView()));
                              } else {
                                if (!mounted) return;
                                AlertMessageDialog.show(context, error, '');
                                setState(() {
                                  onTap = false;
                                });
                              }
                            }
                          }
                        }),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PasswordResetScreen()));
                      },
                      child: const Text('パスワードを忘れた方はこちら'),
                    ),
                  ],
                ),
              )));
  }
}
