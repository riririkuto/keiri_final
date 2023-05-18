import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final kintaiRepositoryProvider =
    Provider<MoneyRepository>((ref) => MoneyRepository());

class MoneyRepository {
  final CollectionReference _requestsRef =
      FirebaseFirestore.instance.collection('kintai');

  Future<void> add(String uid, String kind, List<Map> already) async {
    DateTime now = DateTime.now();
    int nowInt =
        DateTime(now.year, now.month, now.day).microsecondsSinceEpoch ;

    await _requestsRef.doc(nowInt.toString() + uid).set({
      'data': already,
      'uid': uid,
      'createDay': DateTime(now.year, now.month, now.day)
    });
  }

  Future<void> updateFire(String uid, DateTime select, List<Map> state) async {
    int nowInt =
        DateTime(select.year, select.month, select.day).microsecondsSinceEpoch ;
    await _requestsRef.doc(nowInt.toString() + uid).update({'data': state});
  }

  Future<List<Map>> get(String uid, DateTime? day) async {
    day ??= DateTime.now();
    int id = DateTime(day.year, day.month, day.day).microsecondsSinceEpoch;
    var snapshot = await _requestsRef.doc(id.toString() + uid).get();
    if (snapshot.exists) {
      print('fasdfdsa');
      Map m = snapshot.data() as Map;
      return List<Map<String, dynamic>>.from(m['data']);
    } else {
      print('fdsafda');
      return [];
    }
  }

  Future<Map<String, List>> getMonth(String uid, DateTime first) async {
    final DateTime lastDayOfMonth = DateTime(first.year, first.month + 1, 0);

    final QuerySnapshot querySnapshot = await _requestsRef
        .where('createDay',
            isGreaterThanOrEqualTo: first, isLessThan: lastDayOfMonth)
        .where('uid', isEqualTo: uid)
        .get();

    final List<DocumentSnapshot> documents = querySnapshot.docs;
    List<List<Map<String, dynamic>>> maps = [];
    List<DateTime> dates = [];

    for (DocumentSnapshot document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      List<Map<String, dynamic>> dataField =
          List<Map<String, dynamic>>.from(data['data']!);
      maps.add(dataField);
      dates.add(data['createDay'].toDate());
    }

    List<List<Map<String, dynamic>>> change =
        List<List<Map<String, dynamic>>>.from(maps);

    return {'データ': change, '日': dates};
  }
}
