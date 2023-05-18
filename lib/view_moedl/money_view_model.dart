import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../repository/money_repository.dart';


final moneyProvider =
StateNotifierProvider<moneyViewModel, List>((ref) {
  return moneyViewModel(
    ref.read,
  );
});

class moneyViewModel extends StateNotifier<List> {
  final _read;

  moneyViewModel(this._read) : super([]);


  dynamic getValue(Map<String, dynamic> map) {
    if (!map.containsKey('optionTitle') ||
        !map.containsKey('optionValue') ||
        map['optionTitle'] == '') {
      return map['n'];
    }
  }

  bool isAllNull(List list) {
    return list.every((element) => element == null);
  }

  Future<List> addRequest(List<Map<String, dynamic>> money) async {
    List<dynamic> results = money.map((map) => getValue(map)).toList();
    print(results);
    money.sort((a, b) => a['n'].compareTo(b['n']));
    print(money);
    if (isAllNull(results)) {
      Map<String, int> result = {};

      for (Map<String, dynamic> entry in money) {
        String title = entry['optionTitle'];
        int value = entry['optionValue'];

        result.putIfAbsent(title, () => value);
      }
      print(result);
      await _read(moneyRepositoryProvider).addMoney(money);
    }

    return results;
  }

  Future<void> getDay(DateTime now) async {
    state = await _read(moneyRepositoryProvider)
        .getDay(now.microsecondsSinceEpoch);
  }

  Future<void> getMonth(DateTime month) async {
    List<Map<String, dynamic>> maps = await _read(moneyRepositoryProvider).getMonth(month);
    List<Map<String, dynamic>>combine = combineByOptionTitle(maps);
    state = combine;
  }

  List<Map<String, dynamic>> combineByOptionTitle(List<Map<String, dynamic>> options) {
    Map<String, int> optionMap = {};

    for (var option in options) {
      final title = option['optionTitle'];
      final int value = option['optionValue'];
      if (optionMap.containsKey(title)) {
        optionMap[title] = optionMap[title]! + value;
      } else {
        optionMap[title] = value.toInt();
      }
    }

    return optionMap.entries
        .map((entry) =>
    {'optionTitle': entry.key, 'optionValue': entry.value})
        .toList();
  }
  Future<void> update(List dataList,DateTime change) async {
  await _read(moneyRepositoryProvider).update(dataList,change);
  print(dataList);
  state=dataList;
  }
}