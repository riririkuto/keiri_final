import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:keiri_new/screen/employee/shift_view.dart';
import 'package:keiri_new/view_moedl/auth_view_model.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'firebase_options.dart';
import 'screen/auth/login_view.dart';

StateProvider<int> drawerIndexProvider = StateProvider((ref) => 0);

void main() async {
  Duration duration=Duration(hours:1,minutes: 22);
  int hours = duration.inHours;
  print(duration.inMinutes);
  int minutes = (duration.inMinutes % 60);
  print('$hours時間 $minutes分');

  WidgetsFlutterBinding.ensureInitialized();
  // Firebase CLIのときはこの設定を書く
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(authViewModelProvider.notifier).readProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 640),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale("en"),
              const Locale('ja'),
            ],
            // locale: const Locale('ja'),
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: ref.watch(authViewModelProvider) == null
                ? LoginView()
                : ShiftView(),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    print(
      DateTime.now(),
    );
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.grey, title: Text('カレンダー')),
      body: Localizations.override(
        context: context,
        locale: Locale('ja'),
        child: SfCalendar(
          backgroundColor: Colors.white,
          view: CalendarView.week,
          firstDayOfWeek: 6,
          initialDisplayDate: DateTime.now(),
          //initialSelectedDate: DateTime(2021, 03, 01, 08, 30),
          dataSource: MeetingDataSource(getAppointments()),
        ),
      ),
    );
  }
}

List<Appointment> getAppointments() {
  List<Appointment> meetings = <Appointment>[];
  final DateTime today = DateTime.now();
  print(today.day);

  final DateTime startTime =
      DateTime(today.year, today.month, today.day, 9, 0, 0).toLocal();
  final DateTime endTime = startTime.add(const Duration(hours: 2)).toLocal();

  meetings.add(Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: '松村',
      color: Colors.blue,
      // recurrenceRule: 'FREQ=DAILY;COUNT=10',
      isAllDay: false));

  meetings.add(Appointment(
      startTime: startTime.add(Duration(hours: 1)),
      endTime: endTime.add(Duration(hours: 1)),
      subject: '自分',
      color: Colors.red,
      // recurrenceRule: 'FREQ=DAILY;COUNT=10',
      isAllDay: false));
  meetings.add(Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: '長野',
      color: Colors.blue,
      // recurrenceRule: 'FREQ=DAILY;COUNT=10',
      isAllDay: false));
  meetings.add(Appointment(
      startTime: startTime.add(Duration(hours: 32)),
      endTime: endTime.add(Duration(hours: 35)),
      subject: '田中',
      color: Colors.blue,
      // recurrenceRule: 'FREQ=DAILY;COUNT=10',
      isAllDay: false));

  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
