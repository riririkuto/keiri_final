import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../view_moedl/auth_view_model.dart';
import '../../widgets/my_text_field.dart';
import 'confirm_email.dart';

class ChangeEmail extends ConsumerStatefulWidget {
  const ChangeEmail({Key? key}) : super(key: key);

  @override
  ConsumerState<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends ConsumerState<ChangeEmail> {
  bool _isObscured = true;
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    String email = '';
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 40.h,
          title: Text('メールアドレスの変更', style: TextStyle(fontSize: 15.sp)),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            iconSize: 15.sp,
            icon: const Icon(Icons.arrow_back),
          )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                '現在のパスワード',
                style: TextStyle(color: Colors.grey, fontSize: 15.sp),
              ),
              Spacer()
            ],
          ),

          SizedBox(
            height: 50.h,
            child: TextFormField(
              style:  TextStyle(
                fontSize: 30.sp,
                color: Colors.black,
              ),
              obscureText: _isObscured,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(width: 0.1.w, color: Colors.white)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon:
                  Icon(_isObscured ? Icons.visibility_off : Icons.visibility,size: 15.sp),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                '変更後のメールアドレス',
                style: TextStyle(color: Colors.grey, fontSize: 15.sp),
              ),
              const Spacer()
            ],
          ),
          SizedBox(height: 5.h),
          MyTextField(
            hintText: 'abc@example.com',
            onChanged: (value) {
              email = value;
            },
          ),
          SizedBox(height: 50.h),
          SizedBox(
            height: 50.h,
            width: 100.w,
            child: ElevatedButton(
                onPressed: () async {
                  String beforeEmail = ref.read(authViewModelProvider)!.email!;
                  if (password == "" || email == '') {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text('パスワード、メールアドレスを入力してください。'),
                          actions: [
                            ElevatedButton(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  String error = await ref
                      .read(authViewModelProvider.notifier)
                      .signInWithEmailAndPassword(
                      email: beforeEmail, password: password);
                  if (error != '成功') {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text(error),
                          content: const Text("This is the content"),
                          actions: [
                            ElevatedButton(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    bool emailVerified = await ref
                        .read(authViewModelProvider.notifier)
                        .updateEmailAndSendVerificationEmail(email);
                    if (!emailVerified) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ConfirmEmail()));
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title:
                            const Text('エラーが発生しました。そのメールアドレスは使えないかもしれません。'),
                            content: const Text("This is the content"),
                            actions: [
                              ElevatedButton(
                                child: const Text("OK"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
                child:  Text('変更',style: TextStyle(fontSize: 25.sp,color: Colors.white),)),
          ),
          SizedBox(
            height: 50.h,
          ),
          Text(
            'メールをご確認いただき、再度ログインしていただく必要があります。',
            style: TextStyle(color: Colors.white,fontSize: 11.sp),
          )
        ],
      ),
    );
  }
}
