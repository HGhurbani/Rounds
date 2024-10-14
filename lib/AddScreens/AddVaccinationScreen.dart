import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';

import 'package:rounds/Network/SickModel.dart';
import 'package:rounds/Screens/HomeScreen.dart';
import 'package:rounds/Screens/ProfileScreen.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:rounds/component.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


import '../colors.dart';

class AddVaccinationScreen extends StatefulWidget {
  final int id;
  final DoctorSicks patient;
  String vaccinationName;
  String vaccinationDate;
  String vaccinationAge;
  int index;


  AddVaccinationScreen(this.id, this.patient, this.vaccinationName,
      this.vaccinationDate, this.vaccinationAge, this.index);

  @override
  _AddVaccinationScreenState createState() => _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends State<AddVaccinationScreen> {
  final nameConroler = TextEditingController();
  final dateConroler = TextEditingController();
  final ageConroler = TextEditingController();

  bool error = false;
  bool complete = false;

  final String KEY = 'os14042020ah';
  final String ACTION = 'add-vaccination';
  SuccessModel successModel;
  Future<void> _showInfoDialog(BuildContext context) {
    bool dontShowAgain = false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'To use the microphone for input, press the microphone icon next to the text field. '
                      'Speak clearly into your device\'s microphone. The text will be added to the current content of the field. '
                      'Press the microphone icon again to stop listening.'),
              Row(
                children: [
                  Checkbox(
                    value: dontShowAgain,
                    onChanged: (bool value) {
                      setState(() {
                        dontShowAgain = value;
                      });
                    },
                  ),
                  Text('Don\'t show again'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if (dontShowAgain) {
                  await prefs.setBool('dontShowAgain', true);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<SuccessModel> uploadMedication(BuildContext context, String name, String date, String age) async {
    try {
      final CollectionReference medications = FirebaseFirestore.instance.collection('vaccinations');

      DocumentReference docRef = await medications.add({
        'action': ACTION,
        'key': KEY,
        'vaccination_name': name,
        'vaccination_date': date,
        'age': age,
        'sick_id': widget.patient.id,
        'doctor_id': await DoctorID().readID(),
        'timestamp': FieldValue.serverTimestamp(), // لإضافة وقت الإدراج
      });

      // إنشاء نموذج نجاح بناءً على الإدراج الناجح
      successModel = SuccessModel(
        // id: docRef.id,
        // message: 'Medication uploaded successfully',
      );
    } catch (e) {
      print("Exception Caught : $e");

      // إنشاء نموذج نجاح مع رسالة خطأ
      successModel = SuccessModel(
        // id: '',
        // message: 'Error uploading medication: $e',
      );
    }
    return successModel;
  }

  editVaccination(context, name, date, age) async {
    try {
      FormData formData = FormData.fromMap({
        "action": "edit-sick-vaccination",
        "key": KEY,
        "vac_name": name,
        "vac_date": date,
        "vac_age": age,
        "sick_id": widget.id,
        "doctor_id": await DoctorID().readID(),
        "index": widget.index
      });



      if (successModel.st == 'success') {
        successMessage(context);
        setState(() {
          error = false;
        });
      } else {
        setState(() {
          error = false;
        });
        errorMessage(context);
      }
    } catch (e) {
      print("Exception Caught : $e");
    }
  }

  successMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
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
        return alert;
      },
    );
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speech = stt.SpeechToText();
    nameConroler.text = widget.vaccinationName;
    dateConroler.text = widget.vaccinationDate;
    ageConroler.text = widget.vaccinationAge;
  }
  stt.SpeechToText _speech;
  bool _isListeningTitle=false;
  Future<bool> _listen(TextEditingController controller, bool coloring) async {
    if (!coloring) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => coloring = true);
        String originalText = controller.text; // تخزين النص الأصلي في بداية الاستماع
        List<String> recognizedWordsList = []; // لتتبع الكلمات المعترف بها بشكل فردي

        _speech.listen(
          onResult: (val) => setState(() {
            String currentRecognizedWords = val.recognizedWords.trim(); // تنظيف وتقليم النص المعترف به
            List<String> currentWords = currentRecognizedWords.split(' '); // تقسيم النص إلى كلمات

            // تحديد الكلمات الجديدة التي لم تُعترف بها من قبل
            List<String> newWords = currentWords.where((word) => !recognizedWordsList.contains(word)).toList();

            if (newWords.isNotEmpty) {
              controller.text = originalText + (originalText.isEmpty ? "" : " ") + newWords.join(' '); // إضافة الكلمات الجديدة فقط
              originalText = controller.text; // تحديث النص الأصلي بالكامل
              recognizedWordsList.addAll(newWords); // إضافة الكلمات الجديدة إلى قائمة الكلمات المعترف بها
            }
          }),
        );
      }
    } else {
      setState(() => coloring = false);
      _speech.stop();
    }
    return coloring;
  }




  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
        elevation: 0,
        backgroundColor: teal,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: height * .1,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30)),
                color: teal),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      right: 8, top: 8, left: 5, bottom: 8),
                  child: SizedBox(
                    height: 100,
                    child: CircleAvatar(
                      backgroundImage: (widget.patient?.avatar == null ||
                              widget.patient?.avatar == false)
                          ? AssetImage('images/doctoravatar.png')
                          : NetworkImage(widget.patient.avatar),
                      radius: 50,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.patient.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.patient.fileNumber,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: width * 0.8,
                      child: defaultTextFormField(
                          controller: nameConroler, hintText: "Vaccine"),
                    ),
                  ),
                  CircleAvatar(
                      radius: (width-(width*0.8))/4,
                      backgroundColor: _isListeningTitle? Colors.red: teal,
                      child: IconButton(icon: Icon(                            _isListeningTitle ? Icons.pause : Icons.mic_none_outlined,
                      ), onPressed: (){
                        _listen(nameConroler,_isListeningTitle).then((value) {
                          setState(() {
                            _isListeningTitle = value;
                          });
                        });
                      },))
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    width: width * .8,
                    child: defaultTextFormField(
                        controller: ageConroler, hintText: "Age")),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.8,
                      child: defaultTextFormField(
                        controller: dateConroler,
                        hintText:
                        dateConroler.text.isEmpty ? "Date" : dateConroler.text,
                        read: true,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(3000),
                          ).then((date) {
                            setState(() {
                              dateConroler.text = date.toString().substring(0, 10);
                            });
                          });
                        },
                        icon: Icon(
                          Icons.calendar_today,
                          color: teal,
                        ))
                  ],
                ),
              ),
              myButton(
                width: width,
                onPressed: () async {
                  check().then((intenet) {
                    if (intenet != null && intenet) {
                      // Internet Present Case
                      widget.index == 0
                          ? uploadMedication(context, nameConroler.text,
                          dateConroler.text, ageConroler.text)
                          .then((value) {
                        if (value.st == 'success') {
                          successMessage(context);
                          setState(() {
                            error = false;
                          });
                        } else {
                          setState(() {
                            error = false;
                          });
                          errorMessage(context);
                        }
                      })
                          : editVaccination(
                          context, nameConroler.text, dateConroler.text, ageConroler.text);
                    } else {
                      internetMessage(context);
                    }
                  });
                },
                text: error ? 'Uploading' : 'Add Medicine',
              )
            ],
          )
        ],
      ),
    );
  }

}
