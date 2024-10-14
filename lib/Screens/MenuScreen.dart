import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:rounds/AddScreens/AddDoctorToTeamScreen.dart';
import 'package:rounds/AddScreens/AddSickScreen.dart';
import 'package:rounds/Network/RestPasswordModel.dart';
import 'package:rounds/Status/DoctorLogin.dart';
import 'package:rounds/UserLogin/Login.dart';
import 'package:rounds/colors.dart';
import 'package:rounds/component.dart';
import '../Policy/PrivacyPolicyScreen.dart';
import '../Policy/TermsOfUseScreen.dart';
import 'ChangePhotoScreen.dart';
import 'DailyRoundScreen.dart';
import 'MyPatientsScreen.dart';
import 'MyTeamScreen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final mailController = TextEditingController();
  String _mail = '';
  bool error = false;
  bool complete = false;
  final String KEY = 'os14042020ah';
  final String ACTION = 'reset-password';

  Password(context, mail) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
      restMessage(context, 'Password reset email sent');
      setState(() {
        error = false;
      });
    } catch (e) {
      print("Exception Caught : $e");
      errorMessage(context);
    }
  }

  internetMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Connection Error"),
          content: Text("Please check your internet connection"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  errorMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Something went wrong"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  restMessage(BuildContext context, msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reset Password"),
          content: Text(msg),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  _displayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
      String _mail = ''; // إضافة متغير لتخزين قيمة البريد الإلكتروني
      bool complete = false; // إضافة متغير للتحقق من إكمال الإدخال
      bool error = false; // إضافة متغير للتحقق من وجود خطأ

      return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
          padding: EdgeInsets.all(20.0),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    Text(
    'Enter the email address used to create your account. We will email you a link to reset your password.',
    style: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 15,
    color: teal,
    ),
    textAlign: TextAlign.center,
    ),
    SizedBox(height: 20.0),
    TextField(
    controller: mailController,
    onChanged: (val) {
    _mail = val;
    complete = val.isNotEmpty;
    },
    decoration: InputDecoration(
    hintText: "Enter your email",
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: teal, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: teal, width: 2.0),
    ),
    ),
    ),
    SizedBox(height: 20.0),
    Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
    TextButton(
    child: Text(error ? 'Sending' : 'Send', style: TextStyle(color: teal),),
    onPressed: () async {
    bool isConnected = await checkInternet();
    if (!isConnected) {
    internetMessage(context);
    return;
    }
    if (mailController.text.isEmpty) return;

    // Check if the entered email is the same as logged-in user's email
    if (FirebaseAuth.instance.currentUser?.email == _mail) {
    error = true;

    // Close the original dialog after pressing the send button
    Navigator.pop(context);
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _mail);

    // Display a new dialog for successful sending
    showDialog(
    context: context,
    builder: (context) {
    return Dialog(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
    ),
    child: Container(
    padding: EdgeInsets.all(20.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Email Sent Successfully',
          style: TextStyle(
            fontSize: 20.0,
            color: teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'We have sent a password reset link to $_mail.',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the success dialog
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: teal,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    ),
    );
    },
    );
    } else {
      // Show error message if emails don't match
      error = false;
      showErrorDialog(
        context,
        "Entered email does not match logged-in user's email.",
      );
    }
    },
    ),
    ],
    ),
    ],
    ),
          ),
      );
        },
    );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height * 0.1,
          ),
          myTextButton(
            width: width,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDoctorToTeamScreen(),
                ),
              );
            },
            icon: Icons.add_circle_outline,
            text: "Add doctor",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              thickness: 0.3,
              color: teal,
            ),
          ),
          myTextButton(
              width: width,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddSickScreen(
                          sickModel: null,
                        )));
              },
              icon: Icons.person_add_outlined,
              text: "Add Patients"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              thickness: 0.3,
              color: teal,
            ),
          ),
          myTextButton(
            width: width,
            onPressed: () {
              _displayDialog(context);
            },
            icon: Icons.lock_outline,
            text: "Change Password",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              thickness: 0.3,
              color: teal,
            ),
          ),
          myTextButton(
              width: width,
              onPressed: () async {
                await DoctorLogIn().writeLogIn(false);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePhotoScreen()));
              },
              icon: Icons.camera_enhance_outlined,
              text: "Change Picture"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              thickness: 0.3,
              color: teal,
            ),
          ),
          myTextButton(
              width: width,
              onPressed: () async {
                await DoctorLogIn().writeLogIn(false);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyTeamScreen()));
              },
              icon: Icons.supervisor_account_outlined,
              text: "My team"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              thickness: 0.3,
              color: teal,
            ),
          ),
          myTextButton(
            width: width,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicyScreen(),
                ),
              );
            },
            icon: Icons.privacy_tip_outlined,
            text: "Privacy Policy",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              thickness: 0.3,
              color: teal,
            ),
          ),
          myTextButton(
            width: width,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermsOfUseScreen(),
                ),
              );
            },
            icon: Icons.description_outlined,
            text: "Terms of Use",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              thickness: 0.3,
              color: teal,
            ),
          ),
          myTextButton(
              width: width,
              onPressed: () async {
                await DoctorLogIn().writeLogIn(false);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                        (route) => false);
              },
              icon: Icons.exit_to_app,
              text: "SignOut"),
        ],
      ),
    );
  }

  Widget myTextButton({
    double width,
    Function onPressed,
    IconData icon,
    String text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: width * 0.06,
          color: Colors.deepOrangeAccent, // Deep orange color for icons
        ),
        label: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: teal, // Teal color for text
            ),
          ),
        ),
      ),
    );
  }
}
