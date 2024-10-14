import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rounds/Network/DoctorDataModel.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:rounds/colors.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rounds/component.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Screens/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddReportScreen extends StatefulWidget {
  final int id;
  final DoctorSicks patient;
  final String reportTitle;
  final String reportText;
  final int index;
  final String documentId; // Add this line

  AddReportScreen(
      this.id, this.patient, this.reportTitle, this.reportText, this.index,
      {this.documentId}); // Add this line

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final reportNameConroler = TextEditingController();
  final infoConroler = TextEditingController();

  bool error = false;
  bool complete = true;
  bool isLoading = false;

  final String KEY = 'os14042020ah';
  final String ACTION = 'add-report';
  final String ACTIONEDIT = 'edit-sick-report';
  List<File> pdfFiles = [];

  Future getFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        pdfFiles = result.paths.map((path) => File(path)).toList();
      });
    }
  }

  Future uploadReport(BuildContext context, String title, String text) async {
    String audioName = _audio?.path == null ? "" : _audio.path.split('/').last;

    try {
      // Upload audio file to Firebase Storage
      String audioUrl = "";
      if (_audio != null) {
        firebase_storage.Reference audioRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('audio')
            .child(audioName);
        await audioRef.putFile(_audio);
        audioUrl = await audioRef.getDownloadURL();
      }

      // Upload PDF files to Firebase Storage
      List<String> pdfUrls = [];
      for (var file in pdfFiles) {
        String fileName = '${DateTime.now()}.pdf';
        firebase_storage.Reference pdfRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('pdfs')
            .child(fileName);
        await pdfRef.putFile(file);
        String pdfUrl = await pdfRef.getDownloadURL();
        pdfUrls.add(pdfUrl);
      }

      // Construct report data
      Map<String, dynamic> reportData = {
        "action": ACTION,
        "key": KEY,
        "report_title": title,
        "report_text": text,
        "sick_id": widget.patient.id,
        "doctor_id": await DoctorID().readID(),
        "report_file": audioUrl,
        "pdf_files": pdfUrls,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // Upload report data to Firestore using .add()
      await FirebaseFirestore.instance.collection('medical_reports').add(reportData);

      // If successful, show success message
      successMessage(context);
      setState(() {
        error = false;
        isLoading = false;
      });
    } catch (e) {
      print("Exception Caught : $e");
      // Show error message
      Fluttertoast.showToast(
        msg: "Server error ..",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Handle any specific error handling or logging as needed
      setState(() {
        error = true; // Update error state if necessary
        isLoading = false;
      });
    }
  }

  Future editReport(BuildContext context, String title, String text) async {
    String audioName = _audio?.path == null ? "" : _audio.path.split('/').last;

    try {
      // Upload audio file to Firebase Storage if updated
      String audioUrl = "";
      if (_audio != null) {
        firebase_storage.Reference audioRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('audio')
            .child(audioName);
        await audioRef.putFile(_audio);
        audioUrl = await audioRef.getDownloadURL();
      }

      // Upload PDF files to Firebase Storage if updated
      List<String> pdfUrls = [];
      for (var file in pdfFiles) {
        String fileName = '${DateTime.now()}.pdf';
        firebase_storage.Reference pdfRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('pdfs')
            .child(fileName);
        await pdfRef.putFile(file);
        String pdfUrl = await pdfRef.getDownloadURL();
        pdfUrls.add(pdfUrl);
      }

      // Construct report data
      Map<String, dynamic> reportData = {
        "action": ACTIONEDIT,
        "key": KEY,
        "report_title": title,
        "report_text": text,
        "sick_id": widget.patient.id,
        "index": widget.index, // Remove this line if not needed
        "doctor_id": await DoctorID().readID(),
        "report_file": audioUrl.isEmpty ? null : audioUrl,
        "pdf_files": pdfUrls.isEmpty ? null : pdfUrls,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // Update report data to Firestore using .update()
      await FirebaseFirestore.instance
          .collection('medical_reports')
          .doc(widget.documentId) // Use documentId to update the document
          .update(reportData);

      // If successful, show success message
      successMessage(context);
      setState(() {
        error = false;
        isLoading = false;
      });
    } catch (e) {
      print("Exception Caught : $e");
      // Show error message
      Fluttertoast.showToast(
        msg: "Server error ..",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Handle any specific error handling or logging as needed
      setState(() {
        error = true; // Update error state if necessary
        isLoading = false;
      });
    }
  }

  DoctorSicks sicks;

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
    reportNameConroler.text = widget.reportTitle;
    infoConroler.text = widget.reportText;
    // تعيين مستمع لتغيرات الحالة
    _speech.statusListener = (status) {
      if (status == 'done' || status == 'notListening') {
        // إعادة الأيقونة واللون عند انتهاء الاستماع
        setState(() {
          _isListeningName = false;
          _isListeningReport = false;
        });
      }
    };
  }

  /*********************** speech **********************/
  stt.SpeechToText _speech;
  bool _isListeningName = false;
  bool _isListeningReport = false;

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




  FlutterAudioRecorder _recorder;
  Recording _recording;
  File _audio;

  bool isRecord = false;

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: teal,
        title: Text(widget.documentId == null ? "Add Report" : "Edit Report"), // Change title based on documentId
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: height * 0.15,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30)),
                color: teal),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20.0),
                  child: CircleAvatar(
                    backgroundImage: (widget.patient?.avatar == null ||
                        widget.patient?.avatar == false)
                        ? AssetImage('images/doctoravatar.png')
                        : NetworkImage(widget.patient.avatar),
                    radius: 40,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
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
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                          width: width * .8,
                          child: defaultTextFormField(
                              controller: reportNameConroler,
                              TextformSize: 16,
                              hintText: "Patient Name")),
                      CircleAvatar(
                        radius: (width - (width * 0.8)) / 4,
                        backgroundColor: _isListeningName ? Colors.red : teal,
                        child: IconButton(
                          icon: Icon(
                            _isListeningName ? Icons.pause : Icons.mic_none_outlined,
                          ),
                          onPressed: () {
                            _listen(reportNameConroler, _isListeningName)
                                .then((value) {
                              setState(() {
                                _isListeningName = value;
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: width * 0.8,
                        child: defaultTextFormField(
                            controller: infoConroler,
                            TextformSize: 16,
                            hintText: "Report"),
                      ),
                      CircleAvatar(
                        radius: (width - (width * 0.8)) / 4,
                        backgroundColor: _isListeningReport ? Colors.red : teal,
                        child: IconButton(
                          icon: Icon(
                            _isListeningReport ? Icons.pause : Icons.mic_none_outlined,

                          ),
                          onPressed: () {
                            _listen(infoConroler, _isListeningReport)
                                .then((value) {
                              setState(() {
                                _isListeningReport = value;
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                          width: width * 0.8,
                          child: defaultTextFormField(
                              read: true,
                              TextformSize: 16,
                              hintText:
                              _audio == null ? "Record" : _audio.path)),
                      CircleAvatar(
                        radius: (width - (width * 0.8)) / 4,
                        backgroundColor: isRecord ? Colors.deepOrangeAccent : teal,
                        child: IconButton(
                          icon: isRecord
                              ? Icon(Icons.pause)
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:  TextButton.icon(
                    onPressed: () {
                      getFile();
                    },
                    label: pdfFiles.isEmpty ? Text(
                      "Add PDF File",
                      style: TextStyle(color: orange, fontSize: 15),
                    ):Column(
                      children: pdfFiles.map((file) {
                        return ListTile(
                          title: Text(file.path.split("file_picker/").last.toString(),style: TextStyle(color: teal),),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                pdfFiles.remove(file);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    icon: Icon(
                      Icons.picture_as_pdf,
                      size: 28,
                      color:pdfFiles.isEmpty ? teal : orange,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: width * 0.5,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: orange),
                        child: TextButton(
                          onPressed: () async {
                            if (widget.documentId == null) {
                              uploadReport(context, reportNameConroler.text, infoConroler.text);
                            } else {
                              editReport(context, reportNameConroler.text, infoConroler.text);
                            }
                          },
                          child: Text(
                            isLoading == false
                                ? widget.documentId == null
                                ? 'Add Report'
                                : 'Update Report'
                                : "Loading ..",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              // fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
