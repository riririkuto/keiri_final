import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final shiftRepositoryProvider =
    Provider<ShiftRepository>((ref) => ShiftRepository());

class ShiftRepository {
  final CollectionReference _requestsRef =
      FirebaseFirestore.instance.collection('shifts');

  Future<void> addShift(List<Map<String, DateTime>> shifts) async {
    User myProfile = FirebaseAuth.instance.currentUser!;
    String name = myProfile.displayName!;
    String uid = myProfile.uid;
    Map<String, int> intM = {'status': 0};
    for (Map shift in shifts) {
      String id = DateTime.now().microsecondsSinceEpoch.toString();
      Map<String, String> profile = {'name': name, 'uid': uid, 'id': id};
      Map<String, dynamic> sum = {...shift, ...profile, ...intM};
      await _requestsRef.doc(id).set(sum);
    }
  }
  Future<List<Appointment>> shiftView(int year,int month,int day) async {
    DateTime start = DateTime(year,month, day);

    DateTime end = DateTime(
      year,
      month,
      day+6,
      23,
      59,
    );

    QuerySnapshot snapshot = await _requestsRef
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThanOrEqualTo: end)
        .where('status', isEqualTo: 2)
        .get();

    List<Appointment> appointments = [];
    snapshot.docs.forEach((DocumentSnapshot document) {
      Map? data = document.data() as Map?;
      print(data!['name']);
      print(data['startTime']);
      appointments.add(
        Appointment(
          notes: data!['id'],
          subject: data!['name'],
          startTime: (data['startTime'] as Timestamp).toDate(),
          endTime: (data['endTime'] as Timestamp).toDate(),
        ),
      );
    });
    print('s');
    print(appointments.length);
    return appointments;

  }

  Future<List<Appointment>> shiftManage(int year,int month) async {

    DateTime start = DateTime(year,month, 1);

    DateTime end = DateTime(
     year,
     month + 1,
      0,
      23,
      59,
    );

    QuerySnapshot snapshot = await _requestsRef
        .where('startTime', isGreaterThanOrEqualTo: start)
        .where('startTime', isLessThanOrEqualTo: end)
        .where('status', isEqualTo: 0)
        .get();

    List<Appointment> appointments = [];
    snapshot.docs.forEach((DocumentSnapshot document) {
      Map? data = document.data() as Map?;
      print(data!['name']);
      print(data['startTime']);
      appointments.add(
        Appointment(
          notes: data!['id'],
          subject: data!['name'],
          startTime: (data['startTime'] as Timestamp).toDate(),
          endTime: (data['endTime'] as Timestamp).toDate(),
        ),
      );
    });
    print('s');
    print(appointments.length);
    return appointments;
  }
  Future<void>statusChange(String id,int status)async {
    await _requestsRef.doc(id).update({'status':status});
  }



}
