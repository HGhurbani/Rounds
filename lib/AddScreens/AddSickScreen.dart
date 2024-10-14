import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Screens/HomeScreen.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rounds/colors.dart';
import 'package:rounds/component.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Network/SickModel.dart';
import 'package:rounds/Network/DoctorDataModel.dart';

class AddSickScreen extends StatefulWidget {
  SickModel sickModel;
  final DoctorSicks sickData;
  final List<DoctorSicks> list;
  final DoctorData doctor;
  final List<DoctorSicks> filteredSick;

  AddSickScreen(
      {Key key,
      this.sickModel,
      this.doctor,
      this.filteredSick,
      this.list,
      this.sickData})
      : super(key: key);

  @override
  _AddSickScreenState createState() => _AddSickScreenState();
}

class _AddSickScreenState extends State<AddSickScreen> {
  @override
  void initState() {
    if (widget.sickData != null) {
      nameConroler.text = widget.sickData.name;
      medicalHistoryConroler.text = widget.sickData.medicalHistory;
      diagnosisConroler.text = widget.sickData.diagnosis;
      surgeryConroler.text = widget.sickData.surgery;
      heightConroler.text = widget.sickData.height;
      ageConroler.text = widget.sickData.age;
      surgicalHistoryConroler.text = widget.sickData.surgicalHistory;
      weightConroler.text = widget.sickData.weight;
      sugarLevelConroler.text = widget.sickData.sugarLevel;
      bloodPressureConroler.text = widget.sickData.bloodPressure;
      temperatureConroler.text = widget.sickData.temperature;
      dateOfAdmissionConroler.text = widget.sickData.dateOfAdmission;
      dateOfDischargeConroler.text = widget.sickData.dateOfDischarge;
      occupationConroler.text = widget.sickData.occupation;
      bloodGroupConroler.text = widget.sickData.bloodGroup;
      fileNumberConroler.text = widget.sickData.fileNumber;
      allergiesController.text = widget.sickData.allergies;
      dropdownValueGender = widget.sickData.gender ?? 'Male';
      dropdownValueSmoking = widget.sickData.smoking ?? 'No';
      dropdownValueAlcohol = widget.sickData.alcohol ?? 'No';
      _dateOfAdmission = widget.sickData.dateOfAdmission;
      _dateOfDischarge = widget.sickData.dateOfDischarge;
    } else {
      nameConroler.text = "";
      medicalHistoryConroler.text = "";
      diagnosisConroler.text = "";
      surgeryConroler.text = "";
      heightConroler.text = "";
      ageConroler.text = "";
      surgicalHistoryConroler.text = "";
      weightConroler.text = "";
      sugarLevelConroler.text = "";
      bloodPressureConroler.text = "";
      temperatureConroler.text = "";
      dateOfAdmissionConroler.text = "";
      dateOfDischargeConroler.text = "";
      occupationConroler.text = "";
      bloodGroupConroler.text = "";
      fileNumberConroler.text = "";
      allergiesController.text = "";
    }
    super.initState();
  }

  String generateRandomId() {
    var rng = Random();
    return '${rng.nextInt(10000)}'; // Random ID generation
  }

  bool loaded = false;
  TextEditingController nameConroler = TextEditingController();
  TextEditingController medicalHistoryConroler = TextEditingController();
  TextEditingController diagnosisConroler = TextEditingController();
  TextEditingController surgeryConroler = TextEditingController();
  TextEditingController heightConroler = TextEditingController();
  TextEditingController ageConroler = TextEditingController();
  TextEditingController surgicalHistoryConroler = TextEditingController();
  TextEditingController weightConroler = TextEditingController();
  TextEditingController sugarLevelConroler = TextEditingController();
  TextEditingController bloodPressureConroler = TextEditingController();
  TextEditingController temperatureConroler = TextEditingController();
  TextEditingController dateOfAdmissionConroler = TextEditingController();
  TextEditingController dateOfDischargeConroler = TextEditingController();
  TextEditingController occupationConroler = TextEditingController();
  TextEditingController bloodGroupConroler = TextEditingController();
  TextEditingController fileNumberConroler = TextEditingController();
  TextEditingController allergiesController = TextEditingController();

