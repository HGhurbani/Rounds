import 'package:connectivity/connectivity.dart';
import 'package:rounds/Status/DoctorLogin.dart';
import 'package:rounds/UserLogin/ForgetPassword.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Screens/HomeScreen.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  String _user = '';
  String _password = '';
  bool error = false;
  bool complete = false;
  final String KEY = 'os14042020ah';
  final String ACTION = 'login';

  Future<void> loginDoctor(BuildContext context, String user, String password) async {
    try {
      if (user.isEmpty || password.isEmpty) {
        showEmptyFieldDialog(context);
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user,
        password: password,
      );

      if (userCredential.user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(userCredential.user.uid)
            .get();

        if (userData.exists) {
          DoctorID().writeID(userCredential.user.uid);
          DoctorLogIn().writeLogIn(true);
          setState(() {
            error = false;
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
          );
          _appUsage(context);
        } else {
          showValidationErrorDialog(context, 'User does not exist');
        }
      } else {
        showWrongPasswordDialog(context);
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            showInvalidEmailDialog(context);
            break;
          case 'wrong-password':
            showWrongPasswordDialog(context);
            break;
          default:
            showValidationErrorDialog(context, 'An unexpected error occurred');
            break;
        }
      } else {
        showValidationErrorDialog(context, 'An unexpected error occurred');
      }
    }
  }

  void showEmptyFieldDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Error",
            style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "All fields are required",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(color: teal),
              ),
            ),
          ],
        );
      },
    );
  }

  void showInternetErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Connection Error",
            style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Please check your internet connection",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(color: teal),
              ),
            ),
          ],
        );
      },
    );
  }

  void showValidationErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Error",
            style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            errorMessage,
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(color: teal),
              ),
            ),
          ],
        );
      },
    );
  }

  void showInvalidEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Error",
            style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Invalid email address",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(color: teal),
              ),
            ),
          ],
        );
      },
    );
  }

  void showWrongPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            "Error",
            style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Incorrect password",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(color: teal),
              ),
            ),
          ],
        );
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
              style: TextStyle(color: Colors.black),
              controller: userController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (val) {
                _user = val.trim();
                setState(() {
                  complete = _user.isNotEmpty && _password.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: teal, fontWeight: FontWeight.bold),
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
                contentPadding: EdgeInsets.symmetric(
                    vertical: 5.0, horizontal: 20.0),
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
                borderRadius: BorderRadius.circular(24), color: Colors.white),
            child: TextField(
              style: TextStyle(color: Colors.black),
              controller: passwordController,
              obscureText: true,
              onChanged: (val) {
                _password = val;
                setState(() {
                  complete = _user.isNotEmpty && _password.isNotEmpty;
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
                  Icons.lock_open_outlined,
                  color: teal,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 5.0, horizontal: 20.0),
              ),
              maxLines: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 25.0, start: 20, end: 20),
            child: Container(
              width: width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: complete ? Colors.blueGrey : orange),
              child: TextButton(
                onPressed: () async {
                  if (userController.text.isEmpty || passwordController.text.isEmpty) {
                    showEmptyFieldDialog(context);
                  } else {
                    check().then((internet) {
                      if (internet != null && internet) {
                        setState(() {
                          error = true;
                        });
                        loginDoctor(context, _user, _password);
                      } else {
                        showInternetErrorDialog(context);
                      }
                    });
                  }
                },
                child: Text(
                  error ? 'Loading' : 'Login',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(top: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ForgetPassword()));
              },
              child: Text(
                'Forget Password ?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: teal,
                ),
              ),
            ),
          ),
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
