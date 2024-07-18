import 'package:fbserviceauthentication/Allemployees/Allemaployees.dart';
import 'package:fbserviceauthentication/Attendance/Attendance.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fbserviceauthentication/Admin/Admin.dart';
import 'package:fbserviceauthentication/Appdevelopment/Appdeveloper.dart';
import 'package:fbserviceauthentication/DIgitalmarketing/Digitalmarketing.dart';
import 'package:fbserviceauthentication/Graphics/Graphics.dart';
import 'package:fbserviceauthentication/Vidioeditor/Vidioeditor.dart';
import 'package:fbserviceauthentication/Webdevelopment/Webdeveloper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'Authentication/Login.dart';
import 'Employee/Addemployee.dart';
import 'Guildlines/Addguildlines.dart';
import 'Provider.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.setPersistence(Persistence.NONE);

  // Check if the user is already logged in
  User? user = FirebaseAuth.instance.currentUser;
  Widget homeScreen = user != null ? Admin() : Login();

  runApp(MyApp(homeScreen: homeScreen));
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;

  const MyApp({required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faydabazar',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: homeScreen,
    );
  }
}

class Adminscreen extends StatefulWidget {
  const Adminscreen({Key? key}) : super(key: key);

  @override
  State<Adminscreen> createState() => _AdminscreenState();
}

class _AdminscreenState extends State<Adminscreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDialogShowing = false;

  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
      return false;
    } else if (!_isDialogShowing) {
      _isDialogShowing = true;
      bool? confirmExit = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text(
            'Exit Faydabazar App?',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          content: const Text(
            'Are you sure you want to exit?',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _isDialogShowing =
                    false; // Reset _isDialogShowing before closing the dialog
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _isDialogShowing =
                    false; // Reset _isDialogShowing before closing the dialog
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      return confirmExit ?? false;
    } else {
      return false;
    }
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Logout Faydabazar App?",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.width * 0.35,
        width: MediaQuery.of(context).size.width * 0.35,
        child: Card(
          color: Colors.white70,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 10.0,
          margin: EdgeInsets.all(10.0),
          shadowColor: Colors.black87,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var documents;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: Text(
            "Faydabazar",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width *
              0.75, // Responsive drawer width
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.cyan),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/Logo_Final.png'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Admin()));
                },
              ),
              Divider(
                thickness: 2,
              ),
              ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text("Add Employee Data"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddEmployee()));
                },
              ),
              Divider(
                thickness: 2,
              ),
              ListTile(
                leading: const Icon(Icons.announcement),
                title: const Text("Add Guidelines"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddGuidelines()));
                },
              ),
              Divider(
                thickness: 2,
              ),
              ListTile(
                leading: const Icon(Icons.sunny_snowing, size: 25),
                title: const Text("Theme"),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                  Navigator.pop(context);
                },
              ),
              Divider(
                thickness: 2,
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Logout"),
                onTap: () {
                  Navigator.pop(context);
                  showLogoutConfirmationDialog(context);
                },
              ),
              Divider(
                thickness: 2,
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Image.asset(
                "assets/images/Logo_Final.png",
                height: 100,
                width: 180,
              ),
              SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Employees')
                        .where('department')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(); // Placeholder for when data is loading
                      }
                      if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Display error message if snapshot has error
                      }
                      final data = snapshot.data!;
                      List<DocumentSnapshot> documents = data.docs;

                      return _buildCard(
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/division.png",
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "All Employees Data",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 12,
                                child: Text(
                                  documents.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Allemployees()),
                          );
                        },
                      );
                    },
                  ),
                  _buildCard(
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/business.png",
                              height: 70,
                              width: 70,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Attendance",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Attendance()),
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Employees')
                        .where('department', isEqualTo: 'Admin')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(); // Placeholder for when data is loading
                      }
                      if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Display error message if snapshot has error
                      }
                      final data = snapshot.data!;
                      List<DocumentSnapshot> documents = data.docs;

                      return _buildCard(
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/Admin.png",
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Admin",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 12,
                                child: Text(
                                  documents.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Admin()),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Employees')
                        .where('department', isEqualTo: 'App Development')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(); // Placeholder for when data is loading
                      }
                      if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Display error message if snapshot has error
                      }
                      final data = snapshot.data!;
                      List<DocumentSnapshot> documents = data.docs;

                      return _buildCard(
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/appsfinal.png",
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "App Developer",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 13,
                                child: Text(
                                  documents.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Appdevelopment()),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Employees')
                        .where('department', isEqualTo: 'Web Development')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(); // Placeholder for when data is loading
                      }
                      if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Display error message if snapshot has error
                      }
                      final data = snapshot.data!;
                      List<DocumentSnapshot> documents = data.docs;

                      return _buildCard(
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/Appdeveloper.png",
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Web Developer",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 13,
                                child: Text(
                                  documents.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Webdeveolper()),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Employees')
                        .where('department', isEqualTo: 'App Development')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(); // Placeholder for when data is loading
                      }
                      if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Display error message if snapshot has error
                      }
                      final data = snapshot.data!;
                      List<DocumentSnapshot> documents = data.docs;

                      return _buildCard(
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/digitalmarketing.png",
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Digital Marketing",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 13,
                                child: Text(
                                  documents.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Digitalmarketing()),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Employees')
                        .where('department', isEqualTo: 'Video Editor')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(); // Placeholder for when data is loading
                      }
                      if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Display error message if snapshot has error
                      }
                      final data = snapshot.data!;
                      List<DocumentSnapshot> documents = data.docs;

                      return _buildCard(
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/Vidioeditor.png",
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Vidio Editor",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 13,
                                child: Text(
                                  documents.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VidioEditor()),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Employees')
                        .where('department', isEqualTo: 'Graphics')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(); // Placeholder for when data is loading
                      }
                      if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Display error message if snapshot has error
                      }
                      final data = snapshot.data!;
                      List<DocumentSnapshot> documents = data.docs;

                      return _buildCard(
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/graphics.png",
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Graphics",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 13,
                                child: Text(
                                  documents.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Graphics()),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
