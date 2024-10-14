import 'package:connectivity/connectivity.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rounds/component.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../VideoItems.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../colors.dart';

class AddVitalSignScreen extends StatefulWidget {
  final String sectionName;
  final int id;
  final String title;
  final String date;
  final String result;
  final String normalValue;
  final int index;
  final String noResult;
  final String patientId;
  final DoctorSicks patient;
  final String documentId; // Add this to track document ID

  AddVitalSignScreen(
      this.sectionName,
      this.id,
      this.title,
      this.date,
      this.result,
      this.normalValue,
      this.index,
      this.noResult,
      this.patientId,
      this.patient,
      [this.documentId]);

  @override
  _AddVitalSignScreen createState() => _AddVitalSignScreen();
}

class _AddVitalSignScreen extends State<AddVitalSignScreen> {
  bool isLoading = false;
  bool firstLoad = true;

  final titleConroler = TextEditingController();
  final dateConroler = TextEditingController();
  final heartRateController = TextEditingController();
  final respirataryRateController = TextEditingController();
  final resultConroler = TextEditingController();
  final bloodSugarController = TextEditingController();
  final bloodPressureController = TextEditingController();
  final normalValueConroler = TextEditingController();
  final temperatureController = TextEditingController();
  final othersController = TextEditingController();

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

