import 'dart:async';
import 'package:fbserviceauthentication/Admin/Admin.dart';
import 'package:fbserviceauthentication/Authentication/Enteredscreen.dart';
import 'package:fbserviceauthentication/User/Homescreen.dart';
import 'package:fbserviceauthentication/User/Userlogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Adminscreen.dart';
import 'Login.dart';

User? user = FirebaseAuth.instance.currentUser;

class Splashscreen extends StatefulWidget {
  const Splashscreen({Key? key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), checkingTheSavedData);
  }

  void checkingTheSavedData() async {
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Enteredscreen()),
      );
    } else {
      print("User found");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Adminscreen()),
      );
    }
  }

  void checkingTheSavedData2() async {
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Enteredscreen()),
      );
    } else {
      print("User found");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homescreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:SingleChildScrollView(
        child:Container(
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     colors: [Colors.blueAccent, Colors.orange],
          //     begin: Alignment.topRight,
          //     end: Alignment.bottomLeft,
          //   ),
          // ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/Logo_Final.png"),
                  SizedBox(width: 20, height: 20,),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Welcome To Faydabazar",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                          color: Colors.cyan  // Changed text color to white
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Let's Navigate Promote your business!!",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.cyan
                      ),
                    ),
                  ),
                  // CircularProgressIndicator(color: Colors.white,),
                  SizedBox(height: 300,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


