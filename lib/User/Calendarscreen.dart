import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AttedanceModel.dart'; // Adjust import as per your actual model

class Calendarscreen extends StatefulWidget {
  const Calendarscreen({Key? key}) : super(key: key);

  @override
  State<Calendarscreen> createState() => _CalendarscreenState();
}

class _CalendarscreenState extends State<Calendarscreen> {
  late List<AttendanceRecord> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    fetchAttendanceRecords();
  }

  Future<void> fetchAttendanceRecords() async {
    try {
      String userId = 'userId-18'; // Replace with actual user ID
      String year = '2024'; // Replace with actual year
      String month = '07'; // Replace with actual month (zero-padded if needed)

      print('Firestore query: ${FirebaseFirestore.instance.collection('Attendance').doc('$userId-$month-$year').collection('data').path}');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Attendance')
          .doc('$userId-$month-$year') // Correct document path
          .collection('data') // Access the nested collection 'data'
          .get();

      print('Fetched ${snapshot.docs.length} attendance records');

      List<AttendanceRecord> records = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        AttendanceRecord record = AttendanceRecord.fromMap(data, doc.id);
        print('Record: $record'); // Debug print
        return record;
      }).toList();

      setState(() {
        attendanceRecords = records;
      });
    } catch (e) {
      print('Error fetching attendance records: $e');
    }
  }

  Future<void> updateAttendanceRecordStatus(String recordId, String newStatus) async {
    try {
      String userId = 'userId-18'; // Replace with actual user ID
      String year = '2024'; // Replace with actual year
      String month = '07'; // Replace with actual month (zero-padded if needed)

      await FirebaseFirestore.instance
          .collection('Attendance')
          .doc('$userId-$month-$year') // Correct document path
          .collection('data') // Access the nested collection 'data'
          .doc(recordId)
          .update({'status': newStatus});

      print('Attendance record $recordId updated with status: $newStatus');

      // Optionally, you can update the local state as well if needed
      setState(() {
        var index = attendanceRecords.indexWhere((record) => record.id == recordId);
        if (index != -1) {
          attendanceRecords[index].status = newStatus;
        }
      });
    } catch (e) {
      print('Error updating attendance record: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Calendar'),
      ),
      body: attendanceRecords.isNotEmpty
          ? ListView.builder(
        itemCount: attendanceRecords.length,
        itemBuilder: (context, index) {
          AttendanceRecord record = attendanceRecords[index];
          return Card(
            child: ListTile(
              title: Text(
                'Date: ${record.date}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check-In: ${record.checkIn}'),
                  Text('Check-Out: ${record.checkOut}'),
                  Text('Status: ${record.status}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // Example of updating status
                  updateAttendanceRecordStatus(record.id, 'Present'); // Replace with your logic
                },
                child: Text('Mark Present'),
              ),
            ),
          );
        },
      )
          : Center(child: Text('No attendance records found')),
    );
  }
}