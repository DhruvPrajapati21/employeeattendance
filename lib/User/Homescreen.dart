import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbserviceauthentication/User/sampe.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Profilescreen.dart';
import 'Todayscreen.dart';
import 'UserModel.dart';
import 'locationservice.dart';
import 'calendarscreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  int currentIndex = 0;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user,
  ];

  @override
  void initState() {
    super.initState();
    _startLocationService();
    getId();
  }

  void _startLocationService() async {
    LocationService locationService = LocationService();
    await locationService.initialize();

    locationService.getLongitude().then((value) {
      setState(() {
        User.long = value!;
      });
    });

    locationService.getLatitude().then((value) {
      setState(() {
        User.lat = value!;
      });
    });
  }

  void getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Attendance")
        .where('id', isEqualTo: User.empoyeeId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Home",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: IndexedStack(
        index: currentIndex,
        children:[
          Calendarscreen(),
          Todayscreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(
          left: 12,
          right: 13,
          bottom: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < navigationIcons.length; i++) ...<Expanded>{
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                    child: Container(
                      height: screenHeight,
                      width: screenWidth,
                      color: Colors.cyan,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              navigationIcons[i],
                              color: i == currentIndex
                                  ? Colors.white
                                  : Colors.black54,
                              size: i == currentIndex ? 30 : 26,
                            ),
                            if (i == currentIndex)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                height: 3,
                                width: 22,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
