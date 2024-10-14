import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounds/Network/AddDoctorModel.dart';
import 'package:rounds/Network/DoctorDataModel.dart';
import 'package:rounds/Screens/HomeScreen.dart';
import 'package:rounds/Screens/MyTeamScreen.dart';
import 'package:flutter/services.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:rounds/colors.dart';
import 'package:rounds/Dialogs/LoginDialog.dart';
import 'package:rounds/component.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Header.dart';

class AddDoctorToTeamScreen extends StatefulWidget {
  @override
  _AddDoctorToTeamScreenState createState() => _AddDoctorToTeamScreenState();
}

class _AddDoctorToTeamScreenState extends State<AddDoctorToTeamScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  bool _obscureText = true;
  String _emailError, _passwordError, _nameError;

  DoctorData doctor;

  Future<Map<String, String>> _showLoginDialog(BuildContext context) async {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog(
          onSubmit: (credentials) {
            Navigator.of(context).pop(credentials);
          },
        );
      },
    );
  }

  Future<void> uploadDoctorToFirestore() async {
    try {
      User currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Get current user data
        DocumentSnapshot currentUserData = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(currentUser.uid)
            .get();

        // Check if current user data exists
        if (currentUserData.exists) {
          // Get current user share_id
          String shareId = currentUserData.data()['share_id'];

          // Create new user with the same share_id
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

          String doctorId = userCredential.user.uid;
          DateTime registerDate = DateTime.now();

          FirebaseFirestore firestore = FirebaseFirestore.instance;

          // Add new doctor document with the required data
          await firestore.collection('doctors').doc(doctorId).set({
            'username': nameController.text,
            'email': emailController.text,
            'added_by': currentUser.uid,
            'doctorId': doctorId,
            'registerDate': registerDate,
            'share_id': shareId, // Use the same share_id for the new user
          });

          // Clear input fields after successful addition
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          phoneController.clear();

          // Show success dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                title: Text(
                  'Success',
                  style: TextStyle(color: teal, fontWeight: FontWeight.bold),
                ),
                content: Text('Doctor Added Successfully'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(color: teal),
                    ),
                  ),
                ],
              );
            },
          );

          // Send welcome message via WhatsApp
          String phoneNumber = phoneController.text;
          String message = 'Welcome to our team!\n'
              'Your login credentials:\n'
              'Email: ${emailController.text}\n'
              'Password: ${passwordController.text}';

          String whatsappUrl = 'https://wa.me/$phoneNumber/?text=${Uri.encodeComponent(message)}';
          if (await canLaunch(whatsappUrl)) {
            await launch(whatsappUrl);
          } else {
            throw 'Could not launch $whatsappUrl';
          }
        }
      }
    } catch (error) {
      print("Exception Caught: $error");
    }
  }


  @override
  void initState() {
    super.initState();
    getDoctorData();
  }

  getDoctorData() async {
    User user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          doctor = DoctorData.fromJson(userData.data());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Doctor"),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                  color: teal),
              child: Header(userData: doctor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                suffixIcon: Icon(Icons.email, color: teal),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: teal, width: 2.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: teal, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                errorText: _emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              maxLines: 1,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')), // Deny spaces
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Username',
                suffixIcon: Icon(Icons.person, color: teal),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: teal, width: 2.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: teal, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 5.0, horizontal: 20.0),
                errorText: _nameError,
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              maxLines: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                hintText: 'Phone (Whatsapp), Ex. +966 ..123',
                suffixIcon: Icon(Icons.phone, color: teal),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: teal, width: 2.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: teal, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 5.0, horizontal: 20.0),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              maxLines: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: teal,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: teal, width: 2.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: teal, width: 2.0),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 5.0, horizontal: 20.0),
                errorText: _passwordError,
              ),
              obscureText: _obscureText,
            ),
          ),
          myButton(
            width: width,
            onPressed: () async {
              setState(() {
                if (emailController.text.isEmpty) {
                  _emailError = 'Please enter email';
                } else if (!_isValidEmail(emailController.text)) { // Check for valid email format
                  _emailError = 'Please enter a valid email';
                } else {
                  _emailError = null;
                }
                if (nameController.text.isEmpty) {
                  _nameError = 'Please enter username';
                } else {
                  _nameError = null;
                }
                if (passwordController.text.length < 8) {
                  _passwordError = 'Password must be at least 8 characters';
                } else {
                  _passwordError = null;
                }
              });
              if (_emailError == null && _nameError == null && _passwordError == null) {
                await uploadDoctorToFirestore();
              }
            },
            text: 'Add Doctor',
          )

        ],
      ),
    );
  }
  bool _isValidEmail(String email) {
    // You can use a regular expression to check for a valid email format
    // This is a basic example, you may need to adjust it based on your requirements
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }
}
