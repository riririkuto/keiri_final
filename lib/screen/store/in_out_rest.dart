import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../view_moedl/auth_view_model.dart';
import '../../view_moedl/kintai_view_model.dart';
import '../../widgets/alert_message.dart';
import '../../widgets/drawer.dart';
import '../../widgets/my_text_field.dart';

class InOutRest extends ConsumerStatefulWidget {
  const InOutRest({Key? key}) : super(key: key);

  @override
  ConsumerState<InOutRest> createState() => _InOutRestState();
}

class _InOutRestState extends ConsumerState<InOutRest> {
  List<DateTime> timeInfo = [];

  bool rest = false;
  String? name;
  late String uid;
  bool process = false;
  bool nameSuccess = false;
  String? password;
  bool passwordSuccess = false;

  @override
  void initState() {
    // TODO: implement initState
    ad();
    super.initState();
  }
  void ad() {
    var index = 0;
    while (index <= 2) {
      BannerAd bannerAd;

      bannerAd = BannerAd(
          size: AdSize.banner,
          adUnitId: Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/6300978111'
              : 'ca-app-pub-5187414655441156/7444145981',
          listener: BannerAdListener(onAdLoaded: (Ad ad) {
            setState(() {
              print('fads');
              loaded = true;
            });
          }),
          request: AdRequest())
        ..load();
      ads.add(bannerAd);

      index++;
    }
  }

