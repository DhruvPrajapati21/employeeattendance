import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String documentId;
  final String department;
  final String name;
  final String id;
  final String emailid;
  final String phonenumber;
  final String bloodgroup;
  final String dob;
  final String doj;
  late final String imageurl;

  Employee({
    required this.documentId,
    required this.department,
    required this.name,
    required this.id,
    required this.emailid,
    required this.phonenumber,
    required this.bloodgroup,
    required this.dob,
    required this.doj,
    required this.imageurl
  });

  factory Employee.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    print('Data from Firestore: $data');
    return Employee(
      documentId: snapshot.id,
      department: data['department'] ?? '',
      name: data['name'] ?? '',
      id: data['id'] ?? '',
      emailid: data['emailid'] ?? '',
      phonenumber: data['phonenumber'] ?? '',
      bloodgroup: data['bloodgroup'] ?? '',
      dob: data['dob'] is Timestamp ? (data['dob'] as Timestamp).toDate().toString() : data['dob'],
      doj: data['doj'] is Timestamp ? (data['doj'] as Timestamp).toDate().toString() : data['doj'],
        imageurl: data['imageurl'] ?? ''
    );
  }
}
