import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:connectivity/connectivity.dart';
import 'package:rounds/colors.dart';

class ChangePhotoScreen extends StatefulWidget {
  @override
  _ChangePhotoScreenState createState() => _ChangePhotoScreenState();
}

class _ChangePhotoScreenState extends State<ChangePhotoScreen> {
  bool error = false;
  bool complete = false;
  File _image;

  final String KEY = 'os14042020ah';
  final String ACTION = 'add-doctor-avatar';
  ImageSource source;

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose option", style: TextStyle(color: Colors.blue)),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Divider(height: 1, color: Colors.blue),
                ListTile(
                  onTap: () {
                    setState(() {
                      source = ImageSource.gallery;
                    });
                    Navigator.pop(context);
                    getImage(source);
                  },
                  title: Text("Gallery"),
                  leading: Icon(Icons.account_box, color: Colors.blue),
                ),
                Divider(height: 1, color: Colors.blue),
                ListTile(
                  onTap: () {
                    setState(() {
                      source = ImageSource.camera;
                    });
                    Navigator.pop(context);
                    getImage(source);
                  },
                  title: Text("Camera"),
                  leading: Icon(Icons.camera, color: Colors.blue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    setState(() {
      _image = image;
      if (_image != null) complete = true;
    });
  }

  Future<void> uploadDoctorImage() async {
    String doctorId = await DoctorID().readID();

    try {
      if (_image != null) {
        String fileName = 'doctor_avatar_$doctorId.jpg';
        Reference storageReference =
            FirebaseStorage.instance.ref().child('doctor_avatars/$fileName');
        UploadTask uploadTask = storageReference.putFile(_image);
        await uploadTask.whenComplete(() async {
          String downloadUrl = await storageReference.getDownloadURL();

          // Now you can update Firestore with the downloadUrl
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(doctorId)
              .update({'avatar': downloadUrl});

          setState(() {
            error = false;
          });

          successMessage(context);
        });
      }
    } catch (e) {
      print("Exception Caught : $e");
      setState(() {
        error = false;
      });
      errorMessage(context);
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

  errorMessage(BuildContext context) {
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
      content: Text("something went wrong"),
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

  successMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
        setState(() {
          error = false;
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Success"),
      content: Text("Uploaded"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return alert;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Change Photo'),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? Container(
                      child: Text('No Image Selected.'),
                    )
                  : Image.file(_image,
                      width: width * 0.7, height: height * 0.5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: complete ? orange : teal,
                        ),
                        child: TextButton(
                          onPressed: () async {
                            check().then((intenet) {
                              if (intenet != null && intenet) {
                                // Internet Present Case
                                if (_image == null) {
                                  // Handle case when no image is selected
                                } else {
                                  setState(() {
                                    error = true;
                                  });

                                  uploadDoctorImage();
                                }
                              } else {
                                internetMessage(context);
                              }
                            });
                          },
                          child: Text(
                            error ? 'Uploading' : 'Upload',
                            style: TextStyle(
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: teal,
                        ),
                        child: TextButton(
                          onPressed: () async {
                            _showChoiceDialog(context);
                          },
                          child: Text(
                            'Select Image',
                            style: TextStyle(
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