  List<BannerAd> ads = [];
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    List<Map> info = ref.watch(kintaiProvider);
    print(info);
    DateTime now = DateTime.now();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: CustomDrawer(),
      appBar: AppBar(title: Text('出勤・退勤・休憩')),
      body: Center(
        child: Column(
          children: [
            Flexible(
              child: Column(
                children: [
                  Text(
                    '今日(${now.month}月${now.day}日)の記録',
                    style: TextStyle(fontSize: 25.sp),
                  ),
                  SizedBox(height: 5.h),
                  passwordSuccess
                      ? Column(
                          children: [
                            Text('$nameさんの記録',
                                style: TextStyle(fontSize: 15.sp)),
                            SizedBox(
                              height: 10.h,
                            )
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                                height: 55.h,
                                width: 380.w,
                                child: MyTextField(
                                    hintText: 'お名前を入力してください。',
                                    onChanged: (value) {
                                      name = value;
                                    })),
                            SizedBox(height: 15.h),
                            nameSuccess
                                ? SizedBox(
                                    height: 55.h,
                                    width: 380.w,
                                    child: MyTextField(
                                        number: true,
                                        hintText: '第二のパスワードを入力してください。',
                                        onChanged: (value) {
                                          password = value;
                                        }))
                                : SizedBox(),
                            process
                                ? Container(
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(
                                      color: Colors.green,
                                    ))
                                : ElevatedButton(
                                    onPressed: () async {
                                      if (!nameSuccess) {
                                        if (name == null) return;
                                        setState(() {
                                          process = true;
                                        });
                                        uid = await ref
                                            .read(
                                                authViewModelProvider.notifier)
                                            .nameSearch(name!);
                                        setState(() {
                                          process = false;
                                        });
                                        if (uid == 'Data does not exist.') {
                                          AlertMessageDialog.show(
                                              context, 'あなたの名前は登録されていません。', '');
                                        } else {
                                          nameSuccess = true;
                                        }
                                      } else {
                                        if (password == null) return;
                                        setState(() {
                                          process = true;
                                        });
                                        bool check = await ref
                                            .read(
                                                authViewModelProvider.notifier)
                                            .passwordCheck(uid, password!);
                                        setState(() {
                                          process = false;
                                        });

                                        if (check) {
                                          await ref
                                              .read(kintaiProvider.notifier)
                                              .get(uid, now);
                                          setState(() {
                                            passwordSuccess = true;
                                          });
                                        } else {
                                          AlertMessageDialog.show(
                                              context,
                                              '第二のパスワードが間違っています。',
                                              '第二のパスワードは数字のみのものです。');
                                        }
                                      }
                                    },
                                    child: Text(nameSuccess ? '決定' : '検索'),
                                  ),
                            nameSuccess
                                ? SizedBox(
                                    height: ads[0].size.height.toDouble(),
                                    width: ads[0].size.width.toDouble(),
                                    child: loaded
                                        ? AdWidget(ad: ads[0])
                                        : SizedBox(),
                                  )
                                : SizedBox(
                                    height: ads[1].size.height.toDouble(),
                                    width: ads[1].size.width.toDouble(),
                                    child: AdWidget(ad: ads[1])),
                          ],
                        ),
                  passwordSuccess
                      ? Column(
                          children: [
                            SizedBox(
                              height: 140.h,
                              child: ListView.builder(
                                physics: null,
                                itemCount: info.length,
                                itemBuilder: (BuildContext context, int index) {
                                  int countStart = info
                                      .where((m) => m['kind'] == '休憩開始')
                                      .length;
                                  int countEnd = info
                                      .where((m) => m['kind'] == '休憩終了')
                                      .length;
                                  if (countStart > countEnd) {
                                    rest = true;
                                  }
                                  Map m = info[index];
                                  late String val;
                                  print(m['val'].runtimeType);
                                  if (m['val'] is Timestamp) {
                                    print('fasdf');
                                    DateTime time = m['val'].toDate();
                                    val = '${time.hour}時${time.minute}分';
                                    print(val);
                                  } else if (m['val'] is DateTime) {
                                    DateTime time = m['val'];
                                    val = '${time.hour}時${time.minute}分';
                                  } else {
                                    val = '${m['val']}円';
                                  }
                                  return Column(children: [
                                    SizedBox(
                                      height: 30.h,
                                      width: double.infinity,
                                      child: Container(
                                        color: Colors.grey,
                                        child: Text(
                                          '${m['kind']}:$val',
                                          style: TextStyle(fontSize: 20.sp),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                  ]);
                                },
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                kindButton('出勤', Icons.input, Colors.blue),
                                kindButton('退勤', Icons.output, Colors.red),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                kindButton('休憩${rest ? '終了' : '開始'}',
                                    Icons.forest, Colors.green),
                                kindButton(
                                    'まかない', Icons.food_bank, Colors.orange),
                              ],
                            )
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: 5.h),

                ],
              ),
            ),
            loaded&&passwordSuccess
                ? SizedBox(
                height: ads[2].size.height.toDouble(),
                width: ads[2].size.width.toDouble(),
                child: AdWidget(ad: ads[2]))
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Column kindButton(String kind, IconData icon, Color color) {
    return Column(
      children: [
        SizedBox(
          height: 80.h,
          width: 80.w,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.zero,
              shape: CircleBorder(),
            ),
            onPressed: () async {
              if (kind == 'まかない') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String inputText = '';

                    return AlertDialog(
                      title: Text('何円分のまかないですか？'),
                      content: TextField(
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (text) {
                          inputText = text;
                        },
                      ),
                      actions: [
                        TextButton(
                          child: Text('キャンセル',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(inputText);
                          },
                        ),
                      ],
                    );
                  },
                ).then((result) async {
                  if (result != null) {
                    await ref.read(kintaiProvider.notifier).add(uid, result);
                  }
                });
              } else {
                if (kind == '休憩開始' || kind == '休憩終了') {
                  rest = !rest;
                }
                if (!ref.read(kintaiProvider.notifier).check() &&
                    kind == '退勤') {
                  await ref.read(kintaiProvider.notifier).add(uid, '休憩終了');
                }
                await ref.read(kintaiProvider.notifier).add(uid, kind);
              }
            },
            child: Icon(icon, size: 50.sp),
          ),
        ),
        Text(
          kind,
          style: TextStyle(fontSize: 25.sp),
        )
      ],
    );
  }
}
