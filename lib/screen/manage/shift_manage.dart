import 'dart:io';

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
                onViewChanged: (ViewChangedDetails details) async{
                  final List<DateTime> visibleDates = details.visibleDates;
                  final DateTime firstVisibleDate = visibleDates.first;
                  final int visibleYear = firstVisibleDate.year;
                  final int visibleMonth = firstVisibleDate.month+1;
                print( visibleYear);
                print(visibleMonth);
                 await ref.read(shiftProvider.notifier).shiftManage(visibleYear,visibleMonth);
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
}
