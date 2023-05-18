import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final moneyRepositoryProvider =
    Provider<MoneyRepository>((ref) => MoneyRepository());

class MoneyRepository {
  final CollectionReference _requestsRef =
      FirebaseFirestore.instance.collection('money');

  Future<void> addMoney(List<Map<String, dynamic>> money) async {
    DateTime now = DateTime.now();
    int nowInt = DateTime(now.year, now.month, now.day).microsecondsSinceEpoch;
    await _requestsRef
        .doc(nowInt.toString())
        .set({'data': money, 'month': DateTime(now.year, now.month, now.day)});
  }

  Future<List> getDay(int id) async {
    var snapshot = await _requestsRef.doc(id.toString()).get();
    if (snapshot.exists) {
      Map m = snapshot.data() as Map;
      return m['data'];
    } else {
      print('fafdas');
      return [];
    }
  }

  Future<Object?> getMonth(DateTime first) async {
    final DateTime lastDayOfMonth = DateTime(first.year, first.month + 1, 0);

    final QuerySnapshot querySnapshot = await _requestsRef
        .where('month',
            isGreaterThanOrEqualTo: first, isLessThan: lastDayOfMonth //月末+1日
            )
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    List<dynamic> maps = [];
    for (DocumentSnapshot document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      List<dynamic> dataField = data['data']!;
      maps = maps + dataField;
    }
    List<Map<String, dynamic>> change = List<Map<String, dynamic>>.from(maps);
    return change;
  }

  Future<void> update(List dataList, DateTime change) async {
    int nowInt =
        DateTime(change.year, change.month, change.day).microsecondsSinceEpoch;
    await _requestsRef.doc(nowInt.toString()).set({
      'data': dataList,
      'month': DateTime(change.year, change.month, change.day)
    });
  }
}
