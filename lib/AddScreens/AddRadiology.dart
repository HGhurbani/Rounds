import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:rounds/Screens/ProfileScreen.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rounds/component.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../VideoItems.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../colors.dart';

class AddRadiologyScreen extends StatefulWidget {
  final String id;
  final String sectionName;
  final DoctorSicks patient;
  final String patientId;
  final String title;
  final String date;
  final String result;
  final String normalValue;
  final String NonormalValue;
  final int index;
  final String noResult;
  final List<String> videos;
  final List<String> images;
  final List<String> documents;

  AddRadiologyScreen(
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
      this.videos,
      this.images,
      this.documents,
      [this.NonormalValue]);

  @override
  _AddRadiologyScreen createState() => _AddRadiologyScreen();
}

class _AddRadiologyScreen extends State<AddRadiologyScreen> {
  bool isLoading = false;
  bool firstLoad = true;
  String _audioFilePath; // مكان تخزين الصوت محلياً
  File _audioFile; // الملف المسجل
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final resultController = TextEditingController();
  final normalValueController = TextEditingController();
  final recordController = TextEditingController();

  String actionName = '';
  String action = '';
  bool error = false;
  List<File> _videos = [];
  List<File> _audios = [];
  List<File> _images = [];
  List<File> _documents = [];
  List<File> resultImages = []; // لإضافة صور النتيجة

  stt.SpeechToText _speech;
  bool _isListeningRay = false;
  bool _isListeningResult = false;
  bool _isListeningNormalValue = false;

  FlutterAudioRecorder _recorder;
  Recording _recording;
  bool isRecord = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title; // تعيين النص الأولي للعنوان
    dateController.text = widget.date; // تعيين النص الأولي للتاريخ
    resultController.text = widget.result; // تعيين النص الأولي للنتيجة
    normalValueController.text = widget.NonormalValue == "NO" ? "NONormalValue" : widget.normalValue; // تعيين القيمة الطبيعية
    _speech = stt.SpeechToText(); // تهيئة مكتبة تحويل الصوت إلى نص
    _checkFirstLoad(); // التحقق من التحميل الأول
    if (widget.index != 0) {
      _isListeningNormalValue = false;
      _isListeningResult = false;
      _loadExistingFiles(); // تحميل الملفات الموجودة في حال عدم كون الفهرس صفراً
    }

    // تعيين مستمع لتغيرات حالة الاستماع
    _speech.statusListener = (val) {
      print('onStatus: $val');
      if (val == 'done' || val == 'notListening') {
        // إذا انتهى الاستماع، إعادة تعيين الحالة
        setState(() {
          _isListeningNormalValue = false;
          _isListeningResult = false;
          _isListeningRay = false; // إعادة تعيين حالة الاستماع إلى "false"
        });
      }
    };

