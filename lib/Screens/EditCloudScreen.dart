import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../colors.dart';

class EditCloudScreen extends StatefulWidget {
  final String docId;
  final String initialTitle;
  final String initialUrl;
  final String initialFilePath;

  EditCloudScreen({
    this.docId,
    this.initialTitle,
    this.initialUrl,
    this.initialFilePath,
  });

  @override
  _EditCloudScreenState createState() => _EditCloudScreenState();
}

class _EditCloudScreenState extends State<EditCloudScreen> {
  final titleController = TextEditingController();
  final urlController = TextEditingController();
  File _newAudio;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.initialTitle;
    urlController.text = widget.initialUrl;
  }

  Future getNewAudio() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', '3gpp', '3gp'],
    );
    setState(() {
      if (result != null) {
        _newAudio = File(result.files.single.path);
      }
    });
  }

  Future<void> updateCloud() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      Map<String, dynamic> updateData = {
        "file_title": titleController.text,
        "file_url": urlController.text,
      };

      if (_newAudio != null) {
        updateData["cloud_file"] = _newAudio.path;
      }

      await firestore.collection('clouds').doc(widget.docId).update(updateData);

      Navigator.pop(context);
    } catch (e) {
      print("Failed to update cloud: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update cloud"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Cloud"),
        backgroundColor: teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "File Title",
                labelStyle: TextStyle(color: teal),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.3),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: "File URL",
                labelStyle: TextStyle(color: teal),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.3),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: teal, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: getNewAudio,
              icon: Icon(Icons.upload_file),
              label: Text("Upload New Audio"),
              style: ElevatedButton.styleFrom(
                primary: teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            if (_newAudio != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "New Audio Selected: ${_newAudio.path.split('/').last}",
                  style: TextStyle(color: teal),
                ),
              ),
            Spacer(),
            ElevatedButton(
              onPressed: updateCloud,
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrangeAccent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
