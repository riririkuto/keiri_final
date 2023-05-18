import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class ShiftModel {
  final String uid;
  final String name;
  final DateTime startTime;
  final DateTime endTime;

  const ShiftModel({
    required this.uid,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  factory ShiftModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ShiftModel(
      uid: doc.id,
      name: data['title'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
    );
  }
}
