import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rounds/component.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:video_player/video_player.dart';
import '../VideoItems.dart';
import '../colors.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart' as path;

class AddConsentScreen extends StatefulWidget {
  int patientId;
  String title;
  String risk;
  String description;
  int index;
  String documentId;  // New variable to store document ID

  AddConsentScreen(this.patientId, this.title, this.description, this.index, this.risk, {this.documentId});  // Update constructor to include document ID

  @override
  _AddVideoScreen createState() => _AddVideoScreen();
}

class _AddVideoScreen extends State<AddConsentScreen> {
  final titleConroler = TextEditingController();
  final desConroler = TextEditingController();
  final riskConroler = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UrlConroler = TextEditingController();
  bool error = false;
  bool complete = true;
  bool firstLoad = true;

  List<File> _images = [];
  List<File> _videos = [];
  List<File> _documents = [];
  File _audio;
  final String KEY = 'os14042020ah';
  final String ACTIONAddConsebt = 'add-consebt';
  final String ACTIONEDIT = 'edit-sick-consebt';
  ImageSource source;

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

  Future<void> uploadConsebt(String title, String description, String risk) async {
    try {
      // Upload files to Firebase Storage and get their URLs
      List<String> imageUrls = await _uploadFiles(_images, 'images');
      List<String> videoUrls = await _uploadFiles(_videos, 'videos');
      List<String> documentUrls = await _uploadFiles(_documents, 'documents');
      String audioUrl = _audio != null ? await _uploadFile(_audio, 'audio') : "";

      await _firestore.collection('consebts').add({
        'title': title,
        'description': description,
        'procedure_risk': risk,
        'images': imageUrls,
        'videos': videoUrls,
        'documents': documentUrls,
        'audio': audioUrl,
        'doctor_id': await DoctorID().readID(),
        'sick_id': widget.patientId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      showCustomToast('Consent form uploaded successfully.');
      Navigator.pop(context);
    } catch (e) {
      print('Error uploading consebt: $e');
      showCustomToast('Error uploading consent');
    }
  }

  Future<List<String>> _uploadFiles(List<File> files, String folder) async {
    List<String> urls = [];
    for (var file in files) {
      String url = await _uploadFile(file, folder);
      urls.add(url);
    }
    return urls;
  }

  Future<String> _uploadFile(File file, String folder) async {
    try {
      String fileName = path.basename(file.path);
      Reference storageRef = _storage.ref().child('$folder/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  void showCustomToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.deepOrange,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> editConsebt(String title, String description, String documentId, String risk) async {
    try {
      List<String> imageUrls = await _uploadFiles(_images, 'images');
      List<String> videoUrls = await _uploadFiles(_videos, 'videos');
      List<String> documentUrls = await _uploadFiles(_documents, 'documents');
      String audioUrl = _audio != null ? await _uploadFile(_audio, 'audio') : "";

      await _firestore.collection('consebts').doc(documentId).update({
        'title': title,
        'description': description,
        'procedure_risk': risk,
        'images': imageUrls,
        'videos': videoUrls,
        'documents': documentUrls,
        'audio': audioUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      showCustomToast('Consent form updated successfully.');
      Navigator.pop(context);
    } catch (e) {
      print('Error editing consebt: $e');
      showCustomToast('Error updating consent');
    }
  }

  successMessage(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Success"),
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
      child: Text("OK"),
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

  errorMessage(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("ERROR"),
      content: Text("something went wrong"),
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

  Future<void> _pickImages() async {
    List<Asset> resultList = await MultiImagePicker.pickImages(
      maxImages: 300,
      enableCamera: true,
    );

    List<File> files = [];
    for (var asset in resultList) {
      final filePath = await _getImageFileFromAsset(asset);
      files.add(File(filePath));
    }

    setState(() {
      _images.addAll(files);
    });
  }

  Future<String> _getImageFileFromAsset(Asset asset) async {
    final byteData = await asset.getByteData();
    final tempFile = File('${(await getTemporaryDirectory()).path}/${asset.name}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile.path;
  }

  Future<void> _pickVideos() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    setState(() {
      if (result != null) {
        _videos.addAll(result.paths.map((path) => File(path)).toList());
      }
    });
  }

  Future<void> _pickDocuments() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true,
    );

    setState(() {
      if (result != null) {
        _documents.addAll(result.paths.map((path) => File(path)).toList());
      }
    });
  }

  Future<void> _pickAudio() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    setState(() {
      if (result != null) {
        _audio = File(result.files.single.path);
      }
    });
  }

  Future<void> _loadExistingMedia(String documentId) async {
    try {
      // Get document from Firestore
      DocumentSnapshot doc = await _firestore.collection('consebts').doc(documentId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data();

        // Load images
        List<String> imageUrls = List<String>.from(data['images'] ?? []);
        for (var imageUrl in imageUrls) {
          File file = await _downloadFile(imageUrl);
          _images.add(file);
        }

        // Load videos
        List<String> videoUrls = List<String>.from(data['videos'] ?? []);
        for (var videoUrl in videoUrls) {
          File file = await _downloadFile(videoUrl);
          _videos.add(file);
        }

        // Load documents
        List<String> documentUrls = List<String>.from(data['documents'] ?? []);
        for (var documentUrl in documentUrls) {
          File file = await _downloadFile(documentUrl);
          _documents.add(file);
        }

        // Load audio
        String audioUrl = data['audio'] ?? "";
        if (audioUrl.isNotEmpty) {
          _audio = await _downloadFile(audioUrl);
        }

        setState(() {});  // Update the UI after loading media
      }
    } catch (e) {
      print('Error loading media: $e');
    }
  }

  Future<File> _downloadFile(String url) async {
    try {
      // Download file from Firebase Storage
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/${path.basename(url)}';
      final File file = File(filePath);
      await FirebaseStorage.instance.refFromURL(url).writeToFile(file);
      return file;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  stt.SpeechToText _speech;
  bool _isListeningTitle = false;
  bool _isListeningDesc = false;
  bool _isListeningRisk = false;

  @override
  void initState() {
    super.initState();
    desConroler.text = widget.description; // تعيين النص الأولي للوصف
    titleConroler.text = widget.title; // تعيين النص الأولي للعنوان
    riskConroler.text = widget.risk; // تعيين النص الأولي للمخاطر
    _speech = stt.SpeechToText(); // تهيئة مكتبة تحويل الصوت إلى نص

    if (widget.documentId != null) {
      _loadExistingMedia(widget.documentId);  // Load existing media if editing
    }

    // تعيين مستمع لتغيرات الحالة
    _speech.statusListener = (val) {
      print('onStatus: $val');
      if (val == 'done' || val == 'notListening') {
        setState(() {
          _isListeningTitle = false;
          _isListeningDesc = false;
          _isListeningRisk = false;
        });
      }
    };

    // تعيين مستمع للأخطاء
    _speech.errorListener = (val) {
      print('onError: $val');
      setState(() {
        _isListeningTitle = false;
        _isListeningDesc = false;
        _isListeningRisk = false;
      });
    };
  }

  Future<bool> _listen(TextEditingController controller, bool coloring) async {
    if (!coloring) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => coloring = true); // تعيين حالة الاستماع إلى true
        String originalText = controller.text; // تخزين النص الأصلي في بداية الاستماع
        String newText = ""; // متغير لتجميع النصوص الجديدة

        _speech.listen(
          onResult: (val) => setState(() {
            String detectedWords = val.recognizedWords.trim(); // تنظيف النص المكتشف

            // التحقق من أن النص الجديد ليس فارغًا ومختلف عن آخر تحديث
            if (detectedWords.isNotEmpty && newText != detectedWords) {
              newText = detectedWords; // تحديث النص الجديد
              controller.text = originalText + (newText.isEmpty ? "" : " " + newText); // دمج النص الجديد مع النص الأصلي
            }
          }),
          // listenFor: Duration(seconds: 30), // مدة الاستماع القصوى (5 ثواني هنا كمثال)
          // pauseFor: Duration(seconds: 30), // مدة التوقف بين الأوامر الصوتية
          partialResults: true, // تمكين النتائج الجزئية
        );
      }
    } else {
      setState(() => coloring = false); // تعيين حالة الاستماع إلى false
      _speech.stop(); // إيقاف الاستماع
    }
    return coloring;
  }

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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId == null ? 'Add Consent' : 'Edit Consent'),  // Change title based on mode
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: width * 0.8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          color: Colors.white),
                      child: defaultTextFormField(
                          controller: titleConroler,
                          hintText: "Procedure Name"),
                    ),
                    CircleAvatar(
                        radius: (width - (width * 0.8)) / 4,
                        backgroundColor: _isListeningTitle ? Colors.deepOrangeAccent : teal,
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
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: width * 0.8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          color: Colors.white),
                      child: defaultTextFormField(
                          controller: desConroler,
                          hintText: "Procedure Benefits"),
                    ),
                    CircleAvatar(
                        radius: (width - (width * 0.8)) / 4,
                        backgroundColor: _isListeningDesc ? Colors.deepOrangeAccent : teal,
                        child: IconButton(
                          icon: Icon(
                            _isListeningDesc ? Icons.pause : Icons.mic_none_outlined,
                          ),
                          onPressed: () {
                            _listen(desConroler, _isListeningDesc)
                                .then((value) {
                              setState(() {
                                _isListeningDesc = value;
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
                      width: width * 0.8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          color: Colors.white),
                      child: defaultTextFormField(
                          controller: riskConroler,
                          hintText: "Procedure Risks"),
                    ),
                    CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor: _isListeningRisk ? Colors.deepOrangeAccent : teal,
                      child: IconButton(
                        icon: Icon(
                          _isListeningRisk ? Icons.pause : Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(riskConroler, _isListeningRisk).then((value) {
                            setState(() {
                              _isListeningRisk = value;
                            });
                          });
                        },
                      ),
                    )

                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: width * 0.65,
                      child: TextFormField(
                        controller: TextEditingController(text: _audio == null ? "Communication" : _audio.path)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: _audio == null ? 0 : _audio.path.length),
                          ),
                        style: TextStyle(
                          color: Colors.deepOrange, // Set text color to deep orange
                        ),
                        decoration: InputDecoration(
                          hintText: "Communication",
                          hintStyle: TextStyle(
                            color: Colors.deepOrange, // Set hint text color to deep orange
                          ),
                          filled: true,
                          fillColor: Colors.white, // Optional: sets the background color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0), // Set the radius of the border
                            borderSide: BorderSide(
                              color: Colors.teal, // Border color
                              width: 1.0, // Border width
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.teal, // Border color when focused
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.teal, // Border color when enabled
                              width: 1.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.red, // Border color when there is an error
                              width: 1.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.red, // Border color when focused with an error
                              width: 1.0,
                            ),
                          ),
                        ),
                        readOnly: false, // Allow editing
                        onChanged: (value) {
                          setState(() {
                            _audio = File(value); // Update _audio path
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _pickAudio();
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
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _pickImages();
                        },
                        label: Text(
                          "Images",
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
                          _pickVideos();
                        },
                        label: Text("Videos",
                            style: TextStyle(color: orange, fontSize: 15)),
                        icon: Icon(
                          Icons.video_call,
                          size: 28,
                          color: teal,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _pickDocuments();
                        },
                        label: Text("Documents",
                            style: TextStyle(color: orange, fontSize: 15)),
                        icon: Icon(
                          Icons.upload_file,
                          size: 28,
                          color: teal,
                        ),
                      ),
                    ]),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _images.isEmpty
                    ? [
                  Center(
                    child: Text(
                      'No images selected',  // الرسالة التي تظهر عند عدم وجود صور
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ]
                    : _images.map((image) {
                  return Stack(
                    children: [
                      Image.file(image, height: height * 0.2),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _images.remove(image);  // حذف الصورة
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _videos.isEmpty
                    ? [
                  Center(
                    child: Text(
                      'No videos selected',  // الرسالة التي تظهر عند عدم وجود فيديوهات
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ]
                    : _videos.map((video) {
                  return Stack(
                    children: [
                      VideoItems(
                        videoPlayerController: VideoPlayerController.file(video),
                        looping: false,
                        autoplay: true,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _videos.remove(video);  // حذف الفيديو
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _documents.isEmpty
                    ? [
                  Center(
                    child: Text(
                      'No documents selected',  // الرسالة التي تظهر عند عدم وجود مستندات
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ]
                    : _documents.map((document) {
                  return Stack(
                    children: [
                      Container(
                        height: height * 0.2,
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(path.basename(document.path)),  // عرض اسم المستند
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _documents.remove(document);  // حذف المستند
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              myButton(
                width: width,
                onPressed: () async {
                  check().then((intenet) {
                    if (intenet != null && intenet) {
                      setState(() {
                        error = true;
                      });
                      if (widget.documentId == null) {
                        uploadConsebt(
                          titleConroler.text,
                          desConroler.text,
                          riskConroler.text,
                        );
                      } else {
                        editConsebt(
                          titleConroler.text,
                          desConroler.text,
                          widget.documentId, // Pass the document ID here
                          riskConroler.text,
                        );
                      }
                    } else {
                      internetMessage(context);
                    }
                  });
                },
                text: error ? 'Uploading' : widget.documentId == null ? 'Add' : 'Edit',  // Change button text based on mode
              ),
            ],
          ),
        ),
      ),
    );
  }
}
