import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 // Import your edit profile screen file

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String userName = '';
  late String userEmail = '';
  late String userPhone = '';
  late String userAddress = '';
  late String userDepartment = ''; // Add department variable

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Replace 'userId' with your actual user ID retrieval logic
    String userId = 'userId';

    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (snapshot.exists) {
      setState(() {
        userName = snapshot['Name'];
        userEmail = snapshot['Email'];
        userPhone = snapshot['Phone'];
        userAddress = snapshot['Address'];
        userDepartment = snapshot['Department']; // Update with your field name
      });
    }
  }

  // void editProfile() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => EditProfileScreen(
  //         userId: 'userId', // Pass userId to edit profile screen
  //         initialName: userName,
  //         initialEmail: userEmail,
  //         initialPhone: userPhone,
  //         initialAddress: userAddress,
  //         initialDepartment: userDepartment,
  //       ),
  //     ),
  //   ).then((_) {
  //     // Refresh profile data after edit
  //     fetchUserData();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.edit),
          //   onPressed: editProfile,
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  // You can add image decoration here if you have the user's profile picture
                ),
                // Add image widget if you have user profile picture
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Department',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    userDepartment,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Phone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    userPhone,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    userAddress,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
