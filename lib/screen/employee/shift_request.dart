import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../view_moedl/shit_view_model.dart';
import '../../widgets/drawer.dart';

class ShiftRequest extends ConsumerStatefulWidget {
  const ShiftRequest({super.key});

  @override
  ShiftRequestState createState() => ShiftRequestState();
}

class ShiftRequestState extends ConsumerState<ShiftRequest> {
  late Future<DateTime?> selectedDate;
  DateTime? date;

  late Future<TimeOfDay?> selectedTime;
  DateTime? startTime;
  bool adTap = false;
  DateTime? endTime;

  List<Map<String, DateTime>> sce = [];
  bool onTap = false;
  InterstitialAd? interstitialAd;

  @override
  void initState() {
    _loadInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: Dispose an InterstitialAd object
    _interstitialAd?.dispose();

    super.dispose();
  }

  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-5187414655441156/3050277857'
          : 'ca-app-pub-5187414655441156/5652590159',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              adTap = true;
              showDialogPicker(context);
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      // backgroundColor: Colors.white,
      appBar: AppBar(title: Text('シフト申請')),
      body: onTap
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(

              ))
          : Column(
              children: <Widget>[
                const Spacer(flex: 10),
                SizedBox(
                  height: 300.h,
                  child: ListView.builder(
                    itemCount: sce.length,
                    itemBuilder: (BuildContext context, int index) {
                      DateTime startTimeDate = sce[index]['startTime']!;
                      DateTime endTimeDate = sce[index]['endTime']!;

                      return Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 45.h,
                        color: Colors.grey[300],
                        child: Text(
                            "${startTimeDate.year}年${startTimeDate.month}月${startTimeDate.day}日 ${startTimeDate.hour}時${startTimeDate.minute}分 ～ ${endTimeDate.hour}時${endTimeDate.minute}分"),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 30)),
                    child:
                        const Text("申請", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      if (!onTap) {
                        setState(() {
                          onTap = true;
                        });
                        await ref
                            .read(shiftProvider.notifier)
                            .shiftRequest(sce);
                        setState(() {
                          sce = [];
                          onTap = false;
                        });
                      } else {
                        null;
                      }
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () {
          if (adTap) {
            showDialogPicker(context);
          } else {
            _interstitialAd?.show();
            showDialogPicker(context);

          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void showDialogPicker(BuildContext context) {
    selectedDate = showDatePicker(
      locale: Locale('ja'),
      confirmText: '開始時刻へ',
      context: context,
      helpText: '勤務日',
      initialDate: date == null ? DateTime.now() : date!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              // primary: MyColors.primary,
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            //.dialogBackgroundColor:Colors.blue[900],
          ),
          child: child!,
        );
      },
    );
    selectedDate.then((value) {
      setState(() {
        if (value == null) return;
        date = DateTime(value.year, value.month, value.day);
        showDialogStartTimePicker(context);
      });
    }, onError: (error) {});
  }

  void showDialogStartTimePicker(BuildContext context) {
    selectedTime = showTimePicker(
      confirmText: '終了時刻へ',
      helpText: '開始時刻を入力してください。',
      context: context,
      initialTime: startTime == null
          ? const TimeOfDay(hour: 10, minute: 00)
          : TimeOfDay(hour: startTime!.hour, minute: startTime!.minute),
      builder: (BuildContext context, Widget? child) {
        final Widget mediaQueryWrapper = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
        // A hack to use the es_US dateTimeFormat value.
        if (Localizations.localeOf(context).languageCode == 'es') {
          return Localizations.override(
            context: context,
            locale: Locale('jp', 'JP'),
            child: mediaQueryWrapper,
          );
        }
        return mediaQueryWrapper;
      },
    );

    selectedTime.then((value) {
      setState(() {
        if (value == null) return;
        startTime =
            date!.add(Duration(hours: value.hour, minutes: value.minute));

        showDialogEndTimePicker(context);
      });
    }, onError: (error) {});
  }

  void showDialogEndTimePicker(BuildContext context) {
    selectedTime = showTimePicker(
      helpText: '終了時刻を入力してください。',
      context: context,
      initialTime: getEndTime(),
      builder: (BuildContext context, Widget? child) {
        final Widget mediaQueryWrapper = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
        // A hack to use the es_US dateTimeFormat value.
        if (Localizations.localeOf(context).languageCode == 'es') {
          return Localizations.override(
            context: context,
            locale: Locale('es', 'US'),
            child: mediaQueryWrapper,
          );
        }
        return mediaQueryWrapper;
      },
    );
    selectedTime.then((value) {
      setState(() {
        if (value == null) return;
        endTime = date!.add(Duration(hours: value.hour, minutes: value.minute));

        setState(() {
          sce.add({'startTime': startTime!, 'endTime': endTime!});
        });
      });
    }, onError: (error) {});
  }

  getEndTime() {
    switch (startTime!.hour) {
      case 10:
        return const TimeOfDay(hour: 15, minute: 0);
      case 14:
      case 14:
        return const TimeOfDay(hour: 18, minute: 0);
      case 17:
        return const TimeOfDay(hour: 22, minute: 30);
      default:
        return TimeOfDay.now();
    }
  }
}

class Utils {
  static String getFormattedDateSimple(int time) {
    DateFormat newFormat = DateFormat("MMMM dd, yyyy");
    return DateFormat.yMMMd('ja')
        .format(DateTime.fromMillisecondsSinceEpoch(time))
        .toString();
  }
}
