import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../main.dart';
import '../../view_moedl/shit_view_model.dart';
import '../../widgets/drawer.dart';

class ShiftView extends ConsumerStatefulWidget {
  const ShiftView({Key? key}) : super(key: key);

  @override
  ConsumerState<ShiftView> createState() => _ShiftViewState();
}

class _ShiftViewState extends ConsumerState<ShiftView> {
  @override
  void initState() {
    ad();
    super.initState();
  }

  void ad() {
    print('fadsfds');
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId:Platform.isAndroid? 'ca-app-pub-5187414655441156/3688733803':'ca-app-pub-5187414655441156/7444145981',
        listener: BannerAdListener(onAdLoaded: (Ad ad) {
          setState(() {
            print('fads');
            loaded = true;
          });
        }),
        request: AdRequest())
      ..load();
  }

  late BannerAd bannerAd;
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    List<Appointment> appointments = ref.watch(shiftProvider);

    return Scaffold(
      appBar: AppBar(title: Text('シフト確認')),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Flexible(
            child: Localizations.override(
              context: context,
              locale: Locale('ja'),
              child: SfCalendar(
                onViewChanged: (ViewChangedDetails details) async {
                  final List<DateTime> visibleDates = details.visibleDates;
                  final DateTime firstVisibleDate = visibleDates.first;
                  final int visibleYear = firstVisibleDate.year;
                  final int visibleMonth = firstVisibleDate.month;

                  // 現在の曜日を取得
                  int weekday = firstVisibleDate.weekday;
                  DateTime lastSunday = firstVisibleDate
                      .subtract(Duration(days: weekday))
                      .subtract(Duration(days: -7));
                  await ref.read(shiftProvider.notifier).shiftView(
                      lastSunday.year, lastSunday.month, lastSunday.day);
                  // 月を切り替えたときの処理をここに書く
                },
                dataSource: MeetingDataSource(appointments),
                view: CalendarView.week,
              ),
            ),
          ),
          loaded
              ? SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: bannerAd.size.width.toDouble(),
                  child: loaded ? AdWidget(ad: bannerAd) : SizedBox(),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
