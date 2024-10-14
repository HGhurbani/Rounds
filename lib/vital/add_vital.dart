import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Screens/HomeScreen.dart';
import 'package:rounds/colors.dart';
import 'package:rounds/component.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Network/SickModel.dart';
import '../Network/SuccessModel.dart';
import '../Status/DoctorID.dart';

class AddVitalScreen extends StatefulWidget {
  final DoctorSicks sick;
  final int id;
  final VitalSigns vitalSigns;

  AddVitalScreen(this.sick, this.id, this.vitalSigns);

  @override
  State<AddVitalScreen> createState() => _AddVitalScreenState();
}

class _AddVitalScreenState extends State<AddVitalScreen> {
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    if (widget.vitalSigns != null) {
      heartController.text = widget.vitalSigns.heart_rate;
      respiratoryController.text = widget.vitalSigns.respiratory_rate;
      pressureController.text = widget.vitalSigns.blood_pressure;
      temperatureController.text = widget.vitalSigns.temperature;
      sugarController.text = widget.vitalSigns.blood_sugar;
      otherController.text = widget.vitalSigns.other;
      dateController.text = widget.vitalSigns.date;
    }
  }

  FlutterAudioRecorder _recorder;
  Recording _recording;
  File _audio;

  Future startRecording() async {
    String customPath = '/Round_audio_record_';
    Directory appDocDirectory;
    if (Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
    customPath = appDocDirectory.path + customPath + DateTime.now().toString();
    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.WAV, sampleRate: 22050);
    await _recorder.initialized;
    _recorder.start();
    setState(() {
      isRecord = true;
    });
  }

  Future stopRecording() async {
    var result = await _recorder.stop();
    setState(() {
      _recording = result;
      isRecord = false;
      _audio = File(_recording.path);
    });
  }

  bool isRecord = false;

  var heartController = TextEditingController();

  var respiratoryController = TextEditingController();

  var pressureController = TextEditingController();

  var temperatureController = TextEditingController();

  var sugarController = TextEditingController();

  var otherController = TextEditingController();

  var dateController = TextEditingController();
  var audioController = TextEditingController();
  stt.SpeechToText _speech;

  Future getAudio() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', '3gpp', '3gp'],
    );
    setState(() {
      if (result != null) {
        _audio = File(result.files.single.path);
      }
    });
  }

  bool _isListeningHeart = false;
  bool _isListeningRespiratory = false;
  bool _isListeningPressure = false;
  bool _isListeningTemperature = false;
  bool _isListeningSugar = false;
  bool _isListeningOther = false;

  Future<bool> _listen(TextEditingController controller, bool coloring) async {
    if (!coloring) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => coloring = true);
        _speech.listen(
          onResult: (val) => setState(() {
            // إلحاق النص الجديد بالنص الموجود بالفعل
            controller.text += " ${val.recognizedWords}";
          }),
        );
      }
    } else {
      setState(() => coloring = false);
      _speech.stop();
    }
    return coloring;
  }


  final String key = 'os14042020ah';
  final String action = 'add-vital-signs';
  final String editAction = 'edit-vital-signs';

  uploadVitalSigns(context, heartRate, respiratoryRate, bloodPressure,
      temperature, bloodSugar, date, other) async {
    try {
      CollectionReference vitalSigns =
      FirebaseFirestore.instance.collection('vital_signs');

      await vitalSigns.add({
        'heart_rate': heartRate,
        'respiratory_rate': respiratoryRate,
        'blood_pressure': bloodPressure,
        'temperature': temperature,
        'blood_sugar': bloodSugar,
        'date': date,
        'other': other,
        'doctor_id': await DoctorID().readID(),
        'sick_id': widget.sick.id,
      });

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Please try again ..",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepOrangeAccent,
          textColor: Colors.white,
          fontSize: 16.0);
      print("Exception In Vital Sign : $e");
    }
  }

  editVitalSigns(context, heartRate, respiratoryRate, bloodPressure,
      temperature, bloodSugar, date, other) async {
    try {
      CollectionReference vitalSigns =
      FirebaseFirestore.instance.collection('vitalSigns');

      await vitalSigns.doc(widget.vitalSigns.id).update({
        'heart_rate': heartRate,
        'respiratory_rate': respiratoryRate,
        'blood_pressure': bloodPressure,
        'temperature': temperature,
        'blood_sugar': bloodSugar,
        'date': date,
        'other': other,
        'doctor_id': await DoctorID().readID(),
        'sick_id': widget.id,
      });

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Please try again ..",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepOrangeAccent,
          textColor: Colors.white,
          fontSize: 16.0);
      print("Exception In Vital Sign : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Vital Sign",
        ),
        centerTitle: true,
        backgroundColor: teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.775,
                    child: defaultTextFormField(
                      read: true,
                      controller: dateController,
                      hintText: "Date",
                    ),
                  ),
                  CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor: teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                        ),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(3000),
                          ).then((date) {
                            setState(() {
                              dateController.text = date.toString().substring(0, 10);
                            });
                          });
                        },
                      ))
                ],
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.78,
                    child: defaultTextFormField(
                        controller: heartController, hintText: "Heart Rate"),
                  ),
                  CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor: _isListeningHeart ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(heartController, _isListeningHeart)
                              .then((value) {
                            setState(() {
                              _isListeningHeart = value;
                            });
                          });
                        },
                      ))
                ],
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.78,
                    child: defaultTextFormField(
                        controller: respiratoryController,
                        hintText: "Respiratory Rate"),
                  ),
                  CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor:
                          _isListeningRespiratory ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(respiratoryController,
                                  _isListeningRespiratory)
                              .then((value) {
                            setState(() {
                              _isListeningRespiratory = value;
                            });
                          });
                        },
                      ))
                ],
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.78,
                    child: defaultTextFormField(
                        controller: pressureController,
                        hintText: "Blood Pressure"),
                  ),
                  CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor: _isListeningPressure ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(pressureController, _isListeningPressure)
                              .then((value) {
                            setState(() {
                              _isListeningPressure = value;
                            });
                          });
                        },
                      ))
                ],
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.78,
                    child: defaultTextFormField(
                        controller: sugarController, hintText: "Blood Sugar"),
                  ),
                  CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor: _isListeningSugar ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(sugarController, _isListeningSugar)
                              .then((value) {
                            setState(() {
                              _isListeningSugar = value;
                            });
                          });
                        },
                      ))
                ],
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.78,
                    child: defaultTextFormField(
                        controller: temperatureController,
                        hintText: "Temperature"),
                  ),
                  CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor:
                          _isListeningTemperature ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(temperatureController,
                                  _isListeningTemperature)
                              .then((value) {
                            setState(() {
                              _isListeningTemperature = value;
                            });
                          });
                        },
                      ))
                ],
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.78,
                    child: defaultTextFormField(
                        controller: otherController, hintText: "Others"),
                  ),
                  CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor: _isListeningOther ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(otherController, _isListeningOther)
                              .then((value) {
                            setState(() {
                              _isListeningOther = value;
                            });
                          });
                        },
                      ))
                ],
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  width: width * 0.6,
                  child: TextFormField(
                    controller: audioController,
                    readOnly: false, // Set to false to make it editable
                    decoration: InputDecoration(
                      hintText: _audio == null ? "Record" : _audio.path,
                      hintStyle: TextStyle(color: Colors.deepOrange), // Hint text color
                      filled: true,
                      fillColor: Colors.white, // Background color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0), // Border radius
                        borderSide: BorderSide(color: Colors.teal, width: 1.0), // Border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.teal, width: 1.0), // Border color when focused
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.teal, width: 1.0), // Border color when enabled
                      ),
                    ),
                    style: TextStyle(color: Colors.deepOrange), // Text color
                    onTap: () {
                      if (_audio == null) {
                        getAudio();
                      }
                    },
                  ),
                ),

                IconButton(
                  onPressed: () {
                    getAudio();
                  },
                  icon: Icon(
                    Icons.upload_file,
                    size: 28,
                    color: deepBlue,
                  ),
                ),
                CircleAvatar(
                  radius: (width - (width * 0.8)) / 4,
                  backgroundColor: isRecord ? Colors.deepOrangeAccent : teal,
                  child: IconButton(
                    icon: isRecord
                        ? Icon(Icons.stop)
                        : Icon(
                            Icons.mic_rounded,
                          ),
                    onPressed: () {
                      if (isRecord) {
                        stopRecording();
                      } else {
                        startRecording();
                      }
                    },
                  ),
                ),
              ]),
              SizedBox(
                height: height * 0.01,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: width * 0.5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16), color: orange),
                    child: TextButton(
                      child: Text(
                        'Add Vital Sign',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                      onPressed: () async {
                        if (widget.vitalSigns == null) {
                          uploadVitalSigns(
                              context,
                              heartController.text,
                              respiratoryController.text,
                              pressureController.text,
                              temperatureController.text,
                              sugarController.text,
                              dateController.text,
                              otherController.text);

                        } else {
                          editVitalSigns(
                              context,
                              heartController.text,
                              respiratoryController.text,
                              pressureController.text,
                              temperatureController.text,
                              sugarController.text,
                              dateController.text,
                              otherController.text,);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
