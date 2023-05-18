import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../view_moedl/auth_view_model.dart';
import '../widgets/my_text_field.dart';
import 'employee/shift_view.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  String name = '';
  bool _isObscured = true;
  String? password;
  bool onTap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('プロフィール登録', style: TextStyle(fontSize: 15.sp)),
          toolbarHeight: 40.h,
        ),
        body:onTap
            ? Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: Colors.green,
            ))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('あなたの名前を入力してください。', style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 20.h),
            SizedBox(
              height: 50.h,
              width: 400.w,
              child: MyTextField(
                  onChanged: (value) {
                    name = value;
                  },
                  hintText: '田中花子'),
            ),
            SizedBox(height: 40.h),
            Text('第2のパスワードを入力してください。', style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 20.h),
            SizedBox(
                height: 50.h,
                width: 360.w,
                child: TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
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
                          _isObscured ? Icons.visibility_off : Icons.visibility,
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
                    if (value.length < 4) {
                      return 'パスワードは4文字以上';
                    }
                    password = value;
                    return null;
                  },
                )),
            SizedBox(
              height: 20.h,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (name == '' && password == null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return AlertDialog(
                          title: Text("未入力の項目があります。"),
                          actions: [
                            ElevatedButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            ElevatedButton(
                              child: Text("OK"),
                              onPressed: () => print('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      onTap = true;
                    });
                    await ref
                        .read(authViewModelProvider.notifier)
                        .name(name, password!);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShiftView()));
                    });
                  }
                },
                child: Text('登録完了！'))
          ],
        ));
  }
}
