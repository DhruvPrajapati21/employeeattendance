import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class Todayscreen extends StatefulWidget {
  const Todayscreen({Key? key}) : super(key: key);

  @override
  State<Todayscreen> createState() => _TodayscreenState();
}

class _TodayscreenState extends State<Todayscreen> {
  late double screenHeight;
  late double screenWidth;
  String userName = '';
  String checkInTime = '--:--';
  String checkOutTime = '--:--';
  String attendanceStatus = '';
  final String userId = 'userId'; // Replace with actual user ID logic
  bool hasCheckedIn = false;
  bool hasCheckedOut = false;
  bool showEntryCompleteMessage = false;
  late Timer _timer;
  String location = '';
  bool isCheckIn = false;
  String _currentLocation = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchCheckInOutTimes();
    requestLocationPermission().then((_) {
      _getLocation();
    });
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _resetDailyData();
    });
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      return Future.value(true);
    } else {
      setState(() {
        location = "Location permission denied";
      });
      return Future.value(false);
    }
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          setState(() {
            _currentLocation = "Location permission denied";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          _currentLocation = "${placemarks[0].street}, ${placemarks[0].administrativeArea}, ${placemarks[0].postalCode}, ${placemarks[0].country}";
        });
      } else {
        setState(() {
          _currentLocation = "Location not available";
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = "Error: ${e.toString()}";
      });
    }
  }

  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _resetDailyData() {
    setState(() {
      checkInTime = '--:--';
      checkOutTime = '--:--';
      hasCheckedIn = false;
      hasCheckedOut = false;
      showEntryCompleteMessage = false;
      attendanceStatus = '';
    });
    fetchCheckInOutTimes();
  }

  Future<void> fetchUserName() async {
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (snapshot.exists) {
      setState(() {
        userName = snapshot['Name'];
      });
    }
  }

  Future<void> fetchCheckInOutTimes() async {
    String todayStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .doc('$userId-$todayStr')
        .get();

    if (snapshot.exists) {
      setState(() {
        checkInTime = snapshot['checkIn'] ?? '--:--';
        checkOutTime = snapshot['checkOut'] ?? '--:--';
        hasCheckedIn = snapshot['checkIn'] != null;
        hasCheckedOut = snapshot['checkOut'] != null;
        if (hasCheckedOut) {
          showEntryCompleteMessage = true;
          calculateAttendanceStatus();
        } else {
          showEntryCompleteMessage = false;
        }
      });
    } else {
      setState(() {
        checkInTime = '--:--';
        checkOutTime = '--:--';
        hasCheckedIn = false;
        hasCheckedOut = false;
        showEntryCompleteMessage = false;
      });
    }
  }

  Future<void> storeCheckInOutTime({required bool isCheckIn}) async {
    String currentTime = DateFormat('HH:mm').format(DateTime.now());
    String todayStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

    DocumentReference attendanceRef = FirebaseFirestore.instance
        .collection('Attendance')
        .doc('$userId-$todayStr');

    DocumentSnapshot snapshot = await attendanceRef.get();

    if (isCheckIn && !hasCheckedIn) {
      await attendanceRef.set({
        'date': todayStr,
        'checkIn': currentTime,
        'location': location,
      }, SetOptions(merge: true));

      setState(() {
        checkInTime = currentTime;
        hasCheckedIn = true;
        showEntryCompleteMessage = false;
      });
    } else if (!isCheckIn && hasCheckedIn && !hasCheckedOut) {
      await attendanceRef.update({
        'checkOut': currentTime,
        'location': location,
      });

      setState(() {
        checkOutTime = currentTime;
        hasCheckedOut = true;
        showEntryCompleteMessage = true;
        calculateAttendanceStatus();
      });
    }
  }

  void calculateAttendanceStatus() async {
    if (checkInTime != '--:--' && checkOutTime != '--:--') {
      DateTime checkIn = DateFormat('HH:mm').parse(checkInTime);
      DateTime checkOut = DateFormat('HH:mm').parse(checkOutTime);

      Duration duration = checkOut.difference(checkIn);
      int hours = duration.inHours;
      int minutes = duration.inMinutes.remainder(60);

      String status;
      if (hours >= 7) {
        status = 'Full Day';
      } else {
        status = 'Half Day';
      }

      setState(() {
        attendanceStatus = status;
      });

      String todayStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

      DocumentReference attendanceRef = FirebaseFirestore.instance
          .collection('Attendance')
          .doc('$userId-$todayStr');

      await attendanceRef.update({
        'status': status,
        'record': '$hours hours and $minutes minutes'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildWelcomeMessage(),
              _buildTodaysStatus(),
              _buildDateTime(),
              SizedBox(height: 10),
              if (!hasCheckedOut) _buildSlideAction(),
              if (showEntryCompleteMessage) _buildEntryCompleteMessage(),
              SizedBox(height: 10),
              _buildLocationInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 32),
          child: Text(
            "Welcome",
            style: TextStyle(
              color: Colors.black54,
              fontFamily: "NexaRegular",
              fontSize: screenWidth / 20,
            ),
          ),
        ),
        Container(
          child: Text(
            userName.isNotEmpty ? userName : "Employee",
            style: TextStyle(
              fontFamily: "NexaBold",
              fontSize: screenWidth / 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 12),
          child: Text(
            "Today's Status",
            style: TextStyle(
              fontFamily: "NexaBold",
              fontSize: screenWidth / 18,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 12, bottom: 32),
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatusColumn("Check In", checkInTime, hasCheckedIn),
              ),
              Expanded(
                child: _buildStatusColumn("Check Out", checkOutTime, hasCheckedOut),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusColumn(String title, String time, bool isChecked) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: "NexaRegular",
            fontSize: screenWidth / 20,
            color: Colors.black54,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontFamily: "NexaBold",
            fontSize: screenWidth / 18,
          ),
        ),
        if (isChecked) Icon(Icons.done, color: Colors.green, size: 24),
      ],
    );
  }

  Widget _buildDateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: RichText(
            text: TextSpan(
              text: DateTime.now().day.toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth / 18,
                fontFamily: "NexaBold",
              ),
              children: [
                TextSpan(
                  text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth / 20,
                    fontFamily: "NexaBold",
                  ),
                ),
              ],
            ),
          ),
        ),
        StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            return Container(
              child: Text(
                DateFormat('hh:mm:ss a').format(DateTime.now()),
                style: TextStyle(
                  fontFamily: "NexaRegular",
                  fontSize: screenWidth / 20,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSlideAction() {
    final GlobalKey<SlideActionState> key = GlobalKey();
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: SlideAction(
        text: hasCheckedIn && !hasCheckedOut
            ? "Slide to check Out"
            : "Slide to check In",
        textStyle: TextStyle(
          color: Colors.black54,
          fontSize: screenWidth / 20,
          fontFamily: "NexaRegular",
        ),
        outerColor: Colors.cyan,
        innerColor: Colors.white,
        key: key,
        onSubmit: () async {
          if ((isCheckIn && hasCheckedIn) || (!isCheckIn && hasCheckedOut)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  "Entry for today has already been completed.",
                  style: TextStyle(color: Colors.white),
                ),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            await storeCheckInOutTime(isCheckIn: !hasCheckedIn);
            key.currentState?.reset();
            fetchCheckInOutTimes();
          }
        },
      ),
    );
  }

  Widget _buildEntryCompleteMessage() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            "You have completed your entry for today. Attendance: $attendanceStatus",
            style: TextStyle(
              color: Colors.green,
              fontFamily: "NexaRegular",
              fontSize: screenWidth / 24,
            ),
          ),
          location.isNotEmpty ? Text("Location: $location") : const SizedBox(),
        ],
      ),
    );
  }
  Widget _buildLocationInfo() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Current Location",
            style: TextStyle(
              fontFamily: "NexaBold",
              fontSize: screenWidth / 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _currentLocation.isNotEmpty ? _currentLocation : "Location not available",
            style: TextStyle(
              fontSize: screenWidth / 22,
              color: Colors.black, // Adjust color as needed
            ),
          ),
        ],
      ),
    );
  }
}