  final nameFocusNode = FocusNode();
  final ageFocusNode = FocusNode();
  final heightFocusNode = FocusNode();
  final weightFocusNode = FocusNode();
  final surgeryFocusNode = FocusNode();
  final surgicalHistoryFocusNode = FocusNode();
  final medicalHistoryFocusNode = FocusNode();
  final temperatureFocusNode = FocusNode();
  final bloodPressureFocusNode = FocusNode();
  final sugarLevelFocusNode = FocusNode();
  final diagnosisFocusNode = FocusNode();
  final occupationFocusNode = FocusNode();
  final bloodGroupFocusNode = FocusNode();
  final allergiesFocusNode = FocusNode();
  final fileNumberFocusNode = FocusNode();

  File _image;
  bool error = false;
  bool complete = false;
  String KEY = 'os14042020ah';
  String ACTION = 'add-sick';
  String editAction = 'edit-sick';
  String dropdownValueGender = 'Male';
  String dropdownValueSmoking = "No";
  String _dateOfAdmission = "";
  String _dateOfDischarge = "";
  // String dropdownValueSmoke = 'No';
  String dropdownValueAlcohol = 'No';
  ImageSource source;

  @override
  void dispose() {
    nameConroler.dispose();
    ageConroler.dispose();
    heightConroler.dispose();
    weightConroler.dispose();
    surgeryConroler.dispose();
    surgicalHistoryConroler.dispose();
    medicalHistoryConroler.dispose();
    temperatureConroler.dispose();
    bloodPressureConroler.dispose();
    sugarLevelConroler.dispose();
    diagnosisConroler.dispose();
    occupationConroler.dispose();
    bloodGroupConroler.dispose();
    allergiesController.dispose();
    fileNumberConroler.dispose();

    nameFocusNode.dispose();
    ageFocusNode.dispose();
    heightFocusNode.dispose();
    weightFocusNode.dispose();
    surgeryFocusNode.dispose();
    surgicalHistoryFocusNode.dispose();
    medicalHistoryFocusNode.dispose();
    temperatureFocusNode.dispose();
    bloodPressureFocusNode.dispose();
    sugarLevelFocusNode.dispose();
    diagnosisFocusNode.dispose();
    occupationFocusNode.dispose();
    bloodGroupFocusNode.dispose();
    allergiesFocusNode.dispose();
    fileNumberFocusNode.dispose();

    super.dispose();
  }

  CollectionReference sickCollection =
      FirebaseFirestore.instance.collection('patients');
  Future<void> uploadSick({
    String name,
    String medicalHistory,
    String diagnosis,
    String surgery,
    String height,
    String gender,
    String age,
    String surgicalHistory,
    String weight,
    String sugarLevel,
    String bloodPressure,
    String temperature,
    String dateOfAdmission,
    String dateOfDischarge,
    String smoking,
    String alcohol,
    String occupation,
    String bloodGroup,
    String fileNumber,
    String allergies,
  }) async {
    try {
      int id = int.parse(generateRandomId());

      // Retrieve the share_id of the current user from the 'doctors' collection
      String doctorId = await DoctorID().readID();
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();
      String shareId = doctorSnapshot.get('share_id');

      // Upload image to Firebase Storage
      String imageUrl = '';
      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child(DateTime.now().toString());
        await storageRef.putFile(_image);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Save patient data including the image URL and share_id to Firestore
      DocumentReference docRef = await sickCollection.add({
        "id": id,
        "action": ACTION,
        "key": KEY,
        "avatar": imageUrl, // Store the download URL of the image
        "name": name,
        "username": "$name",
        "email": "$name@rounds.com",
        "sick-password": "$name@rounds.com",
        "doctorId": doctorId,
        "share_id": shareId, // Add the share_id field
        "medical-history": medicalHistory,
        "general-information": " ",
        "diagnosis": diagnosis,
        "medicines": " ",
        "surgery": surgery,
        "surgical-history": surgicalHistory,
        "age": age,
        "gender": gender,
        "height": height,
        "weight": weight,
        "temperature": temperature,
        "sugar-level": sugarLevel,
        "blood-pressure": bloodPressure,
        "smoking": smoking,
        "alcohol": alcohol,
        "occupation": occupation,
        "blood-group": bloodGroup,
        "file-number": fileNumber,
        "allergies": allergies,
        "date-of-admission": dateOfAdmission,
        "date-of-discharge": dateOfDischarge,
        "status": "in",
        "created-at": FieldValue.serverTimestamp(),
        "updated-at": FieldValue.serverTimestamp(),
      });

      await Fluttertoast.showToast(msg: "Patient added successfully.",backgroundColor: teal,
        textColor: Colors.white,);
      Navigator.pop(context);
      Navigator.pop(context); // العودة إلى الشاشة السابقة

    } catch (e) {
      await Fluttertoast.showToast(msg: e.toString(),backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,);
    }
  }

