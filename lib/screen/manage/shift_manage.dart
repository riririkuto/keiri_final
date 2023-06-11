import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../main.dart';
import '../../view_moedl/shit_view_model.dart';
import '../../widgets/drawer.dart';

class ShiftManage extends ConsumerStatefulWidget {
  const ShiftManage({Key? key}) : super(key: key);

  @override
  ConsumerState<ShiftManage> createState() => _ShiftManageState();
}

class _ShiftManageState extends ConsumerState<ShiftManage> {
  bool onTap = false;
  bool di = false;
  List<dynamic> selectAppointments = [];
  late Future<DateTime?> selectedDate;
  DateTime? date;

  late Future<TimeOfDay?> selectedTime;
  DateTime? startTime;
  bool adTap = false;
  DateTime? endTime;

  List<Map<String, DateTime>> sce = [];
  InterstitialAd? interstitialAd;

  late BannerAd bannerAd;
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    print('ss');
    List<Appointment> appointments = ref.watch(shiftProvider);
    return Scaffold(
        appBar: AppBar(title: Text('シフト管理画面')),
        drawer: CustomDrawer(),
        body: Column(children: [
          Flexible(
            // height: onTap ? 400.h : 570.h,
            child: Localizations.override(
              context: context,
              locale: Locale('ja'),
              child: SfCalendar(
                onViewChanged: (ViewChangedDetails details) async {
                  final List<DateTime> visibleDates = details.visibleDates;
                  final DateTime firstVisibleDate = visibleDates.first;
                  final int visibleYear = firstVisibleDate.year;
                  final int visibleMonth = firstVisibleDate.month + 1;
                  print(visibleYear);
                  print(visibleMonth);
                  await ref
                      .read(shiftProvider.notifier)
                      .shiftManage(visibleYear, visibleMonth);
                  // 月を切り替えたときの処理をここに書く
                },
                onTap: (s) {
                  setState(() {
                    onTap = true;
                  });
                  selectAppointments = s.appointments!;
                },
                dataSource: MeetingDataSource(appointments),
                monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment),

                // monthViewSettings : MonthViewSettings ( showAgenda : true ),
                // dataSource:[Appointment(startTime: DateTime.now(), endTime: DateTime.niw)],
                backgroundColor: Colors.white,
                view: CalendarView.month,
              ),
            ),
          ),
          onTap
              ? Column(
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            onTap = false;
                          });
                        },
                        child: Text(
                          'カレンダーの拡大',
                          style: TextStyle(fontSize: 15.sp),
                        )),
                    SizedBox(
                      height: 120.h,
                      child: ListView.builder(
                          itemCount: selectAppointments.length,
                          itemBuilder: (BuildContext context, int index) {
                            Appointment apo = selectAppointments[index];
                            String startTime =
                                '${apo.startTime.hour}時${apo.startTime.minute}分';
                            String endTime =
                                '${apo.endTime.hour}時${apo.endTime.minute}分';
                            return Column(
                              children: [
                                ListTile(
                                    trailing: IconButton(
                                      icon: Icon(Icons.more_vert),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) {
                                            return AlertDialog(
                                              title: Text('承認or非承認'),
                                              actions: [
                                                TextButton(
                                                    child: Text(
                                                      "戻る",
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                    }),
                                                TextButton(
                                                    child: Text(
                                                      "変更",
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                    onPressed: () async {
                                                      showDialogPicker(
                                                          context, apo);
                                                    }),
                                                TextButton(
                                                    child: Text(
                                                      "非承認",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                    onPressed: () async {
                                                      await ref
                                                          .read(shiftProvider
                                                              .notifier)
                                                          .statusChange(
                                                              apo.notes!, 1);
                                                      Navigator.pop(context);
                                                    }),
                                                TextButton(
                                                    child: Text("承認"),
                                                    onPressed: () async {
                                                      for (final selectApo
                                                          in selectAppointments) {
                                                        selectAppointments = [
                                                          if (selectApo.notes !=
                                                              apo.notes)
                                                            selectApo,
                                                        ];
                                                      }
                                                      await ref
                                                          .read(shiftProvider
                                                              .notifier)
                                                          .statusChange(
                                                              apo.notes!, 2);
                                                      Navigator.pop(context);
                                                    }),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    tileColor: Colors.grey,
                                    title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(apo.subject),
                                          Text('$startTime～$endTime')
                                        ])),
                                SizedBox(
                                  height: 5.h,
                                ),
                              ],
                            );
                          }),
                    )
                  ],
                )
              : const SizedBox(),
        ]));
  }

  void showDialogStartTimePicker(BuildContext context, Appointment apo) {
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

        showDialogEndTimePicker(context, apo);
      });
    }, onError: (error) {});
  }

  void showDialogEndTimePicker(BuildContext context, Appointment apo) {
    selectedTime = showTimePicker(
      helpText: '終了時刻を入力してください。',
      context: context,
      initialTime: getEndTime(),
      confirmText: '変更する',
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
    selectedTime.then((value) async {
      if (value == null) return;
      endTime = date!.add(Duration(hours: value.hour, minutes: value.minute));

      sce.add({'startTime': startTime!, 'endTime': endTime!});

      await ref
          .read(shiftProvider.notifier)
          .shiftRequest(sce, apo.notes, apo.subject);
      DateTime now = DateTime.now();
      await ref.read(shiftProvider.notifier).statusChange(apo.notes!, 1);
      await ref.read(shiftProvider.notifier).shiftManage(now.year, now.month);
      sce = [];
      setState(() {
        onTap = false;
      });
      Navigator.pop(context);
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

  void showDialogPicker(BuildContext context, Appointment apo) {
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
        showDialogStartTimePicker(context, apo);
      });
    }, onError: (error) {});
  }
}
