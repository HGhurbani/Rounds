import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:rounds/colors.dart';
import 'package:rounds/component.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AddMedicinesScreen extends StatefulWidget {
  final int patientId;
  final DoctorSicks patient;
  String medicationTitle;
  String medicationText;
  int index;

  AddMedicinesScreen(this.patientId, this.patient, this.medicationTitle,
      this.medicationText, this.index);

  @override
  _AddMedicinesScreenState createState() => _AddMedicinesScreenState();
}

class _AddMedicinesScreenState extends State<AddMedicinesScreen> {
  final textConroler = TextEditingController();
  final titleConroler = TextEditingController();
  bool isStopped = false; // حالة العلاج إذا كان موقفًا أم لا
  bool error = false;

  final String KEY = 'os14042020ah';
  final String ACTION = 'add-medication';

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
  Future<SuccessModel> uploadMedication(
      BuildContext context, String text, String title) async {
    try {
      final CollectionReference medications =
      FirebaseFirestore.instance.collection('medications');

      DocumentReference docRef = await medications.add({
        'action': ACTION,
        'key': KEY,
        'medication_text': text,
        'medication_title': title,
        'sick_id': widget.patient.id,
        'is_stopped': isStopped, // إضافة حالة العلاج
        'doctor_id': await DoctorID().readID(),
        'timestamp': FieldValue.serverTimestamp(), // لإضافة وقت الإدراج
      });

      // تعيين successModel إلى نجاح
      successModel = SuccessModel(
        // نعين رسالة نجاح هنا
        st: 'success',
        message: 'Medication uploaded successfully',
      );
    } catch (e) {
      print("Exception Caught : $e");

      // تعيين successModel إلى فشل
      successModel = SuccessModel(
        st: 'error', // تحديد حالة الخطأ
        message: 'Error uploading medication: $e',
      );
    }
    return successModel;
  }


  editMedication(BuildContext context, String text, String title) async {
    try {
      String doctorId = await DoctorID().readID();
      DocumentReference medicationRef = FirebaseFirestore.instance
          .collection('medications')
          .doc(widget.patient.id
              .toString()); // افتراض أن `sick_id` هو معرف الوثيقة

      await medicationRef.update({
        'medication_text': text,
        'medication_title': title,
        'doctor_id': doctorId,
        'index': widget.index,
        'is_stopped': isStopped, // تحديث حالة العلاج
        'action': 'edit-sick-medication',
        'key': KEY,
        'timestamp': FieldValue.serverTimestamp(), // لتحديث وقت التعديل
      });

      // عرض رسالة النجاح
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Status'),
            content: Text('Medication updated successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق الحوار
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      setState(() {
        error = false;
      });
    } catch (e) {
      print("Exception Caught : $e");

      // عرض رسالة الخطأ
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Status'),
            content: Text('Error updating medication: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق الحوار
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      setState(() {
        error = true;
      });
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

  stt.SpeechToText _speech;
  bool _isListeningTitle = false;
  bool _isListeningText = false;

  Future<bool> _listen(TextEditingController controller, bool coloring) async {
    if (!coloring) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => coloring = true);
        String originalText = controller.text; // تخزين النص الأصلي في بداية الاستماع
        List<String> recognizedWordsList = []; // لتتبع الكلمات التي تم التعرف عليها بالفعل

        _speech.listen(
          onResult: (val) => setState(() {
            String currentRecognizedWords = val.recognizedWords.trim();
            List<String> currentWords = currentRecognizedWords.split(' '); // تقسيم النص الحالي إلى كلمات

            // تحديد الكلمات الجديدة التي لم تكن جزءًا من النص المعترف به سابقاً
            List<String> newWords = currentWords.where((word) => !recognizedWordsList.contains(word)).toList();

            if (newWords.isNotEmpty) {
              controller.text = originalText + (originalText.isEmpty ? "" : " ") + newWords.join(' '); // إضافة الكلمات الجديدة فقط
              recognizedWordsList.addAll(newWords); // تحديث قائمة الكلمات المعترف بها
              originalText = controller.text; // تحديث النص الأصلي بالكامل
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _speech = stt.SpeechToText();
    textConroler.text = widget.medicationText;
    titleConroler.text = widget.medicationTitle;
    // تعيين مستمع لتغيرات الحالة
    _speech.statusListener = (status) {
      if (status == 'done' || status == 'notListening') {
        // إعادة الأيقونة واللون عند انتهاء الاستماع
        setState(() {
          _isListeningTitle = false;
          _isListeningText = false;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            _showInfoDialog(context);
          },
        ),
      ], elevation: 0),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),  // لغلق لوحة المفاتيح عند الضغط على أي مكان
        child: SingleChildScrollView( // إضافة SingleChildScrollView لتجنب مشكلة لوحة المفاتيح
          child: Column(
            children: [
              Container(
                height: height * .1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30)),
                    color: teal),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: width * 0.7,
                      child: defaultTextFormField(
                          controller: titleConroler, hintText: "Drug name"),
                    ),
                    CircleAvatar(
                        radius: (width - (width * 0.8)) / 4,
                        backgroundColor:
                        _isListeningTitle ? Colors.red : teal,
                        child: IconButton(
                          icon: Icon(
                            _isListeningTitle ? Icons.pause : Icons.mic_none_outlined,
                          ),
                          onPressed: () {
                            _listen(titleConroler, _isListeningTitle)
                                .then((value) {
                              setState(() {
                                _isListeningTitle = value;
                              });
                            });
                          },
                        ))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: width * 0.7,
                      child: defaultTextFormField(
                          controller: textConroler, hintText: "Drug details"),
                    ),
                    CircleAvatar(
                        radius: (width - (width * 0.8)) / 4,
                        backgroundColor: _isListeningText ? Colors.red : teal,
                        child: IconButton(
                          icon: Icon(
                            _isListeningText ? Icons.pause : Icons.mic_none_outlined,
                          ),
                          onPressed: () {
                            _listen(textConroler, _isListeningText)
                                .then((value) {
                              setState(() {
                                _isListeningText = value;
                              });
                            });
                          },
                        ))
                  ],
                ),
              ),
              // إضافة مربع الاختيار لحالة العلاج
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isStopped,
                      onChanged: (bool value) {
                        setState(() {
                          isStopped = value;
                        });
                      },
                    ),
                    Text('Stopped?')
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
                          ? uploadMedication(context, textConroler.text, titleConroler.text)
                          .then((value) {
                        if (value.st == 'success') {
                          successMessage(context);
                          setState(() {
                            error = false;
                            textConroler.clear(); // مسح النص من الـ TextFormField
                            titleConroler.clear(); // مسح النص من الـ TextFormField
                          });
                        } else {
                          setState(() {
                            error = true;
                          });
                          errorMessage(context);  // عرض رسالة الخطأ فقط إذا فشلت العملية
                        }
                      })
                          : editMedication(context, textConroler.text, titleConroler.text);
                    } else {
                      internetMessage(context); // إذا كان الإنترنت غير متصل
                    }
                  });
                },
                text: error ? 'Uploading' : 'Add Medicine',
              )
            ],
          ),
        ),
      ),
    );
  }
}