  Future<void> editSick({
    String name,
    String medicalHistory,
    String diagnosis,
    String surgery,
    String height,
    String gender,
    String age,
    String surgicalHistory,
    String weight,
    String sugarLevel,
    String bloodPressure,
    String temperature,
    String dateOfAdmission,
    String dateOfDischarge,
    String smoking,
    String alcohol,
    String occupation,
    String bloodGroup,
    String fileNumber,
    String allergies,
  }) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('id', isEqualTo: widget.sickData.id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // تحديث بيانات المريض الموجود
        var docRef = querySnapshot.docs.first.reference;

        // Update other fields
        await docRef.update({
          "name": name,
          "medical-history": medicalHistory,
          "diagnosis": diagnosis,
          "surgery": surgery,
          "surgical-history": surgicalHistory,
          "age": age,
          "gender": gender,
          "height": height,
          "weight": weight,
          "temperature": temperature,
          "sugar-level": sugarLevel,
          "blood-pressure": bloodPressure,
          "smoking": smoking,
          "alcohol": alcohol,
          "occupation": occupation,
          "blood-group": bloodGroup,
          "file-number": fileNumber,
          "allergies": allergies,
          "date-of-admission": dateOfAdmission,
          "date-of-discharge": dateOfDischarge,
          "updated-at": FieldValue.serverTimestamp(),
        });

        // Upload new avatar if selected
        if (_image != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('avatars')
              .child(DateTime.now().toString());
          await storageRef.putFile(_image);
          String imageUrl = await storageRef.getDownloadURL();
          // Update avatar URL in Firestore
          await docRef.update({"avatar": imageUrl});
        }

        await Fluttertoast.showToast(msg: "Patient updated successfully.",backgroundColor: teal,
          textColor: Colors.white,);
        Navigator.pop(context); // العودة إلى الشاشة السابقة
        Navigator.pop(context); // العودة إلى الشاشة السابقة

        Navigator.pop(context); // العودة إلى الشاشة السابقة

      } else {
        throw 'Document not found';
      }
    } catch (e) {
      await Fluttertoast.showToast(msg: e.toString(),backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,);
    }
  }


  Future<void> checkPermission() async {
    if (Platform.isAndroid) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    }
  }

  Future<void> chooseImage(ImageSource source) async {
    await checkPermission();
    final picker = ImagePicker();
    var pickedImage = await picker.getImage(source: source);
    if (pickedImage != null) {
      File croppedImage = await _cropImage(pickedImage.path);
      if (croppedImage != null) {
        setState(() {
          _image = croppedImage;
        });
      }
    }
  }

  Future<File> _cropImage(String imagePath) async {
    final File imageFile = File(imagePath);
    final img.Image image = img.decodeImage(imageFile.readAsBytesSync());
    final int minSize = image.width < image.height ? image.width : image.height;
    final img.Image croppedImage = img.copyCrop(
      image,
      (image.width - minSize) ~/ 2,
      (image.height - minSize) ~/ 2,
      minSize,
      minSize,
    );
    return File(imageFile.path)..writeAsBytesSync(img.encodeJpg(croppedImage));
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

  TextStyle style =
      TextStyle(color: teal, fontSize: 14, fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sickData == null ? 'Add' : 'Edit'),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          headApp(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * .3),
                  child: GestureDetector(
                    onTap: () {
                      chooseImage(ImageSource.gallery);
                    },
                    child: CircleAvatar(
                      backgroundImage: _image == null
                          ? AssetImage('images/avatar.png')
                          : FileImage(_image),
                      radius: 70,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    buildCard(
                      text: "Name",
                      controller: nameConroler,
                      focusNode: nameFocusNode,
                      nextFocusNode: ageFocusNode,
                    ),
                    Expanded(
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Gender',
                                style: style,
                              ),
                              DropdownButton<String>(
                                value: dropdownValueGender,
                                elevation: 16,
                                style: TextStyle(
                                    color: orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                underline: Container(
                                  height: 2,
                                  color: teal,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValueGender = newValue;
                                  });
                                },
                                items: <String>[
                                  'Male',
                                  'Female'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildCard(
                        text: "Age",
                        controller: ageConroler,
                        focusNode: ageFocusNode,
                        nextFocusNode: heightFocusNode,
                        inputType: TextInputType.number),
                    buildCard(
                        text: "Height",
                        controller: heightConroler,
                        focusNode: heightFocusNode,
                        nextFocusNode: weightFocusNode,
                        inputType: TextInputType.number),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildCard(
                        text: "Weight",
                        controller: weightConroler,
                        focusNode: weightFocusNode,
                        nextFocusNode: surgeryFocusNode,
                        inputType: TextInputType.number),
                    buildCard(
                      text: "Surgery",
                      controller: surgeryConroler,
                        focusNode: surgeryFocusNode,
                        nextFocusNode: surgicalHistoryFocusNode
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildCard(
                        text: "Surgical history",
                        focusNode: surgicalHistoryFocusNode,
                        nextFocusNode: medicalHistoryFocusNode,
                        controller: surgicalHistoryConroler),
                    buildCard(
                        text: "Medical history",
                        focusNode: medicalHistoryFocusNode,
                        nextFocusNode: temperatureFocusNode,
                        controller: medicalHistoryConroler),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'Date of admission',
                                      style: style,
                                    ),
                                    Icon(
                                      Icons.date_range_rounded,
                                      color: teal,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(3000),
                                  ).then((date) {
                                    setState(() {
                                      _dateOfAdmission =
                                          date.toString().substring(0, 10);
                                    });
                                  });
                                },
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    _dateOfAdmission == null
                                        ? "0000-00-00"
                                        : _dateOfAdmission,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'Date of discharge',
                                      style: style,
                                    ),
                                    Icon(
                                      Icons.date_range_rounded,
                                      color: teal,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(3000),
                                  ).then((date) {
                                    setState(() {
                                      _dateOfDischarge =
                                          date.toString().substring(0, 10);
                                    });
                                  });
                                },
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    _dateOfDischarge == null
                                        ? "0000-00-00"
                                        : _dateOfDischarge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildCard(
                        text: "Temperature",
                        focusNode: temperatureFocusNode,
                        nextFocusNode: bloodPressureFocusNode,
                        controller: temperatureConroler),
                    buildCard(
                        text: "Blood pressure",
                        focusNode: bloodPressureFocusNode,
                        nextFocusNode: sugarLevelFocusNode,
                        controller: bloodPressureConroler),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildCard(
                        text: "Sugar level",
                        focusNode: sugarLevelFocusNode,
                        nextFocusNode: diagnosisFocusNode,
                        controller: sugarLevelConroler),
                    buildCard(text: "Diagnosis",
                        focusNode: diagnosisFocusNode,
                        nextFocusNode: occupationFocusNode,
                        controller: diagnosisConroler),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Smoking',
                                style: style,
                              ),
                              DropdownButton<String>(
                                value: dropdownValueSmoking,
                                elevation: 16,
                                style: TextStyle(
                                    color: orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                underline: Container(
                                  height: 2,
                                  color: teal,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValueSmoking = newValue;
                                  });
                                },
                                items: <String>[
                                  'Yes',
                                  'No'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Alcohol',
                                style: style,
                              ),
                              DropdownButton<String>(
                                value: dropdownValueAlcohol,
                                elevation: 16,
                                style: TextStyle(
                                    color: orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                underline: Container(
                                  height: 2,
                                  color: teal,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    dropdownValueAlcohol = newValue;
                                  });
                                },
                                items: <String>[
                                  'Yes',
                                  'No'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildCard(
                        text: "Occupation",
                        focusNode: occupationFocusNode,
                        nextFocusNode: bloodGroupFocusNode,
                        controller: occupationConroler),
                    buildCard(
                        text: "Blood Group",
                        focusNode: bloodGroupFocusNode,
                        nextFocusNode: allergiesFocusNode,
                        controller: bloodGroupConroler),
                  ],
                ),
                Row(
                  children: <Widget>[
                    buildCard(
                        text: "Allergies",
                        focusNode: allergiesFocusNode,
                        nextFocusNode: fileNumberFocusNode,
                        controller: allergiesController),
                    buildCard(
                        text: "File Number",
                        focusNode: fileNumberFocusNode,
                        nextFocusNode: FocusNode(),
                        controller: fileNumberConroler),
                  ],
                ),
                myButton(
                  width: width,
                  onPressed: () async {
                    bool hasInternet = await check();
                    check().then(
                      (intenet) {
                        if (intenet != null || intenet) {
                          widget.sickData == null

                              ? uploadSick(
                                  name: nameConroler.text,
                                  medicalHistory: medicalHistoryConroler.text,
                                  diagnosis: diagnosisConroler.text,
                                  surgery: surgeryConroler.text,
                                  height: heightConroler.text,
                                  gender: dropdownValueGender,
                                  age: ageConroler.text,
                                  surgicalHistory: surgicalHistoryConroler.text,
                                  weight: weightConroler.text,
                                  sugarLevel: sugarLevelConroler.text,
                                  bloodPressure: bloodPressureConroler.text,
                                  temperature: temperatureConroler.text,
                                  dateOfAdmission: _dateOfAdmission,
                                  dateOfDischarge: _dateOfDischarge,
                                  smoking: dropdownValueSmoking,
                                  alcohol: dropdownValueAlcohol,
                                  occupation: occupationConroler.text,
                                  bloodGroup: bloodGroupConroler.text,
                                  fileNumber: fileNumberConroler.text,
                                  allergies: allergiesController.text)
                              : editSick(
                                  name: nameConroler.text,
                                  medicalHistory: medicalHistoryConroler.text,
                                  diagnosis: diagnosisConroler.text,
                                  surgery: surgeryConroler.text,
                                  height: heightConroler.text,
                                  gender: dropdownValueGender,
                                  age: ageConroler.text,
                                  surgicalHistory: surgicalHistoryConroler.text,
                                  weight: weightConroler.text,
                                  sugarLevel: sugarLevelConroler.text,
                                  bloodPressure: bloodPressureConroler.text,
                                  temperature: temperatureConroler.text,
                                  dateOfAdmission: _dateOfAdmission,
                                  dateOfDischarge: _dateOfDischarge,
                                  smoking: dropdownValueSmoking,
                                  alcohol: dropdownValueAlcohol,
                                  occupation: occupationConroler.text,
                                  bloodGroup: bloodGroupConroler.text,
                                  fileNumber: fileNumberConroler.text,
                                  allergies: allergiesController.text);


                        } else {
                          internetMessage(context);
                        }
                        showLoadingDialog(context); // عرض دايلوج التحميل
                      },
                    );
                  },

                  text: error ? 'Loading' : 'Save',
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    String text,
    TextEditingController controller,
    TextInputType inputType,
    FocusNode focusNode,
    FocusNode nextFocusNode,
  }) {
    return Expanded(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(
                  color: teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              TextFormField(
                controller: controller,
                keyboardType: inputType,
                focusNode: focusNode,
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  if (nextFocusNode != null) {
                    FocusScope.of(context).requestFocus(nextFocusNode);
                  }
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  hintText: 'Enter $text',
                  hintStyle: TextStyle(fontSize: 12),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget headApp() {
    return ClipPath(
      clipper: CustomShapeClipper(),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                teal,
                teal,
              ]),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0), // تغيير القيمة حسب الحاجة
            bottomRight: Radius.circular(20.0), // تغيير القيمة حسب الحاجة
          ),
        ),
      ),
    );
  }
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)),
          title: Text('Please Wait', style: TextStyle(color: teal),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Uploading data'),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  void internetMessage(BuildContext context) {}

  CustomShapeClipper() {}
}

class PermissionGroup {
  static var storage;
}

class PermissionHandler {
  requestPermissions(List list) {}
}
