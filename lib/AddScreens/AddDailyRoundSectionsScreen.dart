import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:video_player/video_player.dart';
import '../colors.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:rounds/component.dart';

class AddDailyRoundSectionsScreen extends StatefulWidget {
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

  AddDailyRoundSectionsScreen(
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
  _AddDailyRoundSectionsScreen createState() => _AddDailyRoundSectionsScreen();
}

class _AddDailyRoundSectionsScreen extends State<AddDailyRoundSectionsScreen> {
  bool isLoading = false;
  bool firstLoad = true;
  String _audioFilePath;
  File _audioFile;
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final resultController = TextEditingController();
  final normalValueController = TextEditingController();
  final recordController = TextEditingController();

  List<File> _videos = [];
  List<File> _audios = [];
  List<File> _images = [];
  List<File> _documents = [];
  List<File> resultImages = [];

  FlutterAudioRecorder _recorder;
  Recording _recording;
  bool isRecord = false;

  stt.SpeechToText _speech;
  bool _isListeningRay = false;
  bool _isListeningResult = false;
  bool _isListeningNormalValue = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    dateController.text = widget.date;
    resultController.text = widget.result;
    normalValueController.text =
    widget.NonormalValue == "NO" ? "NONormalValue" : widget.normalValue;
    _speech = stt.SpeechToText();
    _checkFirstLoad();

    if (widget.index != 0) {
      _isListeningNormalValue = false;
      _isListeningResult = false;
      _loadExistingFiles();
    }

    _speech.statusListener = (val) {
      if (val == 'done' || val == 'notListening') {
        setState(() {
          _isListeningNormalValue = false;
          _isListeningResult = false;
          _isListeningRay = false;
        });
      }
    };

