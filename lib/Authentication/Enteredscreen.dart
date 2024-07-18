import 'package:fbserviceauthentication/Authentication/Login.dart';
import 'package:fbserviceauthentication/User/Userlogin.dart';
import 'package:flutter/material.dart';

class Enteredscreen extends StatefulWidget {
  const Enteredscreen({super.key});

  @override
  State<Enteredscreen> createState() => _EnteredscreenState();
}

class _EnteredscreenState extends State<Enteredscreen> {
  Widget _buildCard(Widget content, VoidCallback onTap) {
    return Container(
      height: 180,
      width: 180,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: Colors.white70,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 10.0,
          margin: EdgeInsets.all(10.0),
          shadowColor: Colors.black87,
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Center(
              child: Image.asset(
                "assets/images/Logo_Final.png",
                height: 170,
                width: 200,
              ),
            ),
            SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Employee",style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.italic,color: Colors.orange,fontSize: 23),),
                SizedBox(width: 5,),
                Text("Management",style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.italic,color: Colors.blueAccent,fontSize: 23),),
                SizedBox(width: 5,),
                Text("System",style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.italic,color: Colors.orange,fontSize: 23),),
              ],
            ),
            SizedBox(height: 20,),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildCard(
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/Admin.png",
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Admin Login",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                      () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
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
                            "assets/images/user.png",
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Employee Login",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14, // Adjust the font size to make the text smaller
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                      () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => UserLogin()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
