import 'package:fbserviceauthentication/Authentication/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Admin/Admin.dart';
import '../Adminscreen.dart';
import 'Forgetpassword.dart';

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
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  var _passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(hexColor('#5F9EA0')),
        title: Text(
          "Faydabazar",
          style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                "assets/images/Logo_Final.png",
                width: 210,
                height: 150,
              ),
              Card(
                color: Color(hexColor('#5F9EA0')),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/sample.png",
                        width: 110,
                        height: 110,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Admin Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            } else if (!value.contains("@") ||
                                !value.contains(".com") ||
                                !value.contains("gmail")) {
                              return "Please enter valid email";
                            }
                            return null;
                          },
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            prefixIconColor: Colors.white,
                            labelText: 'Enter Your Email',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Password";
                            }
                            return null;
                          },
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Enter Your Password',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            prefixIconColor: Colors.white,
                            suffixIconColor: Colors.white,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: _passwordVisible
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                          ),
                          obscureText: _passwordVisible,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                final userSnapshot = await FirebaseFirestore.instance
                                    .collection('Admin')
                                    .where('Email', isEqualTo: _emailController.text)
                                    .limit(1)
                                    .get();

                                if (userSnapshot.docs.isNotEmpty) {
                                  final userData = userSnapshot.docs.first.data();
                                  final savedPassword = userData['Password'];
                                  if (savedPassword == _passwordController.text) {
                                    // Password matches, proceed with login
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                    Fluttertoast.showToast(
                                      msg: "Successfully Logged In!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 11.0,
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Adminscreen()),
                                    );
                                  } else {
                                    // Password doesn't match
                                    print('Incorrect Password');
                                    Fluttertoast.showToast(
                                      msg: 'Incorrect password',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 11.0,
                                    );
                                  }
                                } else {
                                  // User not found
                                  print('User not found');
                                  Fluttertoast.showToast(
                                    msg: 'User not found',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 11.0,
                                  );
                                }
                              } catch (e) {
                                print('Error: $e');
                                // Handle any potential errors here
                                Fluttertoast.showToast(
                                  msg: 'An error occurred',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 11.0,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Forgetpassword()),
                              );
                            },
                            child: Text(
                              "Forget Password?",
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Text("Need an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Signup()));
                    },
                    child: Text(
                      "Join us >>",
                      style: TextStyle(color: Color(hexColor('#5F9EA0')),),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalcolor = int.parse(newColor);
  return finalcolor;
}