    _speech.errorListener = (val) {
      setState(() {
        _isListeningRay = false;
      });
    };
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
        return "Laboratory";
      default:
        return "laboratory";
    }
  }

  String getActionName() {
    switch (widget.sectionName) {
      case "Hematology":
        return "add-laboratory-hematology";
      case "Chemistry":
        return "add-laboratory-chemistry";
      case "Microbiology":
        return "add-laboratory-microbiology";
      case "Histopathology":
        return "add-laboratory-histopathology";
      case "Laboratory Others":
        return "add-laboratory-others";
      case "Nervous System":
        return "add-non-radiology-nervous-system";
      case "Skin":
        return "add-non-radiology-skin";
      case "Eye":
        return "add-non-radiology-eye";
      case "Musculoskeletal System":
        return "add-non-radiology-musculoskeletal-system";
      case "Cardiovascular System":
        return "add-non-radiology-cardiovascular-system";
      case "Blood":
        return "add-non-radiology-blood";
      case "Digestive System":
        return "add-non-radiology-digestive-system";
      case "Genital System":
        return "add-non-radiology-genital-system";
      case "Prenatal":
        return "add-non-radiology-prenatal";
      case "Infertility":
        return "add-non-radiology-infertility";
      case "Lymphatic System":
        return "add-non-radiology-lymphatic-system";
      case "Non Radiology Others":
        return "add-non-radiology-others";
      case "X-ray":
        return "add-radiology-xray";
      case "CT-Scan":
        return "add-radiology-ct-scan";
      case "MRI":
        return "add-radiology-mri";
      case "Ultrasound":
        return "add-radiology-ultrasound";
      case "IsotopeScan":
        return "add-radiology-isotope-scan";
      case "Radiology Others":
        return "add-radiology-others";
      case "heart Rate":
        return "add-vital-signs-heart-rate";
      case "Respiratory Rate":
        return "add-vital-signs-respiratory-rate";
      case "blood Pressure":
        return "add-vital-signs-blood-pressure";
      case "Temperature":
        return "add-vital-signs-temperature";
      case "blood Sugar":
        return "add-vital-signs-blood-sugar";
      default:
        return "add-vital-signs-others";
    }
  }

  Future<void> _loadExistingFiles() async {
    try {
      // محاولة جلب البيانات من Firebase
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('laboratory')
          .doc(widget.id) // استخدم ID الفحص لتمييز كل فحص عن الآخر
          .get();

      if (document.exists) {
        // استرجاع البيانات من المستند
        Map<String, dynamic> data = document.data();

        setState(() {
          widget.videos.clear();
          widget.images.clear();
          widget.documents.clear();

          widget.videos.addAll(List<String>.from(data['videos']));
          widget.images.addAll(List<String>.from(data['images']));
          widget.documents.addAll(List<String>.from(data['documents']));

          // إضافة البيانات المحملة إلى الحقول الخاصة بها
          titleController.text = data['title'] ?? widget.title;
          dateController.text = data['date'] ?? widget.date;
          resultController.text = data['result'] ?? widget.result;
          normalValueController.text = data['normal_value'] ?? widget.normalValue;
        });
      } else {
        print("No data found for the document.");
      }
    } catch (e) {
      print("Error loading data: $e");
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            'Instructions',
            style: TextStyle(fontWeight: FontWeight.bold, color: teal),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To use the microphone for input, press the microphone icon next to the text field. '
                    'Speak clearly into your device\'s microphone. The text will be added to the current content of the field. '
                    'Press the microphone icon again to stop listening.',
              ),
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
              child: Text('OK', style: TextStyle(color: teal)),
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

  Future<bool> _listen(TextEditingController controller, bool isListening) async {
    if (!isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => isListening = true);
        String originalText = controller.text;
        List<String> lastWords = [];

        _speech.listen(
          onResult: (val) => setState(() {
            String currentRecognizedWords = val.recognizedWords.trim();
            List<String> currentWords = currentRecognizedWords.split(' ');

            List<String> newWords =
            currentWords.where((word) => !lastWords.contains(word)).toList();

            if (newWords.isNotEmpty) {
              controller.text =
                  originalText + (originalText.isEmpty ? "" : " ") + newWords.join(' ');
              originalText = controller.text;
              lastWords.addAll(newWords);
            }
          }),
          partialResults: true,
        );
      }
    } else {
      setState(() => isListening = false);
      _speech.stop();
    }
    return isListening;
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

  Future<void> uploadDocuments() async {
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

  Future<void> getImageReuslt() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarTitle: "Pick Result Images",
          allViewTitle: "All Photos",
          selectCircleStrokeColor: "#000000",
        ),
      );
      setState(() {
        for (var imageAsset in resultList) {
          FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier)
              .then((filePath) {
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

  Future<void> video() async {
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

  Future<void> getAudio() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', '3gpp', '3gp', 'wav'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        result.files.forEach((file) {
          _audios.add(File(file.path));
        });
      });
    }
  }

  Future<List<String>> _loadImages() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('laboratory')
          .doc(widget.id) // استخدام الـ ID الخاص بالعنصر
          .get();

      if (document.exists) {
        Map<String, dynamic> data = document.data();
        List<String> images = List<String>.from(data['images']);
        return images;
      } else {
        return [];
      }
    } catch (e) {
      print("Error loading images: $e");
      return [];
    }
  }

  Widget _buildImageList() {
    return FutureBuilder<List<String>>(
      future: _loadImages(), // استدعاء الدالة التي تقوم بتحميل الصور
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // عرض مؤشر تحميل أثناء انتظار البيانات
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // عرض رسالة في حال حدوث خطأ
          return Center(child: Text('Error loading images'));
        } else if (!snapshot.hasData || snapshot.data.isEmpty) {
          // عرض رسالة في حال عدم وجود صور
          return Center(child: Text('No images available'));
        } else {
          // عرض الصور بعد تحميلها
          return GridView.count(
            crossAxisCount: 4,
            children: List.generate(snapshot.data.length, (index) {
              return Stack(
                children: [
                  Center(
                    child: Image.network(snapshot.data[index], height: 100),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          snapshot.data.removeAt(index);
                        });
                      },
                    ),
                  ),
                ],
              );
            }),
          );
        }
      },
    );
  }


  void _refreshPage() {
    setState(() {
      isLoading = true; // لعرض مؤشر التحميل أثناء التحديث
    });

    _loadExistingFiles().then((_) {
      setState(() {
        isLoading = false; // إخفاء مؤشر التحميل بعد انتهاء التحديث
      });
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

  Future<void> startRecording() async {
    try {
      // طلب أذونات الميكروفون
      bool hasPermission = await FlutterAudioRecorder.hasPermissions;
      if (!hasPermission) {
        // يجب طلب الأذونات
        return;
      }

      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String customPath = '${appDocDirectory.path}/audio_record_${DateTime.now().toString()}.wav';

      _recorder = FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);
      await _recorder.initialized;
      await _recorder.start();

      setState(() {
        isRecord = true;  // تعيين حالة التسجيل إلى true
      });
    } catch (e) {
      print("Error starting recording: $e");
    }
  }



  Future<void> stopRecording() async {
    try {
      var result = await _recorder.stop();
      setState(() {
        _recording = result;
        _audioFilePath = _recording.path;
        _audioFile = File(_audioFilePath);
        isRecord = false;  // تعيين حالة التسجيل إلى false
      });

      // ارفع الملف إلى Firebase
      if (_audioFile != null) {
        String audioUrl = await uploadAudioFile(_audioFile);
        setState(() {
          recordController.text = audioUrl;
        });
      }
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }

  Future<String> uploadAudioFile(File audioFile) async {
    try {
      String audioName = audioFile.path.split('/').last;
      firebase_storage.Reference audioRef = firebase_storage.FirebaseStorage
          .instance
          .ref()
          .child('audios')
          .child(audioName);

      await audioRef.putFile(audioFile);
      String audioUrl = await audioRef.getDownloadURL();
      return audioUrl;  // إرجاع رابط الملف
    } catch (e) {
      print("Error uploading audio: $e");
      return null;
    }
  }


  void showRecordingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              title: Text("Audio Recording"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isRecord
                      ? Text("Recording Start Talk...")
                      : (_audioFile != null
                      ? Column(
                    children: [
                      Text(
                          "Recording finished. You can Upload or re-record."),
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          _playRecordedAudio(_audioFilePath);
                        },
                      ),
                    ],
                  )
                      : Text(
                      "Press the icon below to start recording.")),
                ],
              ),
              actions: [
                if (_audioFile == null)
                  IconButton(
                    icon: Icon(isRecord ? Icons.stop : Icons.mic),
                    onPressed: () {
                      if (isRecord) {
                        stopRecording().then((_) {
                          setState(() {});
                        });
                      } else {
                        startRecording().then((_) {
                          setState(() {});
                        });
                      }
                    },
                  ),
                if (_audioFile != null)
                  IconButton(
                    icon: Icon(Icons.replay),
                    onPressed: () {
                      setState(() {
                        _audioFile = null;
                      });
                      startRecording();
                    },
                  ),
                if (_audioFile != null)
                  IconButton(
                    icon: Icon(Icons.upload),
                    onPressed: () async {
                      Navigator.pop(context);
                      String audioUrl = await uploadAudioFile(_audioFile);
                      setState(() {
                        recordController.text = audioUrl;
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

  AudioPlayer _audioPlayer = AudioPlayer();

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

  Future<void> uploadDailyRoundWithFiles(context, action, title, date, result,
      normalValue) async {
    try {
      List<String> videoUrls = List<String>.from(widget.videos);
      List<String> audioUrls = [];
      List<String> imageUrls = List<String>.from(widget.images);
      List<String> documentUrls = List<String>.from(widget.documents);
      List<String> resultImageUrls = [];

      for (var image in resultImages) {
        String imageName = image.path.split('/').last;
        firebase_storage.Reference imageRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('result-images')
            .child(imageName);
        await imageRef.putFile(image);
        String imageUrl = await imageRef.getDownloadURL();
        resultImageUrls.add(imageUrl);
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

      for (var document in _documents) {
        String documentName = document.path.split('/').last;
        firebase_storage.Reference documentRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('documents')
            .child(documentName);
        await documentRef.putFile(document);
        String documentUrl = await documentRef.getDownloadURL();
        documentUrls.add(documentUrl);
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

      await FirebaseFirestore.instance.collection('laboratory').add({
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
        "result_images": resultImageUrls,
      });

      successMessage(context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Exception Caught: $e");
    }
  }

  Future<void> editDailyRoundWithFiles(
      BuildContext context, String title, String date, String result,
      String normalValue, String audioUrl) async {
    try {
      List<String> videoUrls = List<String>.from(widget.videos);
      List<String> imageUrls = List<String>.from(widget.images);
      List<String> documentUrls = List<String>.from(widget.documents);
      List<String> audioUrls = [];

      // تحديث الملفات الصوتية الموجودة
      if (audioUrl != null && audioUrl.isNotEmpty) {
        audioUrls.add(audioUrl); // إضافة رابط الصوت الجديد
      }

      // رفع الفيديوهات الجديدة
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

      // رفع الصور الجديدة
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

      // رفع المستندات الجديدة
      for (var document in _documents) {
        String documentName = document.path.split('/').last;
        firebase_storage.Reference documentRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('documents')
            .child(documentName);
        await documentRef.putFile(document);
        String documentUrl = await documentRef.getDownloadURL();
        documentUrls.add(documentUrl);
      }

      // تحديث البيانات في Firestore
      await FirebaseFirestore.instance
          .collection('laboratory')
          .doc(widget.id)
          .update({
        "key": 'os14042020ah',
        "title": title,
        "date": date,
        "result": result,
        "normal_value": normalValue,
        "sick_id": widget.patient.id,
        "doctor_id": await DoctorID().readID(),
        "videos": videoUrls,
        "audios": audioUrls,  // تحديث روابط الصوت
        "images": imageUrls,
        "documents": documentUrls,
      });

      successMessage(context);  // عرض رسالة نجاح
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Exception Caught: $e");
      errorMessage(context, "Failed to edit daily round.");
    }
  }


  successMessage(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK", style: TextStyle(color: teal)),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text("Success", style: TextStyle(color: teal)),
      content: Text("Uploaded successfully!"),
      actions: [okButton],
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
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
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
                      resultImages.removeAt(index);  // حذف الصورة من القائمة
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


  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                )
                    : Image.file(
                  _images[index - widget.images.length],
                  height: height * 0.2,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (index < widget.images.length) {
                        widget.images.removeAt(index);  // حذف الصور من الروابط
                      } else {
                        _images.removeAt(index - widget.images.length);  // حذف الصور الجديدة
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
                        _videos.removeAt(
                            index - widget.videos.length);  // حذف الفيديوهات الجديدة
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
                  : _documents[index - widget.documents.length]
                  .path
                  .split('/')
                  .last,  // عرض اسم المستندات الجديدة
            ),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                setState(() {
                  if (index < widget.documents.length) {
                    widget.documents.removeAt(index);  // حذف الروابط
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
        title: Text(widget.index == 0 ? 'Add ${widget.sectionName}' : 'Edit'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.refresh),  // إضافة زر التحديث
          //   onPressed: () {
          //     _refreshPage();  // استدعاء دالة التحديث عند الضغط على الأيقونة
          //   },
          // ),
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
                          hintText: getAction() == "Laboratory"
                              ? "Examination Request"
                              : widget.sectionName == "Histopathology"
                              ? "Specimen"
                              : "Test Name",
                        ),
                      ),
                      CircleAvatar(
                          radius: (width - (width * 0.8)) / 4,
                          backgroundColor:
                          _isListeningRay ? Colors.red : teal,
                          child: IconButton(
                            icon: Icon(
                              _isListeningRay
                                  ? Icons.pause
                                  : Icons.mic_none_outlined,
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
                            hintText: getAction() == "Laboratory"
                                ? "Findings"
                                : widget.sectionName ==
                                "Histopathology"
                                ? "Interpretation"
                                : "Normal Value"),
                      ),
                      CircleAvatar(
                          radius: (width - (width * 0.8)) / 4,
                          backgroundColor: _isListeningNormalValue
                              ? Colors.red
                              : teal,
                          child: IconButton(
                            icon: Icon(
                              _isListeningNormalValue
                                  ? Icons.pause
                                  : Icons.mic_none_outlined,
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
                      IconButton(
                        onPressed: () {
                          getImageReuslt();
                        },
                        icon: Icon(
                          Icons.add_a_photo_outlined,
                          color: deepBlue,
                        ),
                      ),
                      CircleAvatar(
                        radius: (width - (width * 0.8)) / 4,
                        backgroundColor:
                        _isListeningResult ? Colors.red : teal,
                        child: IconButton(
                          icon: Icon(
                            _isListeningResult
                                ? Icons.pause
                                : Icons.mic_none_outlined,
                          ),
                          onPressed: () {
                            _listen(resultController, _isListeningResult)
                                .then((value) {
                              setState(() {
                                _isListeningResult = value;
                              });
                            });
                          },
                        ),
                      ),
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
                          hintText: _recording == null
                              ? "Record"
                              : _recording.path,
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
                        backgroundColor:
                        isRecord ? Colors.deepOrangeAccent : teal,
                        child: IconButton(
                          icon:
                          isRecord ? Icon(Icons.stop) : Icon(Icons.mic_rounded),
                          onPressed: () {
                            showRecordingDialog(context);
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
                ElevatedButton(
                  onPressed: () async {
                    check().then((internet) {
                      if (internet != null && internet) {
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
                          recordController.text,
                        );
                      } else {
                        internetMessage(context);
                      }
                    });
                  },
                  child: Text(widget.index == 0 ? 'Add' : 'Edit'),
                  style: ElevatedButton.styleFrom(
                    primary: teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
