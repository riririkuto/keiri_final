import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../main.dart';
import '../../view_moedl/shit_view_model.dart';
import '../../widgets/drawer.dart';

class ShiftView extends ConsumerWidget {
  const ShiftView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Appointment> appointments = ref.watch(shiftProvider);
    return Scaffold(
        appBar: AppBar(title: Text('シフト確認')),
        drawer: CustomDrawer(),
        body: Localizations.override(
          context: context,
          locale: Locale('ja'),
          child: SfCalendar(
            onViewChanged: (ViewChangedDetails details) async {
              final List<DateTime> visibleDates = details.visibleDates;
              final DateTime firstVisibleDate = visibleDates.first;
              final int visibleYear = firstVisibleDate.year;
              final int visibleMonth = firstVisibleDate.month ;

              // 現在の曜日を取得
              int weekday = firstVisibleDate.weekday;
              DateTime lastSunday = firstVisibleDate.subtract(Duration(days: weekday)).subtract(Duration(days: -7));
              await ref
                  .read(shiftProvider.notifier)
                  .shiftView(lastSunday.year, lastSunday.month,lastSunday.day);
              // 月を切り替えたときの処理をここに書く
            },
            dataSource: MeetingDataSource(appointments),
            view: CalendarView.week,
          ),
        ));
  }
}
