import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../screen/auth/login_view.dart';
import '../screen/employee/shift_request.dart';
import '../screen/employee/shift_view.dart';
import '../screen/manage/money_manage_decision.dart';
import '../screen/manage/shift_manage.dart';
import '../screen/manage/staff_kintai.dart';
import '../screen/store/in_out_rest.dart';
import '../screen/store/money_manage.dart';
import '../view_moedl/auth_view_model.dart';
import '../view_moedl/kintai_view_model.dart';
import '../view_moedl/money_view_model.dart';
import '../view_moedl/shit_view_model.dart';

StateProvider<InterstitialAd?> adProvider = StateProvider((ref) => null);
StateProvider<bool> next = StateProvider((ref) => false);

class CustomDrawer extends ConsumerStatefulWidget {
  CustomDrawer({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  String? photoURLSend;
  InterstitialAd? _interstitialAd;
  bool ready = true;
  var seni;
  bool isLoad = true;

  @override
  void initState() {
    print('foidjasklfjs');
    print((ref.read(drawerTapProvider.notifier).state + 1) % 3 == 0);
    if ((ref.read(drawerTapProvider.notifier).state + 1) % 3 == 0) {
      isLoad = false;
      _loadInterstitialAd();
    }
    // TODO: implement initState
    super.initState();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/8691691433'
          : 'ca-app-pub-5187414655441156/5652590159',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ref.read(adProvider.notifier).state = ad;
          _interstitialAd = ad;
          ref.read(adProvider.notifier).state = ad;
          setState(() {
            isLoad = true;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  // TODO: Implement _loadInterstitialAd()

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider);
    final colorIndex = ref.watch(drawerIndexProvider);

    return Drawer(
      width: 250.w,
      child: !isLoad
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator())
          : Column(
              children: <Widget>[
                SizedBox(
                  height: 140.h,
                  child: UserAccountsDrawerHeader(
                    accountName: Text(
                      user?.displayName ?? '名称未設定',
                      style: TextStyle(color: Colors.white, fontSize: 15.sp),
                    ),
                    accountEmail: Text(
                      user?.email ?? 'メールアドレス未設定',
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                    otherAccountsPictures: [],
                  ),
                ),
                SizedBox(
                  height: 420.h,
                  child: ListView(children: [
                    drawerTile(0, 'シフト確認', ref, colorIndex, context),
                    drawerTile(1, 'シフト申請', ref, colorIndex, context),
                    user!.uid == 'q8FdKn3hVaTYkud5SgNF9uyHLrX2' ||
                            user.uid == 'yXfnZ9fbVnNRumVDdSoBQhRDtDs2'
                        ? drawerTile(2, '出勤退勤休息', ref, colorIndex, context)
                        : SizedBox(),
                    user.uid == 'q8FdKn3hVaTYkud5SgNF9uyHLrX2' ||
                            user.uid == 'yXfnZ9fbVnNRumVDdSoBQhRDtDs2'
                        ? drawerTile(3, '売上仕入申請', ref, colorIndex, context)
                        : SizedBox(),
                    user.uid == 'yXfnZ9fbVnNRumVDdSoBQhRDtDs2'
                        ? drawerTile(4, 'シフト申請状況', ref, colorIndex, context)
                        : SizedBox(),
                    user.uid == 'yXfnZ9fbVnNRumVDdSoBQhRDtDs2'
                        ? drawerTile(5, '売上仕入申請確認', ref, colorIndex, context)
                        : SizedBox(),
                    user.uid == 'yXfnZ9fbVnNRumVDdSoBQhRDtDs2'
                        ? drawerTile(6, 'スタッフ出勤状況', ref, colorIndex, context)
                        : SizedBox(),
                  ]),
                ),
                SizedBox(height: 5.h),
                TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    minimumSize: MaterialStateProperty.all(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    final url =
                        Uri.parse('https://note.com/l_s_c/n/n1e3005e5745d');
                    launchUrl(url);
                  },
                  child: Text('プライバシーポリシー',
                      style: TextStyle(color: Colors.grey, fontSize: 15.sp)),
                ),
                TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      minimumSize: MaterialStateProperty.all(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('ログアウト',
                        style: TextStyle(color: Colors.grey, fontSize: 15.sp)),
                    onPressed: () async {
                      await ref.read(authViewModelProvider.notifier).signOut();
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => LoginView(),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                    }),
              ],
            ),
    );
  }

  SizedBox drawerTile(int index, String title, WidgetRef ref, int colorIndex,
      BuildContext context) {
    return SizedBox(
      height: 65.h,
      child: InkWell(
        onTap: () async {
          ref.read(drawerIndexProvider.notifier).state = index;
          ref.read(drawerTapProvider.notifier).state =
              ref.read(drawerTapProvider.notifier).state + 1;

          switch (title) {
            case 'シフト確認':
              DateTime now = DateTime.now();

              int weekday = now.weekday;

              DateTime lastSunday = now
                  .subtract(Duration(days: weekday))
                  .subtract(Duration(days: -7));
              await ref
                  .read(shiftProvider.notifier)
                  .shiftView(lastSunday.year, lastSunday.month, lastSunday.day);

              seni = const ShiftView();
              break;
            case 'シフト申請':
              seni = const ShiftRequest();
              break;
            case '出勤退勤休息':
              seni = const InOutRest();
              break;
            case '売上仕入申請':
              seni = const MoneyManage();
              break;
            case 'シフト申請状況':
              DateTime now = DateTime.now();
              await ref
                  .read(shiftProvider.notifier)
                  .shiftManage(now.year, now.month);
              seni = const ShiftManage();
              break;
            case '売上仕入申請確認':
              DateTime now = DateTime.now();
              DateTime zeroed = DateTime(now.year, now.month, now.day);
              ref.read(moneyProvider.notifier).getDay(zeroed);
              seni = MoneyManageDecision(now: zeroed);
              break;
            case 'スタッフ出勤状況':
              ref.read(kintaiProvider.notifier).state = [];
              seni = StaffKintai();
          }

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => seni));
          int a = 0;

          var random = Random();
          int randomBit = random.nextInt(2);
          print('feafdas');
          print(randomBit);
          if ((ref.read(drawerTapProvider.notifier).state) % 3 == 0) {
            if (randomBit == 0) {
              ref.read(adProvider.notifier).state?.show();
            } else if (randomBit == 1) {
              ref.read(next.notifier).state = true;
            }
          } else if (ref.read(next.notifier).state) {
            ref.read(next.notifier).state = false;
            ref.read(adProvider.notifier).state?.show();
          }
        },
        child: Container(
          width: double.infinity,
          color: index == colorIndex ? Colors.red : Colors.transparent,
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontSize: 30.sp)),
        ),
      ),
    );
  }
}
