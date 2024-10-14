import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/AccountCreatedSuccessPage.dart';
import '../Screens/HomeScreen.dart';
import '../colors.dart';
import 'dart:math';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final shareIdController = TextEditingController();

  String _username = '';
  String _email = '';
  String _password = '';
  bool error = false;
  bool complete = false;
  String shareId = '';

  final String KEY = 'os14042020ah';
  final String ACTION = 'add-doctor';

  Future<void> signupDoctor(BuildContext context, String username, String email, String password, String shareId) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String doctorId = userCredential.user.uid;
        String shareDataId = generateRandomId();

        if (shareIdController.text.isNotEmpty) {
          shareId = shareIdController.text;
        } else {
          shareId = generateRandomId();
        }

        // Send verification email
        await userCredential.user.sendEmailVerification();

        await FirebaseFirestore.instance.collection('doctors').doc(doctorId).set({
          'doctorId': doctorId,
          'username': username,
          'email': email,
          'registerDate': DateTime.now().toString(),
          'share_data_id': shareDataId,
          'share_id': shareId,
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AccountCreatedSuccessPage()),
              (route) => false,
        );
        // _appUsage(context);

      } else {
        errorMessage(context, 'Failed to sign up');
      }
    } on FirebaseAuthException catch (e) {
      errorMessage(context, e.message ?? 'An error occurred');
    } catch (e) {
      errorMessage(context, 'An unexpected error occurred');
    }
  }


  String generateRandomId() {
    var random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
  }

  internetMessage(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Connection Error"),
      content: Text("Please check your internet connection"),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  errorMessage(BuildContext context, String msg) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
            child: TextField(
              controller: emailController,
              style: TextStyle(color: Colors.black),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (val) {
                setState(() {
                  _email = val.trim();
                  complete = _email.isNotEmpty && _username.isNotEmpty && _password.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: teal, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
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
                contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              ),
              maxLines: 1,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
              ],
            ),
          ),
          SizedBox(height: height * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
            child: TextField(
              controller: nameController,
              style: TextStyle(color: Colors.black),
              textInputAction: TextInputAction.next,
              onChanged: (val) {
                setState(() {
                  _username = val.trim();
                  complete = _email.isNotEmpty && _username.isNotEmpty && _password.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: 'Username',
                hintStyle: TextStyle(color: teal, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: teal,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              ),
              maxLines: 1,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
            ),
          ),
          SizedBox(height: height * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
            child: TextField(
              controller: passwordController,
              style: TextStyle(color: Colors.black),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onChanged: (val) {
                setState(() {
                  _password = val.trim();
                  complete = _email.isNotEmpty && _username.isNotEmpty && _password.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: teal, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: teal,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              ),
              maxLines: 1,
            ),
          ),
          SizedBox(height: height * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
            child: TextField(
              controller: shareIdController,
              style: TextStyle(color: Colors.black),
              textInputAction: TextInputAction.done,
              onChanged: (val) {
                setState(() {
                  complete = _email.isNotEmpty && _username.isNotEmpty && _password.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: 'Share ID (optional)',
                hintStyle: TextStyle(color: teal, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(
                  Icons.share,
                  color: teal,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              ),
              maxLines: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 25.0, start: 20, end: 20),
            child: Container(
              width: width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: complete ? Colors.blueGrey : orange),
              child: TextButton(
                onPressed: () async {
                  check().then((internet) {
                    if (internet != null && internet) {
                      if (emailController.text.isEmpty ||
                          nameController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        // Handle empty fields if needed
                        errorMessage(context, 'Please fill all fields');
                      } else {
                        setState(() {
                          error = true;
                        });
                        signupDoctor(context, _username, _email, _password, shareId);
                      }
                    } else {
                      internetMessage(context);
                    }
                  });
                },
                child: Text(
                  error ? 'Loading' : 'Sign up',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  Future<void> _appUsage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Text(
              "How To Use Rounds:",
              style: TextStyle(
                color: teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListBody(
                  children: [
                    buildTip(
                        "Pull the page down after modifying the data for refreshing it's data."),
                    buildSpace(),
                    buildTip("Click on the cards data to view it's details."),
                    buildSpace(),
                    buildTip(
                        "Swipe the card to the left side for edit or delete."),
                    buildSpace(),
                    buildTip("Don\'t forget mic permission."),
                    buildSpace(),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(orange)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Close")),
                  ],
                ),
              ),
            ),
          );
        });
  }
  Row buildTip(String text) {
    return Row(
      children: [
        Icon(
          Icons.tips_and_updates_outlined,
          color: orange,
        ),
        SizedBox(
          width: 4,
        ),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget buildSpace() {
    return Column(
      children: [
        SizedBox(
          height: 14,
        ),
        Divider(
          endIndent: 18,
          indent: 18,
        )
      ],
    );
  }
}
