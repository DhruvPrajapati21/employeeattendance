import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Adminscreen.dart';
import 'Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invest-IQ',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: Signup(),
    );
  }
}

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final Form_key = GlobalKey<FormState>();
  TextEditingController name1Controller = TextEditingController();
  TextEditingController name2Controller = TextEditingController();
  TextEditingController name3Controller = TextEditingController();
  TextEditingController name4Controller = TextEditingController();
  var password = true;
  var Confirmpassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
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
          key: Form_key,
          child: Column(
            children: [
              Image.asset(
                "assets/images/signup.png",
                width: 110,
                height: 110,
              ),
              SizedBox(height: 10,),
              Container(
                height: 50,
                width: 280,
                color: Colors.cyan,
                child:  Center(child: Text("Admin Signup",style:TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color: Colors.white, fontSize: 20,),)),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your Name";
                    }
                    return null;
                  },
                  controller: name1Controller,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      prefixIconColor: Colors.cyan,
                      labelText: 'Enter Your Name',
                      labelStyle: TextStyle(color: Colors.cyan),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
              ),
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
                  controller: name2Controller,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      prefixIconColor: Colors.cyan,
                      labelText: 'Enter Your Email',
                      labelStyle: TextStyle(color: Colors.cyan),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
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
                  controller: name3Controller,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Password',
                    labelStyle: TextStyle(color: Colors.cyan),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    prefixIconColor: Colors.cyan,
                    suffixIconColor: Colors.cyan,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          password = !password;
                        });
                      },
                      icon: password
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                    ),
                  ),
                  obscureText: password,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Confirm Password";
                    }
                    return null;
                  },
                  controller: name4Controller,
                  decoration: InputDecoration(
                    labelText: 'Enter Confirm Password',
                    labelStyle: TextStyle(color: Colors.cyan),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    prefixIconColor: Colors.cyan,
                    suffixIconColor: Colors.cyan,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          Confirmpassword = !Confirmpassword;
                        });
                      },
                      icon: Confirmpassword
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                    ),
                  ),
                  obscureText: Confirmpassword,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (Form_key.currentState!.validate()) {
                        final name = name1Controller.text;
                        final email = name2Controller.text;
                        final password = name3Controller.text;
                        final confirmpassword = name4Controller.text;

                        if (password == confirmpassword) {
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                            Fluttertoast.showToast(
                              msg: "Successfully Signed Up",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 11.0,
                            );

                            final user = {
                              'Name': name,
                              'Email': email,
                              'Password': password,
                            };

                            await FirebaseFirestore.instance
                                .collection('Admin')
                                .add(user);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Login()),
                            );
                          } on FirebaseAuthException catch (e) {
                            String message;
                            switch (e.code) {
                              case 'email-already-in-use':
                                message =
                                'The email address is already in use by another account.';
                                break;
                              case 'invalid-email':
                                message = 'The email address is not valid.';
                                break;
                              case 'operation-not-allowed':
                                message =
                                'Email/password accounts are not enabled.';
                                break;
                              case 'weak-password':
                                message = 'The password is too weak.';
                                break;
                              default:
                                message =
                                'An unknown error occurred: ${e.message}';
                            }
                            Fluttertoast.showToast(
                              msg: message,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 11.0,
                            );
                            print('FirebaseAuthException: $e');
                          } catch (e) {
                            print('Error: $e');
                            Fluttertoast.showToast(
                              msg: 'An error occurred: ${e.toString()}',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 11.0,
                            );
                          }
                        } else {
                          print('Passwords do not match');
                          Fluttertoast.showToast(
                            msg: 'Passwords do not match',
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
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Text("Already Have a Account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text(
                      "Login >>",
                      style: TextStyle(color: Colors.cyan),
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
