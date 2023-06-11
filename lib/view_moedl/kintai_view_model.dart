import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repository/auth_repository.dart';
import '../repository/kintai_repository.dart';

final kintaiProvider = StateNotifierProvider<KintaiViewModel, List<Map>>((ref) {
  return KintaiViewModel(
    ref.read,
  );
});

class KintaiViewModel extends StateNotifier<List<Map>> {
  final _read;

  KintaiViewModel(this._read) : super([]);

  void update(List<Map> re) {
    print(re);

    state = [...re];
  }

  Future<void> updateFire(String uid, DateTime select) async {
    await _read(kintaiRepositoryProvider).updateFire(uid, select, state);
  }

  Future<void> addState(String kind, DateTime? time, int? makanai) async {
    bool error = false;
    if (kind == 'まかない') {
      state = [
        ...state,
        {'kind': kind, 'val': makanai}
      ];
    } else {
      state = [
        ...state,
        {'kind': kind, 'val': time}
      ];
    }
  }

  bool check() {
    List store = List.of(state);
    int a = 0;
    int b = 0;
    for (final attendance in store) {
      if (attendance['kind'] == '休憩開始') {
        a += 1;
      } else if (attendance['kind'] == '休憩終了') {
        b += 1;
      }
    }
    return a == b;
  }

  Future<void> add(String uid, String kind) async {
    DateTime now = DateTime.now();
    print('fadsfas');
    print(uid);
    bool error = false;
    try {
      int val = int.parse(kind);
    } catch (e) {
      print('fadfsadf');
      error = true;
      await _read(kintaiRepositoryProvider).add(uid, kind, [
        ...state,
        {'kind': kind, 'val': now}
      ]);
      state = [
        ...state,
        {'kind': kind, 'val': now}
      ];
    }
    if (error == false) {
      print('fdasfdsa');
      await _read(kintaiRepositoryProvider).add(uid, 'まかない', [
        ...state,
        {'kind': 'まかない', 'val': int.parse(kind)}
      ]);
      state = [
        ...state,
        {'kind': 'まかない', 'val': int.parse(kind)}
      ];
    }
  }

  Future<void> get(String uid, DateTime? day) async {
    state = await _read(kintaiRepositoryProvider).get(uid, day);
  }

  Future<void> delete(int index) async {
    List store = List.of(state);
    store.removeAt(index);
    state = [...store];
  }

  Future timeCalculator(String uid, List<List<Map<String, dynamic>>> lists,
      List<DateTime> dates) async {
    Duration totalWork = Duration();
    Duration totalBreak = Duration();
    int totalMeal = 0;
    int hourlyWage = await _read(authRepositoryProvider).getHourlyWage(uid);
    int times = 0;
    List<String> waste = [];
    for (List<Map<String, dynamic>> list in lists) {
      DateTime? start;
      DateTime? end;
      DateTime? startBreak;
      Duration breakDuration = Duration(minutes: 0);
      int meal = 0;
      for (Map<String, dynamic> map in list) {
        switch (map['kind']) {
          case '出勤':
            print(map['val']);
            start = map['val'].toDate();
            continue;
          case '退勤':
            end = map['val'].toDate();
            continue;
          case '休憩開始':
            startBreak = map['val'].toDate();
            continue;
          case '休憩終了':
            DateTime endBreak = map['val'].toDate();
            breakDuration = breakDuration + endBreak.difference(startBreak!);
            continue;
          case 'まかない':
            meal = map['val'];
            continue;
        }
      }
      if (end == null) {
        print(dates);
        DateTime day = dates[times];
        String dayStr = '${day.month}月${day.day}日';
        waste.add(dayStr);
        continue;
      } else {
        totalWork = totalWork + end.difference(start!);
        totalBreak = totalBreak + breakDuration;
        totalMeal = totalMeal + meal;
      }
      times++;
    }

    int kesu = (totalWork - totalBreak).inMinutes;
    print((totalWork - totalBreak).inMinutes);
    Duration zissitsu = Duration(minutes: (kesu / 15).floor() * 15);
    print(zissitsu.inMinutes);
    int mi = (hourlyWage ~/ 4) + ((hourlyWage % 4 == 0) ? 0 : 1);
    print(mi);
    print((zissitsu.inMinutes ~/ 4));
    int salary = (zissitsu.inMinutes ~/ 15) * mi - totalMeal;
    int salary1 = (zissitsu.inMinutes ~/ 15) * mi;

    return {
      'waste': waste,
      'totalWork': '${totalWork.inHours}時間 ${totalWork.inMinutes % 60}分',
      'totalBreak': '${totalBreak.inHours}時間 ${totalBreak.inMinutes % 60}分',
      'totalMeal': '$totalMeal円',
      'hourlyWage': '$hourlyWage円',
      'zissitsu': '${zissitsu.inHours}時間 ${zissitsu.inMinutes % 60}分',
      'salary': '$salary円',
          'salary1':'$salary1円'
    };
  }

  Future<Map> getMonth(String uid, DateTime month) async {
    Map test = await _read(kintaiRepositoryProvider).getMonth(uid, month);
    print(test);
    print(test['データ'].runtimeType);
    List<List<Map<String, dynamic>>> maps = test['データ'];

    List<DateTime> dates = test['日'];

    Map result = await timeCalculator(uid, maps, dates);
    print(result);
    return result;
  }
}