    // تعيين مستمع للأخطاء أثناء الاستماع
    _speech.errorListener = (val) {
      print('onError: $val');
      // إذا حدث خطأ، إعادة تعيين الحالة
      setState(() {
        _isListeningRay = false; // إعادة تعيين حالة الاستماع إلى "false"
      });
    };
  }

  Future<void> _loadExistingFiles() async {
    // تحميل البيانات الحالية وعرضها في الواجهة
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('laboratory')
        .doc(widget.index.toString())
        .get();
    if (document.exists) {
      Map<String, dynamic> data = document.data();
      setState(() {
        widget.videos.addAll(List<String>.from(data['videos']));
        widget.images.addAll(List<String>.from(data['images']));
        widget.documents.addAll(List<String>.from(data['documents']));
      });
    }
  }

  Future<void> _checkFirstLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dontShowAgain = prefs.getBool('dontShowAgain') ?? false;
    if (firstLoad && !dontShowAgain) {
      Future.delayed(Duration.zero, () => _showInfoDialog(context));
      firstLoad = false;
    }
  }

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

  // عرض Dialog لبدء التسجيل
  void showRecordingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Audio Recording"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isRecord
                      ? Text("Recording Start Talk...")
                      : (_audioFile != null
                      ? Column(
                    children: [
                      Text("Recording finished. You can Upload or re-record."),
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          // تمرير المسار الصحيح لتشغيل الصوت
                          _playRecordedAudio(_audioFilePath);
                        },
                      ),
                    ],
                  )
                      : Text("Press the icon below to start recording.")),
                ],
              ),
              actions: [
                if (_audioFile == null)
                  IconButton(
                    icon: Icon(isRecord ? Icons.stop : Icons.mic),
                    onPressed: () {
                      if (isRecord) {
                        stopRecording().then((_) {
                          setState(() {}); // تحديث حالة العرض
                        });
                      } else {
                        startRecording().then((_) {
                          setState(() {}); // بدء التسجيل
                        });
                      }
                    },
                  ),
                if (_audioFile != null)
                  IconButton(
                    icon: Icon(Icons.replay),
                    onPressed: () {
                      setState(() {
                        _audioFile = null; // حذف التسجيل وإعادة التسجيل
                      });
                      startRecording();
                    },
                  ),
                if (_audioFile != null)
                  IconButton(
                    icon: Icon(Icons.upload),
                    onPressed: () async {
                      Navigator.pop(context); // إغلاق الـ Dialog
                      String audioUrl = await uploadAudioFile(_audioFile);
                      setState(() {
                        recordController.text = audioUrl; // تحديث الرابط في الـ TextField
                      });
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
  // دالة رفع التسجيل
  Future<String> uploadAudioFile(File audioFile) async {
    try {
      String audioName = audioFile.path.split('/').last;
      firebase_storage.Reference audioRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('audios')
          .child(audioName);

      await audioRef.putFile(audioFile); // رفع الملف إلى Firebase
      String audioUrl = await audioRef.getDownloadURL(); // الحصول على رابط الملف
      return audioUrl;
    } catch (e) {
      print("Error uploading audio: $e");
      return null;
    }
  }
  AudioPlayer _audioPlayer = AudioPlayer();
// دالة لتشغيل الصوت المسجل
  void _playRecordedAudio(String filePath) async {
    if (filePath != null && filePath.isNotEmpty) {
      Uri fileUri = Uri.file(filePath);
      print('Playing audio from: $fileUri');
      int result = await _audioPlayer.play(fileUri.toString(), isLocal: true);
      if (result == 1) {
        print('Audio is playing');
      } else {
        print('Error playing audio');
      }
    } else {
      print('File path is empty or null');
    }
  }

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

  String getAction() {
    switch (widget.sectionName) {
      case "Nervous System":
      case "Skin":
      case "Eye":
      case "Musculoskeletal System":
      case "Cardiovascular System":
      case "Blood":
      case "Digestive System":
      case "Genital System":
      case "Prenatal":
      case "Infertility":
      case "Lymphatic System":
      case "Non Radiology Others":
        action = "NonRadiology";
        break;
      default:
        action = "Laboratory";
    }
    return action;
  }

  String getActionName() {
    switch (widget.sectionName) {
      case "Hematology":
        actionName = "add-laboratory-hematology";
        break;
      case "Chemistry":
        actionName = "add-laboratory-chemistry";
        break;
      case "Microbiology":
        actionName = "add-laboratory-microbiology";
        break;
      case "Histopathology":
        actionName = "add-laboratory-histopathology";
        break;
      case "Laboratory Others":
        actionName = "add-laboratory-others";
        break;
      case "Nervous System":
        actionName = "add-non-radiology-nervous-system";
        break;
      case "Skin":
        actionName = "add-non-radiology-skin";
        break;
      case "Eye":
        actionName = "add-non-radiology-eye";
        break;
      case "Musculoskeletal System":
        actionName = "add-non-radiology-musculoskeletal-system";
        break;
      case "Cardiovascular System":
        actionName = "add-non-radiology-cardiovascular-system";
        break;
      case "Blood":
        actionName = "add-non-radiology-blood";
        break;
      case "Digestive System":
        actionName = "add-non-radiology-digestive-system";
        break;
      case "Genital System":
        actionName = "add-non-radiology-genital-system";
        break;
      case "Prenatal":
        actionName = "add-non-radiology-prenatal";
        break;
      case "Infertility":
        actionName = "add-non-radiology-infertility";
        break;
      case "Lymphatic System":
        actionName = "add-non-radiology-lymphatic-system";
        break;
      case "Non Radiology Others":
        actionName = "add-non-radiology-others";
        break;
      case "X-ray":
        actionName = "add-radiology-xray";
        break;
      case "CT-Scan":
        actionName = "add-radiology-ct-scan";
        break;
      case "MRI":
        actionName = "add-radiology-mri";
        break;
      case "Ultrasound":
        actionName = "add-radiology-ultrasound";
        break;
      case "IsotopeScan":
        actionName = "add-radiology-isotope-scan";
        break;
      case "Radiology Others":
        actionName = "add-radiology-others";
        break;
      case "heart Rate":
        actionName = "add-vital-signs-heart-rate";
        break;
      case "Respiratory Rate":
        actionName = "add-vital-signs-respiratory-rate";
        break;
      case "blood Pressure":
        actionName = "add-vital-signs-blood-pressure";
        break;
      case "Temperature":
        actionName = "add-vital-signs-temperature";
        break;
      case "blood Sugar":
        actionName = "add-vital-signs-blood-sugar";
        break;
      default:
        actionName = "add-vital-signs-others";
    }
    return actionName;
  }

  String getEditActionName() {
    switch (widget.sectionName) {
      case "Hematology":
        actionName = "hematology";
        break;
      case "Chemistry":
        actionName = "chemistry";
        break;
      case "Microbiology":
        actionName = "microbiology";
        break;
      case "Histopathology":
        actionName = "histopathology";
        break;
      case "Laboratory Others":
        actionName = "laboratory-others";
        break;
      case "Nervous System":
        actionName = "nervous-system";
        break;
      case "Skin":
        actionName = "skin";
        break;
      case "Eye":
        actionName = "eye";
        break;
      case "Musculoskeletal System":
        actionName = "musculoskeletal-system";
        break;
      case "Cardiovascular System":
        actionName = "cardiovascular-system";
        break;
      case "Blood":
        actionName = "blood";
        break;
      case "Digestive System":
        actionName = "digestive-system";
        break;
      case "Genital System":
        actionName = "genital-system";
        break;
      case "Prenatal":
        actionName = "prenatal";
        break;
      case "Infertility":
        actionName = "infertility";
        break;
      case "Lymphatic System":
        actionName = "lymphatic-system";
        break;
      case "Non Radiology Others":
        actionName = "non-radiology-others";
        break;
      case "X-ray":
        actionName = "xray";
        break;
      case "CT-Scan":
        actionName = "ct-scan";
        break;
      case "MRI":
        actionName = "mri";
        break;
      case "Ultrasound":
        actionName = "ultrasound";
        break;
      case "IsotopeScan":
        actionName = "isotope-scan";
        break;
      case "Radiology Others":
        actionName = "radiology-others";
        break;
      case "heart Rate":
      case "Respiratory Rate":
        actionName = "rate";
        break;
      case "blood Pressure":
        actionName = "pressure";
        break;
      case "Temperature":
        actionName = "temperature";
        break;
      case "blood Sugar":
        actionName = "sugar";
        break;
      default:
        actionName = "others";
    }
    return actionName;
  }

  void uploadDocuments() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      allowMultiple: true,
    );

    if (result != null) {
      for (var file in result.files) {
        File document = File(file.path);
        _documents.add(document);

        String documentName = document.path.split('/').last;
        firebase_storage.Reference documentRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('documents')
            .child(documentName);

        try {
          await documentRef.putFile(document);
          String documentUrl = await documentRef.getDownloadURL();
          print("Document uploaded successfully: $documentUrl");
        } catch (e) {
          print("Failed to upload document: $e");
        }
      }
    } else {
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
            _images.add(tempFile);
          }
        });
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> getImageReuslt() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300, // يمكنك تحديد العدد الأقصى من الصور
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarTitle: "Pick Result Images",
          allViewTitle: "All Photos",
          selectCircleStrokeColor: "#000000",
        ),
      );
      setState(() {
        for (var imageAsset in resultList) {
          // تحويل الصور إلى ملفات لرفعها لاحقاً
          FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier).then((filePath) {
            File tempFile = File(filePath);
            if (tempFile.existsSync()) {
              resultImages.add(tempFile);
            }
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadDailyRoundWithFiles(context, action, title, date, result, normalValue) async {
    try {
      List<String> videoUrls = [];
      List<String> audioUrls = [];
      List<String> imageUrls = [];
      List<String> documentUrls = [];
      List<String> resultImageUrls = [];  // إضافة روابط صور result

      for (var video in _videos) {
        String videoName = video.path.split('/').last;
        firebase_storage.Reference videoRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('videos')
            .child(videoName);
        await videoRef.putFile(video);
        String videoUrl = await videoRef.getDownloadURL();
        videoUrls.add(videoUrl);
      }

      for (var audio in _audios) {
        String audioName = audio.path.split('/').last;
        firebase_storage.Reference audioRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('audios')
            .child(audioName);
        await audioRef.putFile(audio);
        String audioUrl = await audioRef.getDownloadURL();
        audioUrls.add(audioUrl);
      }

      for (var image in _images) {
        String imageName = image.path.split('/').last;
        firebase_storage.Reference imageRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('images')
            .child(imageName);
        await imageRef.putFile(image);
        String imageUrl = await imageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // رفع الصور الجديدة الخاصة بـ result
      for (var image in resultImages) {
        String imageName = image.path.split('/').last;
        firebase_storage.Reference imageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('result-images')
            .child(imageName);
        await imageRef.putFile(image);
        String imageUrl = await imageRef.getDownloadURL();
        resultImageUrls.add(imageUrl);
      }

      for (var document in _documents) {
        String documentName = document.path.split('/').last;
        firebase_storage.Reference documentRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('documents')
            .child(documentName);
        await documentRef.putFile(document);
        String documentUrl = await documentRef.getDownloadURL();
        documentUrls.add(documentUrl);
      }

      await FirebaseFirestore.instance.collection('radiology').add({
        "action": action,
        "key": 'os14042020ah',
        "title": title,
        "date": date,
        "result": result,
        "normal_value": normalValue,
        "sick_id": widget.patient.id,
        "doctor_id": await DoctorID().readID(),
        "videos": videoUrls,
        "audios": audioUrls,
        "images": imageUrls,
        "documents": documentUrls,
        "result_images": resultImageUrls,  // إضافة روابط صور result
      });

      successMessage(context);
      setState(() {
        error = false;
      });
    } catch (e) {
      print("Exception Caught: $e");
    }
  }

  Future<void> editDailyRoundWithFiles(context, title, date, result, normalValue) async {
    try {
      List<String> videoUrls = [];
      List<String> audioUrls = [];
      List<String> imageUrls = [];
      List<String> documentUrls = [];
      List<String> resultImageUrls = [];  // إضافة روابط صور result

      for (var video in _videos) {
        String videoName = video.path.split('/').last;
        firebase_storage.Reference videoRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('videos')
            .child(videoName);
        await videoRef.putFile(video);
        String videoUrl = await videoRef.getDownloadURL();
        videoUrls.add(videoUrl);
      }

      for (var audio in _audios) {
        String audioName = audio.path.split('/').last;
        firebase_storage.Reference audioRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('audios')
            .child(audioName);
        await audioRef.putFile(audio);
        String audioUrl = await audioRef.getDownloadURL();
        audioUrls.add(audioUrl);
      }

      for (var image in _images) {
        String imageName = image.path.split('/').last;
        firebase_storage.Reference imageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('images')
            .child(imageName);
        await imageRef.putFile(image);
        String imageUrl = await imageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      for (var document in _documents) {
        String documentName = document.path.split('/').last;
        firebase_storage.Reference documentRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('documents')
            .child(documentName);
        await documentRef.putFile(document);
        String documentUrl = await documentRef.getDownloadURL();
        documentUrls.add(documentUrl);
      }

      // رفع الصور الجديدة الخاصة بـ result
      for (var image in resultImages) {
        String imageName = image.path.split('/').last;
        firebase_storage.Reference imageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('result-images')
            .child(imageName);
        await imageRef.putFile(image);
        String imageUrl = await imageRef.getDownloadURL();
        resultImageUrls.add(imageUrl);
      }

      await FirebaseFirestore.instance.collection('radiology').doc(widget.id.toString()).update({
        // "action": actionName,
        "key": 'os14042020ah',
        "title": title,
        "date": date,
        "result": result,
        "normal_value": normalValue,
        "sick_id": widget.patient.id,
        "doctor_id": await DoctorID().readID(),
        "videos": videoUrls,
        "audios": audioUrls,
        "images": imageUrls,
        "documents": documentUrls,
        "result_images": resultImageUrls,  // إضافة روابط صور result
      });

      successMessage(context);
      setState(() {
        error = false;
      });
    } catch (e) {
      print("Exception Caught: $e");
    }
  }

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
      _audios.add(File(_recording.path));
      recordController.text = _recording.path;
    });
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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

  successMessage(BuildContext context) {
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  internetMessage(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(color: teal),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Connection Error"),
      content: Text("please check your internet connection"),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  errorMessage(BuildContext context, String msg) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        print(msg);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("ERROR"),
      content: Text(msg),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
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
  Widget _buildAudioList() {
    return Container(
      height: 150,
      child: _audios.isEmpty
          ? Center(
        child: Text(
          'No audios selected',  // الرسالة التي تظهر عند عدم وجود ملفات صوتية
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        itemCount: _audios.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_audios[index].path.split('/').last),  // عرض اسم الملف الصوتي
            trailing: IconButton(
              icon: Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                setState(() {
                  _audios.removeAt(index);  // حذف الملف الصوتي
                });
              },
            ),
          );
        },
      ),
    );
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    setState(() {
      _images.add(image);
    });
  }


  Future video() async {
    FilePickerResult _pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    setState(() {
      _pickedFile.files.forEach((file) {
        _videos.add(File(file.path));
      });
    });
  }

  Future getAudio() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', '3gpp', '3gp'],
      allowMultiple: true,
    );
    setState(() {
      result.files.forEach((file) {
        _audios.add(File(file.path));
      });
    });
  }
  Widget _buildImagesList(double height) {
    final totalImages = widget.images.length + _images.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.0),
      ),
      height: height * 0.15,
      child: totalImages == 0
          ? Center(
        child: Text(
          'No images selected',  // الرسالة التي تظهر عند عدم وجود صور
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
        ),
      )
          : GridView.count(
        crossAxisCount: 4,
        children: List.generate(totalImages, (index) {
          return Stack(
            children: [
              Center(
                child: index < widget.images.length
                    ? Image.network(
                  widget.images[index],
                  height: height * 0.2,
                ) // عرض الصور المحفوظة من الروابط
                    : Image.file(
                  _images[index - widget.images.length],
                  height: height * 0.2,
                ), // عرض الصور الجديدة
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (index < widget.images.length) {
                        widget.images.removeAt(index); // حذف الروابط من القائمة
                      } else {
                        _images.removeAt(index - widget.images.length); // حذف الملفات الجديدة
                      }
                    });
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }


  Widget _buildResultImagesList(double height) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.0),
      ),
      height: height * 0.15,
      child: resultImages.isEmpty
          ? Center(
        child: Text(
          'No images selected for result',  // الرسالة التي تظهر عند عدم وجود صور
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
        ),
      )
          : GridView.count(
        crossAxisCount: 4,
        children: List.generate(resultImages.length, (index) {
          return Stack(
            children: [
              Center(
                child: Image.file(resultImages[index], height: height * 0.2),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      resultImages.removeAt(index); // حذف الصورة من القائمة
                    });
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }


  Widget _buildVideosList(double height) {
    final totalVideos = widget.videos.length + _videos.length;

    return Container(
      height: height * 0.2,
      child: totalVideos == 0
          ? Center(
        child: Text(
          'No videos selected',  // الرسالة التي تظهر عند عدم وجود فيديوهات
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalVideos,
        itemBuilder: (context, index) {
          if (index < widget.videos.length) {
            final videoUrl = widget.videos[index];
            final videoController = VideoPlayerController.network(videoUrl);

            return Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(8.0),
                  width: 150,
                  child: AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    child: VideoPlayer(videoController),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        widget.videos.removeAt(index);  // حذف روابط الفيديو
                      });
                    },
                  ),
                ),
              ],
            );
          } else {
            final videoFile = _videos[index - widget.videos.length];
            final videoController = VideoPlayerController.file(videoFile);

            return Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(8.0),
                  width: 150,
                  child: AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    child: VideoPlayer(videoController),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _videos.removeAt(index - widget.videos.length);  // حذف الفيديوهات الجديدة
                      });
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }


  Widget _buildDocumentsList() {
    final totalDocuments = widget.documents.length + _documents.length;

    return Container(
      child: totalDocuments == 0
          ? Center(
        child: Text(
          'No documents selected',  // الرسالة التي تظهر عند عدم وجود مستندات
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
        ),
      )
          : Column(
        children: List.generate(totalDocuments, (index) {
          return ListTile(
            title: Text(
              index < widget.documents.length
                  ? widget.documents[index].split('/').last  // عرض اسم المستند من الروابط
                  : _documents[index - widget.documents.length].path.split('/').last,  // عرض اسم المستندات الجديدة
            ),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                setState(() {
                  if (index < widget.documents.length) {
                    widget.documents.removeAt(index);  // حذف روابط المستندات
                  } else {
                    _documents.removeAt(index - widget.documents.length);  // حذف المستندات الجديدة
                  }
                });
              },
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == 0
            ? 'Add ${widget.sectionName}'
            : 'Edit'),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: width * 0.8,
                        child: defaultTextFormField(
                          controller: titleController,
                          hintText: getAction() == "NonRadiology"
                              ? "Examination Request"
                              : widget.sectionName == "X-ray"
                              ? "Requested Image"
                              : "Test Name",
                        ),
                      ),
                      CircleAvatar(
                          radius: (width - (width * 0.8)) / 4,
                          backgroundColor: _isListeningRay ? Colors.red : teal,
                          child: IconButton(
                            icon: Icon(
                              _isListeningRay ? Icons.pause : Icons.mic_none_outlined,
                            ),
                            onPressed: () {
                              _listen(titleController, _isListeningRay)
                                  .then((value) {
                                setState(() {
                                  _isListeningRay = value;
                                });
                              });
                            },
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, right: 8.0, bottom: 8.0, left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: width * 0.8,
                        child: defaultTextFormField(
                          controller: dateController,
                          hintText: dateController.text.isEmpty
                              ? "Date"
                              : dateController.text,
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
                                dateController.text =
                                    date.toString().substring(0, 10);
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
                widget.NonormalValue == "NO"
                    ? Container()
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: width * 0.8,
                        child: defaultTextFormField(
                            controller: normalValueController,
                            hintText: getAction() == "NonRadiology"
                                ? "Findings"
                                : widget.sectionName == "X-ray"
                                ? "Report"
                                : "Normal Value"),
                      ),
                      CircleAvatar(
                          radius: (width - (width * 0.8)) / 4,
                          backgroundColor:
                          _isListeningNormalValue ? Colors.red : teal,
                          child: IconButton(
                            icon: Icon(
                              _isListeningNormalValue ? Icons.pause : Icons.mic_none_outlined,
                            ),
                            onPressed: () {
                              _listen(normalValueController,
                                  _isListeningNormalValue)
                                  .then((value) {
                                setState(() {
                                  _isListeningNormalValue = value;
                                });
                              });
                            },
                          ))
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
                          controller: resultController,
                          hintText: "Result",
                        ),
                      ),
                      widget.noResult == "NoResult"
                          ? Container(
                        width: width * 0.1,
                      )
                          : IconButton(
                          onPressed: () {
                            getImageReuslt();  // دالة لاختيار صور result
                          },
                          icon: Icon(
                            Icons.add_a_photo_outlined,
                            color: deepBlue,
                          )),
                      CircleAvatar(
                          radius: (width - (width * 0.8)) / 4,
                          backgroundColor:
                          _isListeningResult ? Colors.red : teal,
                          child: IconButton(
                            icon: Icon(
                              _isListeningResult ? Icons.pause : Icons.mic_none_outlined,
                            ),
                            onPressed: () {
                              _listen(resultController, _isListeningResult)
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
                _buildResultImagesList(height),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: width * 0.7,
                        child: defaultTextFormField(
                          controller: recordController,
                          hintText: _recording == null ? "Record" : _recording.path,
                          read: false,
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
                        backgroundColor: isRecord ? Colors.deepOrangeAccent : teal,
                        child: IconButton(
                          icon: isRecord ? Icon(Icons.stop) : Icon(Icons.mic_rounded),
                          onPressed: () {
                            showRecordingDialog(context); // عرض الـ Dialog الجديد لبدء التسجيل
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAudioList(),

                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                          uploadDocuments();
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
                 _buildImagesList(height),
                _buildVideosList(height),
                 _buildDocumentsList(),
                myButton(
                  width: width,
                  onPressed: () async {
                    check().then((intenet) {
                      if (intenet != null && intenet) {
                        setState(() {
                          isLoading = true;
                        });
                        showLoadingDialog(context);

                        setState(() {
                          isLoading = false;
                        });
                        widget.index == 0
                            ? uploadDailyRoundWithFiles(
                            context,
                            getActionName(),
                            titleController.text,
                            dateController.text,
                            resultController.text,
                            normalValueController.text)
                            : editDailyRoundWithFiles(
                          context,
                          titleController.text,
                          dateController.text,
                          resultController.text,
                          normalValueController.text,
                        );
                      }
                    });
                  },
                  text: error ? 'Uploading' : (widget.index == 0 ? 'Add' : 'Edit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
