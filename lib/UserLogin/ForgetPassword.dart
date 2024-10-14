import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Network/RestPasswordModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../colors.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final mailConroler = TextEditingController();

  String _mail = '';
  bool error = false;
  bool complete = false;

  final String KEY = 'os14042020ah';
  final String ACTION = 'reset-password';

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      restMessage(context, "Password reset email sent successfully.");
    } catch (e) {
      errorMessage(context, "Failed to send reset email: $e");
    }
  }

  Future<void> addDoctorToFirestore(String email) async {
    try {
      await FirebaseFirestore.instance.collection('doctors').doc().set({
        'email': email,
      });
    } catch (e) {
      print('Failed to add doctor to Firestore: $e');
    }
  }

  internetMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Connection Error"),
      content: Text("please check your internet connection"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void errorMessage(BuildContext context, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("ERROR"),
      content: Text(message), // تم استخدام الرسالة الممررة كوسيط هنا
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  restMessage(BuildContext context, msg) {
    // set up the button
    Widget okButton = TextButton(
      style: TextButton.styleFrom(
        primary: teal, // تحديد لون الزر
      ),
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        // جعل الحواف أنعم
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text("Reset Password",
          style: TextStyle(
              color: teal,
              fontWeight: FontWeight.bold)), // تحديد لون العنوان
      content: Text("$msg"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsetsDirectional.only(top: 120.0, end: 20, start: 20),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    'Welcome Doctor',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: teal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Forget Password Helper',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white),
                  child: TextField(
                    controller: mailConroler,
                    onChanged: (val) {
                      _mail = val;
                      if (_mail.length != 0) {
                        setState(() {
                          complete = true;
                        });
                      } else {
                        setState(() {
                          complete = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle:
                          TextStyle(color: teal, fontWeight: FontWeight.bold),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: teal, width: 2.0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(
                        Icons.mail_outline_outlined,
                        color: teal,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: teal, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 20),
                  child: Text(
                    'Enter the email address you used to create your account and we will email you a link to rest your password',
                    style: TextStyle(
                      fontSize: 20,
                      color: teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 20),
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: complete ? Colors.blueGrey : orange),
                    child: TextButton(
                        onPressed: () async {
                          if (mailConroler.text.isEmpty) {
                            // Handle empty email
                          } else {
                            setState(() {
                              error = true;
                            });

                            resetPassword(context, _mail);
                            addDoctorToFirestore(_mail);
                          }
                        },
                        child: Text(
                          error ? 'Loading' : 'Send',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
