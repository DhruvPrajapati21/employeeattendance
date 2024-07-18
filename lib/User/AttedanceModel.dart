import 'package:flutter/material.dart';
class AttendanceRecord {
  String id;
  String date;
  String checkIn;
  String checkOut;
  String status;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> data, String recordId) {
    return AttendanceRecord(
      id: recordId,
      date: data['date'] ?? '',
      checkIn: data['checkIn'] ?? '',
      checkOut: data['checkOut'] ?? '',
      status: data['status'] ?? '',
    );
  }
}