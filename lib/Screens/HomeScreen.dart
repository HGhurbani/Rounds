import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import '../Header.dart';
import 'MenuScreen.dart';
import 'package:rounds/colors.dart';
import '../Network/DoctorDataModel.dart';
import '../Network/DoctorSicksModel.dart';
import '../BottomNavigationBarItems/DailyRound.dart';
import 'chatScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DoctorData doctor;
  List<DoctorSicks> filteredSick = [];
  File _image;
  Icon _searchIcon = Icon(Icons.search);
  Widget _appBarTitle;

  final TextEditingController _filter = TextEditingController();

  String _searchText = "";

  Future<void> _checkPermission() async {
    final storage = await Permission.storage.request();
    if (storage == PermissionStatus.granted) {
    } else if (storage == PermissionStatus.denied) {
      Fluttertoast.showToast(
        msg: "Storage Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (storage == PermissionStatus.permanentlyDenied) {
      Fluttertoast.showToast(
        msg: "Storage Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      await openAppSettings();
    }

    final camera = await Permission.camera.request();
    if (camera == PermissionStatus.granted) {
    } else if (camera == PermissionStatus.denied) {
      Fluttertoast.showToast(
        msg: "Camera Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (camera == PermissionStatus.permanentlyDenied) {
      Fluttertoast.showToast(
        msg: "Camera Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      await openAppSettings();
    }

    final audio = await Permission.microphone.request();
    if (audio == PermissionStatus.granted) {
      print('Permission granted');
    } else if (audio == PermissionStatus.denied) {
      Fluttertoast.showToast(
        msg: "Mic Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print(
        'Permission denied. Show a dialog and again ask for the permission',
      );
    } else if (audio == PermissionStatus.permanentlyDenied) {
      Fluttertoast.showToast(
        msg: "Mic Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      await openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
    getDoctorData();
    getDoctorSicks();
  }

  Future<void> getDoctorData() async {
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

  uploadDoctorImage() async {
    User user = FirebaseAuth.instance.currentUser;
    if (user != null && _image != null) {
      try {
        Reference storageRef =
        FirebaseStorage.instance.ref().child('doctor_avatars/$user.uid');
        UploadTask uploadTask = storageRef.putFile(_image);
        await uploadTask.whenComplete(() async {
          String downloadURL = await storageRef.getDownloadURL();
          if (downloadURL.isNotEmpty) {
            FirebaseFirestore.instance
                .collection('doctors')
                .doc(user.uid)
                .update({'avatar': downloadURL});
          }
        });
      } catch (e) {
        print("Exception Caught : $e");
      }
    }
  }

  getDoctorSicks() async {
    User user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot sicksSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .collection('doctorId')
          .get();

      setState(() {
        filteredSick = sicksSnapshot.docs
            .map((doc) => DoctorSicks.fromJson(doc.data()))
            .toList();
      });
    }
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search),
            hintText: 'Enter name or file number...',
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('');
        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Future<void> _appUsage(BuildContext context) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ), // حواف مربعة ناعمة
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
                              backgroundColor:
                              MaterialStateProperty.all(orange)),
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
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    // Assuming doctorId is the user ID
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.info_rounded),
            onPressed: () {
              _appUsage(context);
              // Show app usage info
            },
          ),

        ],
        elevation: 0,
      ),
      drawer: MenuScreen(),
      body: Column(
        children: <Widget>[
          Container(
            height: height * 0.12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              color: teal
            ),
            child: GestureDetector(
              onTap: () {
                getDoctorData();
              },
              child: Header(userData: doctor), // Assuming userData contains the doctor data from Firestore
            ),
          ),
          DailyRound(doctor, filteredSick),
        ],
      ),
    );
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