  String getAction() {
    if (widget.sectionName == "Nervous System") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Skin") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Eye") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Musculoskeletal System") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Cardiovascular System") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Blood") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Digestive System") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Genital System") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Prenatal") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Infertility") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Lymphatic System") {
      action = "NonRadiology";
      return action;
    } else if (widget.sectionName == "Non Radiology Others") {
      action = "NonRadiology";
      return action;
    }
    return action;
  }

  String actionName = '';
  String action = '';
  bool error = false;
  File _video;
  File _audio;
  File _image;
  File _resultFile;
  List<File> images = [];
  List<File> documents = [];

  String getActionName() {
    if (widget.sectionName == "Hematology") {
      actionName = "add-laboratory-hematology";
      return actionName;
    } else if (widget.sectionName == "Chemistry") {
      actionName = "add-laboratory-chemistry";
      return actionName;
    } else if (widget.sectionName == "Microbiology") {
      actionName = "add-laboratory-microbiology";
      return actionName;
    } else if (widget.sectionName == "Histopathology") {
      actionName = "add-laboratory-histopathology";
      return actionName;
    } else if (widget.sectionName == "Laboratory Others") {
      actionName = "add-laboratory-others";
      return actionName;
    } else if (widget.sectionName == "Nervous System") {
      actionName = "add-non-radiology-nervous-system";
      return actionName;
    } else if (widget.sectionName == "Skin") {
      actionName = "add-non-radiology-skin";
      return actionName;
    } else if (widget.sectionName == "Eye") {
      actionName = "add-non-radiology-eye";
      return actionName;
    } else if (widget.sectionName == "Musculoskeletal System") {
      actionName = "add-non-radiology-musculoskeletal-system";
      return actionName;
    } else if (widget.sectionName == "Cardiovascular System") {
      actionName = "add-non-radiology-cardiovascular-system";
      return actionName;
    } else if (widget.sectionName == "Blood") {
      actionName = "add-non-radiology-blood";
      return actionName;
    } else if (widget.sectionName == "Digestive System") {
      actionName = "add-non-radiology-digestive-system";
      return actionName;
    } else if (widget.sectionName == "Genital System") {
      actionName = "add-non-radiology-genital-system";
      return actionName;
    } else if (widget.sectionName == "Prenatal") {
      actionName = "add-non-radiology-prenatal";
      return actionName;
    } else if (widget.sectionName == "Infertility") {
      actionName = "add-non-radiology-infertility";
      return actionName;
    } else if (widget.sectionName == "Lymphatic System") {
      actionName = "add-non-radiology-lymphatic-system";
      return actionName;
    } else if (widget.sectionName == "Non Radiology Others") {
      actionName = "add-non-radiology-others";
      return actionName;
    } else if (widget.sectionName == "X-ray") {
      actionName = "add-radiology-xray";
      return actionName;
    } else if (widget.sectionName == "CT-Scan") {
      actionName = "add-radiology-ct-scan";
      return actionName;
    } else if (widget.sectionName == "MRI") {
      actionName = "add-radiology-mri";
      return actionName;
    } else if (widget.sectionName == "Ultrasound") {
      actionName = "add-radiology-ultrasound";
      return actionName;
    } else if (widget.sectionName == "IsotopeScan") {
      actionName = "add-radiology-isotope-scan";
      return actionName;
    } else if (widget.sectionName == "Radiology Others") {
      actionName = "add-radiology-others";
      return actionName;
    } else if (widget.sectionName == "heart Rate") {
      actionName = "add-vital-signs-heart-rate";
      return actionName;
    } else if (widget.sectionName == "Respiratory Rate") {
      actionName = "add-vital-signs-respiratory-rate";
      return actionName;
    } else if (widget.sectionName == "blood Pressure") {
      actionName = "add-vital-signs-blood-pressure";
      return actionName;
    } else if (widget.sectionName == "Temperature") {
      actionName = "add-vital-signs-temperature";
      return actionName;
    } else if (widget.sectionName == "blood Sugar") {
      actionName = "add-vital-signs-blood-sugar";
      return actionName;
    } else {
      actionName = "add-vital-signs-others";
      return actionName;
    }
  }

  String getEditActionName() {
    if (widget.sectionName == "Hematology") {
      actionName = "hematology";
      return actionName;
    } else if (widget.sectionName == "Chemistry") {
      actionName = "chemistry";
      return actionName;
    } else if (widget.sectionName == "Microbiology") {
      actionName = "microbiology";
      return actionName;
    } else if (widget.sectionName == "Histopathology") {
      actionName = "histopathology";
      return actionName;
    } else if (widget.sectionName == "Laboratory Others") {
      actionName = "laboratory-others";
      return actionName;
    } else if (widget.sectionName == "Nervous System") {
      actionName = "nervous-system";
      return actionName;
    } else if (widget.sectionName == "Skin") {
      actionName = "skin";
      return actionName;
    } else if (widget.sectionName == "Eye") {
      actionName = "eye";
      return actionName;
    } else if (widget.sectionName == "Musculoskeletal System") {
      actionName = "musculoskeletal-system";
      return actionName;
    } else if (widget.sectionName == "Cardiovascular System") {
      actionName = "cardiovascular-system";
      return actionName;
    } else if (widget.sectionName == "Blood") {
      actionName = "blood";
      return actionName;
    } else if (widget.sectionName == "Digestive System") {
      actionName = "digestive-system";
      return actionName;
    } else if (widget.sectionName == "Genital System") {
      actionName = "genital-system";
      return actionName;
    } else if (widget.sectionName == "Prenatal") {
      actionName = "prenatal";
      return actionName;
    } else if (widget.sectionName == "Infertility") {
      actionName = "infertility";
      return actionName;
    } else if (widget.sectionName == "Lymphatic System") {
      actionName = "lymphatic-system";
      return actionName;
    } else if (widget.sectionName == "Non Radiology Others") {
      actionName = "non-radiology-others";
      return actionName;
    } else if (widget.sectionName == "X-ray") {
      actionName = "xray";
      return actionName;
    } else if (widget.sectionName == "CT-Scan") {
      actionName = "ct-scan";
      return actionName;
    } else if (widget.sectionName == "MRI") {
      actionName = "mri";
      return actionName;
    } else if (widget.sectionName == "Ultrasound") {
      actionName = "ultrasound";
      return actionName;
    } else if (widget.sectionName == "IsotopeScan") {
      actionName = "isotope-scan";
      return actionName;
    } else if (widget.sectionName == "Radiology Others") {
      actionName = "radiology-others";
      return actionName;
    } else if (widget.sectionName == "heart Rate") {
      actionName = "rate";
      return actionName;
    } else if (widget.sectionName == "Respiratory Rate") {
      actionName = "rate";
      return actionName;
    } else if (widget.sectionName == "blood Pressure") {
      actionName = "pressure";
      return actionName;
    } else if (widget.sectionName == "Temperature") {
      actionName = "temperature";
      return actionName;
    } else if (widget.sectionName == "blood Sugar") {
      actionName = "sugar";
      return actionName;
    } else {
      actionName = "others";
      return actionName;
    }
  }

  void uploadDocument() async {
    // اختر المستند باستخدام مكتبة مثل file_picker
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      File document = File(result.files.single.path);
      setState(() {
        documents.add(document);
      });
    } else {
      // المستخدم لم يختار أي ملف
      print("No document selected");
    }
  }

  Future<void> pickImages() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarTitle: "Rounds",
        ),
      );
      setState(() {
        resultList.forEach((imageAsset) async {
          final filePath =
          await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
          File tempFile = File(filePath);
          if (tempFile.existsSync()) {
            images.add(tempFile);
          }
        });
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  uploadDailyRoundWithImages(
      context,
      action,
      date,
      heartRate,
      respiratatryRate,
      bloodPressure,
      bloodSugar,
      temperature,
      result,
      file,
      audio,
      video,
      resultFile,
      document) async {
    String videoName = video == null ? "" : video.path.split('/').last;
    String audioName = audio == null ? "" : audio.path.split('/').last;
    String imageName = file == null ? "" : file.path.split('/').last;
    String resultImageName =
    resultFile == null ? "" : resultFile.path.split('/').last;
    List<String> documentNames =
    documents.map((doc) => doc.path.split('/').last).toList();

    try {
      String videoUrl = "";
      String audioUrl = "";
      String imageUrl = "";
      String resultImageUrl = "";
      List<String> imageUrls = [];
      List<String> documentUrls = [];

      // Upload video files
      if (video != null) {
        firebase_storage.Reference videoRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('videos')
            .child(videoName);
        await videoRef.putFile(video);
        videoUrl = await videoRef.getDownloadURL();
      }

      // Upload audio files
      if (audio != null) {
        firebase_storage.Reference audioRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('audios')
            .child(audioName);
        await audioRef.putFile(audio);
        audioUrl = await audioRef.getDownloadURL();
      }

      // Upload image files
      if (file != null) {
        firebase_storage.Reference imageRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('images')
            .child(imageName);
        await imageRef.putFile(file);
        imageUrl = await imageRef.getDownloadURL();
      }

      // Upload result file
      if (resultFile != null) {
        firebase_storage.Reference resultImageRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('VitalSigns')
            .child(resultImageName);
        await resultImageRef.putFile(resultFile);
        resultImageUrl = await resultImageRef.getDownloadURL();
      }

      // رفع المستند
      for (var doc in documents) {
        String documentName = doc.path.split('/').last;
        firebase_storage.Reference documentRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('documents')
            .child(documentName);
        await documentRef.putFile(doc);
        String documentUrl = await documentRef.getDownloadURL();
        documentUrls.add(documentUrl);
      }

      // Upload attached images
      for (var image in images) {
        String imageFileName = image.path.split('/').last;
        firebase_storage.Reference imageRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('images')
            .child(imageFileName);
        await imageRef.putFile(image);
        String imageUrl = await imageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      if (widget.documentId == null) {
        // Create new document
        DocumentReference docRef =
        await FirebaseFirestore.instance.collection('vital_sign').add({
          "action": action,
          "key": 'os14042020ah',
          "heart_rate": heartRate,
          "respiratary_rate": respiratatryRate,
          "blood_pressure": bloodPressure,
          "blood_suger": bloodSugar,
          "temperature": temperature,
          "date": date,
          "others": result,
          "result_image": resultImageUrl,
          "report": "",
          "sick_id": widget.patient.id,
          "doctor_id": await DoctorID().readID(),
          "video": videoUrl,
          "audio": audioUrl,
          "documents": documentUrls, // Adding the list of document URLs
          "images": imageUrls, // Use the list of image URLs
          // Add other fields as needed
        });

        // Get the document ID and update the document with it
        String docId = docRef.id;
        await FirebaseFirestore.instance
            .collection('vital_sign')
            .doc(docId)
            .update({
          "documentId": docId, // Add the document ID to the document
        });
      } else {
        // Update existing document
        await FirebaseFirestore.instance
            .collection('vital_sign')
            .doc(widget.documentId) // Use the document ID to update the correct document
            .update({
          "action": action,
          "key": 'os14042020ah',
          "heart_rate": heartRate,
          "respiratary_rate": respiratatryRate,
          "blood_pressure": bloodPressure,
          "blood_suger": bloodSugar,
          "temperature": temperature,
          "date": date,
          "others": result,
          "result_image": resultImageUrl,
          "report": "",
          "sick_id": widget.patient.id,
          "doctor_id": await DoctorID().readID(),
          "video": videoUrl,
          "audio": audioUrl,
          "documents": documentUrls, // Adding the list of document URLs
          "images": imageUrls, // Use the list of image URLs
          // Add other fields as needed
        });
      }

      successMessage(context);
      setState(() {
        error = false;
      });
    } catch (e) {
      print("Exception Caught: $e");
      // Handle error message or other actions after completion
    }
  }

  editDailyRoundWithImages(context, action, title, date, result, normalValue,
      file, audio, video, resultFile) async {
    String videoName = _video == null ? "" : _video.path.split('/').last;
    String audioName = _audio == null ? "" : _audio.path.split('/').last;
    String image = file == null ? "" : file.path.split('/').last;
    String resultImage =
    resultFile == null ? "" : resultFile.path.split('/').last;
    try {
      // Uploading result file to Firebase Storage
      firebase_storage.Reference resultRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('vital_sign')
          .child(resultImage);
      await resultRef.putFile(resultFile);

      // Getting the download URL for the uploaded result file
      String resultImageUrl = await resultRef.getDownloadURL();

      // Uploading other files like images and videos similarly

      // Updating Firestore document in the "vital_sign" collection
      await FirebaseFirestore.instance
          .collection('vital_sign')
          .doc(widget.documentId) // Use the document ID to update the correct document
          .update({
        "action": action,
        "key": 'os14042020ah',
        "heart_rate": title,
        "date": date,
        "others": result,
        "normal_value": normalValue,
        "sick_id": widget.patient.id,
        "video": _video == null ? "" : videoName,
        "audio": _audio == null ? "" : audioName, // Update other fields as needed
        "result_image": resultImageUrl, // Add result image URL
        // Add other necessary fields here
      });

      // Handle success message or further actions
      successMessage(context);
      setState(() {
        error = false;
      });
    } catch (e) {
      print("Exception Caught: $e");
      // Handle error message or further actions
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // لمنع إغلاق الدايلوج بالنقر خارجه
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            'Please Wait',
            style: TextStyle(color: teal),
          ),
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

  DoctorSicks doc;

  successMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(color: teal),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(
        "Success",
        style: TextStyle(color: teal),
      ),
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
      child: Text(
        "OK",
        style: TextStyle(color: teal),
      ),
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

  errorMessage(BuildContext context, String msg) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        print(msg);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("ERROR"),
      content: Text(msg),
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

  ImageSource source;

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Choose option",
              style: TextStyle(color: Colors.blue),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      setState(() {
                        source = ImageSource.gallery;
                      });
                      Navigator.pop(context);
                      getImage(source);
                    },
                    title: Text("Gallery"),
                    leading: Icon(
                      Icons.account_box,
                      color: Colors.blue,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      setState(() {
                        source = ImageSource.camera;
                      });
                      Navigator.pop(context);
                      getImage(source);
                    },
                    title: Text("Camera"),
                    leading: Icon(
                      Icons.camera,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = image;
      images.add(_image);
    });
  }

  Future<void> _showChoiceDialogForResult(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Choose option",
              style: TextStyle(color: Colors.blue),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      setState(() {
                        source = ImageSource.gallery;
                      });
                      Navigator.pop(context);
                      getImageReuslt(source);
                    },
                    title: Text("Gallery"),
                    leading: Icon(
                      Icons.account_box,
                      color: Colors.blue,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      setState(() {
                        source = ImageSource.camera;
                      });
                      Navigator.pop(context);
                      getImageReuslt(source);
                    },
                    title: Text("Camera"),
                    leading: Icon(
                      Icons.camera,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future getImageReuslt(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    setState(() {
      _resultFile = image;
    });
  }

  Future video() async {
    FilePickerResult _pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    setState(() {
      _video = File(_pickedFile.files.single.path);
    });
  }

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

  /********speech*******/

  stt.SpeechToText _speech;
  bool _isListeningRay = false;
  bool _isListeningResult = false;
  bool _isListeningNormalValue = false;
  bool _isListeningBloodPressure = false;
  bool _isListeningBloodSugar = false;
  bool _isListeningTemperature = false;
  bool _isListeningOthers = false;

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



  /********** record *********/
  FlutterAudioRecorder _recorder;
  Recording _recording;

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
  void initState() {
    super.initState();
    titleConroler.text = widget.title;
    dateConroler.text = widget.date;
    resultConroler.text = widget.result;
    normalValueConroler.text =
    widget.normalValue == "NO" ? "NONormalValue" : widget.normalValue;
    heartRateController.text =
        widget.title; // Assuming heart rate is stored in the title
    respirataryRateController.text =
        widget.result; // Assuming respiratory rate is stored in the result
    bloodPressureController.text =
        widget.normalValue; // Assuming blood pressure is stored in the normal value
    bloodSugarController.text =
        widget.noResult; // Assuming blood sugar is stored in noResult
    temperatureController.text =
        widget.date; // Assuming temperature is stored in the date
    _speech = stt.SpeechToText();

    // تعيين مستمع لتغيرات الحالة
    _speech.statusListener = (status) {
      if (status == 'done' || status == 'notListening') {
        // إعادة الأيقونة واللون عند انتهاء الاستماع
        setState(() {
           _isListeningRay = false;
           _isListeningResult = false;
           _isListeningNormalValue = false;
           _isListeningBloodPressure = false;
           _isListeningBloodSugar = false;
           _isListeningTemperature = false;
           _isListeningOthers = false;
        });
      }
    };
  }

  Future<void> _checkFirstLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dontShowAgain = prefs.getBool('dontShowAgain') ?? false;
    if (firstLoad && !dontShowAgain) {
      Future.delayed(Duration.zero, () => _showInfoDialog(context));
      firstLoad = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == 0
            ? 'Add ${widget.sectionName}'
            : 'Edit ${widget.sectionName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
        elevation: 0,
      ),
      body: SizedBox(
        height: height,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: width * 0.8,
                            child: defaultTextFormField(
                              controller: heartRateController,
                              hintText: "Heart Rate",
                            ),
                          ),
                          CircleAvatar(
                            radius: (width - (width * 0.8)) / 4,
                            backgroundColor:
                            _isListeningRay ? Colors.red : teal,
                            child: IconButton(
                              icon: Icon(
                                _isListeningRay ? Icons.pause : Icons.mic_none_outlined,
                              ),
                              onPressed: () {
                                _listen(heartRateController, _isListeningRay)
                                    .then((value) {
                                  setState(() {
                                    _isListeningRay = value;
                                  });
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      widget.normalValue == "NO"
                          ? Container()
                          : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: width * 0.8,
                              child: defaultTextFormField(
                                controller:
                                respirataryRateController,
                                hintText: "Respiratory Rate",
                              ),
                            ),
                            CircleAvatar(
                              radius: (width - (width * 0.8)) / 4,
                              backgroundColor:
                              _isListeningNormalValue
                                  ? Colors.red
                                  : teal,
                              child: IconButton(
                                icon: Icon(
                                  _isListeningNormalValue
                                      ? Icons.pause
                                      : Icons.mic_none_outlined,
                                ),
                                onPressed: () {
                                  _listen(
                                      respirataryRateController,
                                      _isListeningNormalValue)
                                      .then((value) {
                                    setState(() {
                                      _isListeningNormalValue =
                                          value;
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Blood Pressure Field
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: width * 0.8,
                              child: defaultTextFormField(
                                controller: bloodPressureController,
                                hintText: "Blood Pressure",
                              ),
                            ),
                            CircleAvatar(
                              radius: (width - (width * 0.8)) / 4,
                              backgroundColor: _isListeningBloodPressure
                                  ? Colors.red
                                  : teal,
                              child: IconButton(
                                icon: Icon(
                                  _isListeningBloodPressure
                                      ? Icons.pause
                                      : Icons.mic_none_outlined,
                                ),
                                onPressed: () {
                                  _listen(
                                      bloodPressureController,
                                      _isListeningBloodPressure)
                                      .then((value) {
                                    setState(() {
                                      _isListeningBloodPressure =
                                          value;
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Blood Sugar Field
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: width * 0.8,
                              child: defaultTextFormField(
                                controller: bloodSugarController,
                                hintText: "Blood Sugar",
                              ),
                            ),
                            CircleAvatar(
                              radius: (width - (width * 0.8)) / 4,
                              backgroundColor: _isListeningBloodSugar
                                  ? Colors.red
                                  : teal,
                              child: IconButton(
                                icon: Icon(
                                  _isListeningBloodSugar
                                      ? Icons.pause
                                      : Icons.mic_none_outlined,
                                ),
                                onPressed: () {
                                  _listen(bloodSugarController,
                                      _isListeningBloodSugar)
                                      .then((value) {
                                    setState(() {
                                      _isListeningBloodSugar = value;
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Temperature Field
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: width * 0.8,
                              child: defaultTextFormField(
                                controller: temperatureController,
                                hintText: "Temperature",
                              ),
                            ),
                            CircleAvatar(
                              radius: (width - (width * 0.8)) / 4,
                              backgroundColor: _isListeningTemperature
                                  ? Colors.red
                                  : teal,
                              child: IconButton(
                                icon: Icon(
                                  _isListeningTemperature
                                      ? Icons.pause
                                      : Icons.mic_none_outlined,
                                ),
                                onPressed: () {
                                  _listen(temperatureController,
                                      _isListeningTemperature)
                                      .then((value) {
                                    setState(() {
                                      _isListeningTemperature =
                                          value;
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Others Field
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: width * 0.7,
                        child: defaultTextFormField(
                          controller: resultConroler,
                          hintText: "Others",
                        ),
                      ),
                      widget.noResult == "NoResult"
                          ? Container(
                        width: width * 0.1,
                      )
                          : IconButton(
                          onPressed: () {
                            _showChoiceDialogForResult(context);
                          },
                          icon: Icon(
                            Icons.add_a_photo_outlined,
                            color: deepBlue,
                          )),
                      CircleAvatar(
                          radius: (width - (width * 0.8)) / 4,
                          backgroundColor: _isListeningResult
                              ? Colors.red
                              : teal,
                          child: IconButton(
                            icon: Icon(
                              Icons.mic_none_outlined,
                            ),
                            onPressed: () {
                              _listen(resultConroler, _isListeningResult)
                                  .then((value) {
                                setState(() {
                                  _isListeningResult = value;
                                });
                              });
                            },
                          )),
                    ],
                  ),
                ),
                _resultFile == null
                    ? Container()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: width * 0.65,
                      child: Stack(
                        children: [
                          Image.file(_resultFile),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _resultFile = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: width * 0.65,
                        child: TextFormField(
                          readOnly: false, // Allow editing
                          controller: TextEditingController(
                            text: _audio == null ? "Record" : _audio.path,
                          ),
                          decoration: InputDecoration(
                            hintText: _audio == null ? "Record" : _audio.path,
                            hintStyle:
                            TextStyle(color: Colors.deepOrange), // Hint text color
                            filled: true,
                            fillColor: Colors.white, // Background color
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0), // Border radius
                              borderSide:
                              BorderSide(color: Colors.teal, width: 1.0), // Border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide:
                              BorderSide(color: Colors.teal, width: 1.0), // Border color when focused
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide:
                              BorderSide(color: Colors.teal, width: 1.0), // Border color when enabled
                            ),
                          ),
                          style: TextStyle(color: Colors.deepOrange), // Text color
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          getAudio();
                        },
                        icon: Icon(
                          Icons.library_music,
                          size: 28,
                          color: deepBlue,
                        ),
                      ),
                      CircleAvatar(
                        radius: (width - (width * 0.8)) / 4,
                        backgroundColor:
                        isRecord ? Colors.deepOrangeAccent : teal,
                        child: IconButton(
                          icon: isRecord
                              ? Icon(Icons.stop)
                              : Icon(Icons.mic_rounded),
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
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          pickImages();
                        },
                        label: Text(
                          "Image",
                          style: TextStyle(color: orange, fontSize: 15),
                        ),
                        icon: Icon(
                          Icons.camera_enhance_rounded,
                          size: 28,
                          color: teal,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          video();
                        },
                        label: Text("Video",
                            style: TextStyle(color: orange, fontSize: 15)),
                        icon: Icon(
                          Icons.video_call,
                          size: 28,
                          color: teal,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          uploadDocument();
                        },
                        label: Text("Document",
                            style: TextStyle(color: orange, fontSize: 15)),
                        icon: Icon(
                          Icons.attach_file,
                          size: 28,
                          color: teal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
                  child: images.isEmpty
                      ? Container()
                      : Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0)),
                    height: height * 0.3,
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: List.generate(images.length, (index) {
                        return Center(
                          child: Stack(
                            children: [
                              Image.file(images[index],
                                  height: height * 0.2),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      images.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
                  child: _video == null
                      ? Container()
                      : Stack(
                    children: [
                      VideoItems(
                        videoPlayerController:
                        VideoPlayerController.file(_video),
                        looping: false,
                        autoplay: true,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _video = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
                  child: documents.isEmpty
                      ? Container()
                      : Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0)),
                    height: height * 0.2,
                    child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.insert_drive_file),
                          title: Text(documents[index]
                              .path
                              .split('/')
                              .last),
                          trailing: IconButton(
                            icon:
                            Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                documents.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                myButton(
                  width: width,
                  onPressed: () async {
                    check().then((internet) {
                      if (internet != null && internet) {
                        // Internet Present Case
                        setState(() {
                          isLoading = true;
                        });
                        showLoadingDialog(context);

                        uploadDailyRoundWithImages(
                          context,
                          getActionName(),
                          dateConroler.text,
                          heartRateController.text,
                          respirataryRateController.text,
                          bloodPressureController.text,
                          bloodSugarController.text,
                          temperatureController.text,
                          resultConroler.text,
                          _image,
                          _audio,
                          _video,
                          _resultFile,
                          documents,
                        ).then((_) {
                          setState(() {
                            isLoading = false;
                          });
                        });
                      }
                    });
                  },
                  text: widget.index == 0 ? 'Add' : 'Edit',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
