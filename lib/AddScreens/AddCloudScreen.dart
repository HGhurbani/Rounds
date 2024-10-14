import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:rounds/colors.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:rounds/component.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class AddCloudScreen extends StatefulWidget {
  final String docId;
  final String fileTitle;
  final String fileUrl;

  AddCloudScreen({this.docId, this.fileTitle, this.fileUrl});

  @override
  _AddCloudScreen createState() => _AddCloudScreen();
}

class _AddCloudScreen extends State<AddCloudScreen> {
  final titleController = TextEditingController();
  bool error = false;
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  double _confidence = 1.0;
  bool isLoading = false;
  List<File> selectedFiles = [];

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          // إذا كانت الحالة "done" أو "notListening"، إعادة تعيين الأيقونة
          if (val == 'done' || val == 'notListening') {
            setState(() {
              _isListening = false; // إعادة حالة الاستماع إلى "false"
            });
          }
        },
        onError: (val) {
          print('onError: $val');
          // إعادة حالة الاستماع إلى "false" عند حدوث خطأ
          setState(() {
            _isListening = false;
          });
        },
      );

      if (available) {
        setState(() => _isListening = true); // تعيين حالة الاستماع إلى "true"

        String originalText = titleController.text; // تخزين النص الأصلي في بداية الاستماع
        String newText = ""; // متغير لتجميع النصوص الجديدة

        _speech.listen(
          onResult: (val) => setState(() {
            String detectedWords = val.recognizedWords.trim();

            // التحقق من أن النص الجديد ليس فارغًا ومختلف عن آخر تحديث
            if (detectedWords.isNotEmpty && newText != detectedWords) {
              newText = detectedWords; // تحديث النص الجديد
              titleController.text = originalText + (newText.isEmpty ? "" : " " + newText); // دمج النص الجديد مع الأصلي
            }

            // تحديث معدل الثقة
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
          // listenFor: Duration(seconds: 30), // مدة الاستماع القصوى (مثال: 5 ثواني)
          // pauseFor: Duration(seconds: 30), // التوقف بين الأوامر الصوتية
          partialResults: true, // تمكين النتائج الجزئية
        );
      }
    } else {
      setState(() => _isListening = false); // إيقاف الاستماع يدوياً
      _speech.stop(); // إيقاف الاستماع
    }
  }




  Future<void> getFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path)).toList();
      });
    }
  }

  void successMessage(BuildContext context, String message) {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(
        "Success",
        style: TextStyle(color: teal),
      ),
      content: Text(message),
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

  void errorMessage(BuildContext context, String message) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text(message),
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

  Future<void> uploadFiles(BuildContext context, String title) async {
    if (title.isEmpty) {
      errorMessage(context, "Please enter a title.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String currentUserId = await DoctorID().readID();
      DocumentSnapshot userSnapshot = await firestore.collection('doctors').doc(currentUserId).get();
      if (userSnapshot.exists) {
        String shareId = userSnapshot.data()['share_id'] ?? '';

        if (shareId.isNotEmpty) {
          List<String> fileUrls = [];

          for (var file in selectedFiles) {
            String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
            firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
                .ref()
                .child('cloud_files')
                .child(fileName);

            await ref.putFile(file);
            String fileUrl = await ref.getDownloadURL();
            fileUrls.add(fileUrl);
          }

          DocumentReference docRef = await firestore.collection('clouds').add({
            "file_title": title,
            "file_urls": fileUrls,
            "doctor_id": currentUserId,
            "share_id": shareId,
            "timestamp": FieldValue.serverTimestamp(),
          });

          String cloudId = docRef.id;
          await docRef.update({"cloudId": cloudId});

          Navigator.pop(context, "Cloud uploaded successfully");
        } else {
          errorMessage(context, "Share ID is empty");
        }
      } else {
        errorMessage(context, "User data not found");
      }
    } catch (e) {
      print("Exception Caught : $e");
      errorMessage(context, "Failed to upload cloud");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> editCloud(BuildContext context, String title) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('clouds').doc(widget.docId).update({
        "file_title": title,
      });

      Navigator.pop(context, "Cloud edited successfully");
    } catch (e) {
      print("Exception Caught : $e");
      errorMessage(context, "Failed to edit cloud");
    }
  }

  @override
  void initState() {
    super.initState();
    titleController.text = widget.fileTitle ?? ''; // تعيين النص الأولي من 'fileTitle' إذا كان موجودًا
    _speech = stt.SpeechToText(); // تهيئة مكتبة تحويل الصوت إلى نص

    // تعيين مستمع لتغيرات الحالة
    _speech.statusListener = (val) {
      print('onStatus: $val');
      // إذا كانت الحالة "done" أو "notListening"، إعادة تعيين الأيقونة
      if (val == 'done' || val == 'notListening') {
        setState(() {
          _isListening = false; // إعادة حالة الاستماع إلى "false"
        });
      }
    };

    // تعيين مستمع للأخطاء
    _speech.errorListener = (val) {
      print('onError: $val');
      // إعادة حالة الاستماع إلى "false" عند حدوث خطأ
      setState(() {
        _isListening = false;
      });
    };
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.docId == null ? 'Add Cloud' : 'Edit Cloud'),
          elevation: 0,
          backgroundColor: teal,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 100),

                Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.7,
                      child: defaultTextFormField(
                        controller: titleController,
                        hintText: "Cloud Title",
                      ),
                    ),
                    CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor: teal,
                      child: IconButton(
                        icon: Icon(
                            _isListening ? Icons.pause : Icons.mic_rounded),
                        onPressed: _listen,
                      ),
                    )
                  ],
                ),
                SizedBox(height: height * 0.02),
                Center(
                  child: TextButton.icon(
                    onPressed: getFile,
                    icon: Icon(Icons.upload_file, color: Colors.deepOrange),
                    label: Text(
                      "Upload any files",
                      style: TextStyle(color: teal, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedFiles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.insert_drive_file, color: teal),
                        title: Text(selectedFiles[index].path.split('/').last),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              selectedFiles.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                myButton(
                  width: width,
                  text: widget.docId == null ? "Add Cloud" : "Edit Cloud",
                  onPressed: () async {
                    widget.docId == null
                        ? uploadFiles(context, titleController.text)
                        : editCloud(context, titleController.text);
                  },
                ),
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(teal),
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

class EditCloudScreen extends StatelessWidget {
  final String docId;
  final String initialTitle;
  final String initialUrl;

  EditCloudScreen({this.docId, this.initialTitle, this.initialUrl});

  @override
  Widget build(BuildContext context) {
    return AddCloudScreen(
      docId: docId,
      fileTitle: initialTitle,
    );
  }
}
