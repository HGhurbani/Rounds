import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:rounds/Screens/VideosScreen.dart';
import 'package:rounds/colors.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:rounds/component.dart';
import 'package:rounds/Screens/VideoDetailsScreen.dart';

class AddVideoScreen extends StatefulWidget {
  final int type;
  final String title;
  final String description;
  final int index;
  final String documentId;
  final List<String> images;
  final List<String> videoUrls;
  final List<String> documentUrls;

  AddVideoScreen({
    this.type,
    this.title = "",
    this.description = "",
    this.index,
    this.documentId,
    this.images = const [],
    this.videoUrls = const [],
    this.documentUrls = const [],
  });

  @override
  _AddVideoScreenState createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final desController = TextEditingController();
  bool isLoading = false;
  final titleController = TextEditingController();
  List<File> newImages = [];
  List<File> newVideos = [];
  List<File> newDocuments = [];
  List<String> images = [];
  List<String> videoUrls = [];
  List<String> documentUrls = [];
  List<VideoPlayerController> _videoControllers = [];
  Map<String, dynamic> uploadedData = {};

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    desController.text = widget.description;
    images = List<String>.from(widget.images);
    videoUrls = List<String>.from(widget.videoUrls);
    documentUrls = List<String>.from(widget.documentUrls);
    initializeVideoControllers();
  }

  void initializeVideoControllers() {
    for (String videoUrl in videoUrls) {
      VideoPlayerController controller = VideoPlayerController.network(videoUrl);
      controller.initialize();
      _videoControllers.add(controller);
    }
  }

  Future<void> pickImages() async {
    List<Asset> resultList = [];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarTitle: "Rounds",
        ),
      );
      setState(() async {
        for (Asset imageAsset in resultList) {
          final filePath = await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
          File tempFile = File(filePath);
          if (tempFile.existsSync()) {
            newImages.add(tempFile);
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> pickDocuments() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        newDocuments = result.files.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> pickVideos() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        newVideos = result.files.map((file) => File(file.path)).toList();
        for (File video in newVideos) {
          VideoPlayerController controller = VideoPlayerController.file(video);
          controller.initialize();
          _videoControllers.add(controller);
        }
      });
    }
  }

  Future<List<String>> uploadFiles(List<File> files, String folder) async {
    List<String> fileUrls = [];
    for (File file in files) {
      String fileId = Uuid().v4();
      Reference fileRef = FirebaseStorage.instance.ref().child('$folder/$fileId.${file.path.split('.').last}');
      try {
        await fileRef.putFile(file);
        String fileUrl = await fileRef.getDownloadURL();
        fileUrls.add(fileUrl);
      } catch (e) {
        print("Failed to upload file: $e");
      }
    }
    return fileUrls;
  }

  Future<void> uploadData() async {
    try {
      User user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String doctorId = user.uid;

        DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance.collection('doctors').doc(doctorId).get();
        String shareId = doctorSnapshot.get('share_id');

        String videoId = widget.documentId ?? Uuid().v4();

        List<String> newImageUrls = await uploadFiles(newImages, 'images');
        List<String> newVideoUrls = await uploadFiles(newVideos, 'videos');
        List<String> newDocumentUrls = await uploadFiles(newDocuments, 'documents');

        images.addAll(newImageUrls);
        videoUrls.addAll(newVideoUrls);
        documentUrls.addAll(newDocumentUrls);

        uploadedData = {
          'title': titleController.text,
          'description': desController.text,
          'videoUrls': videoUrls,
          'images': images,
          'documentUrls': documentUrls,
          'doctor_id': doctorId,
          'share_id': shareId,
          'videoId': videoId,
        };

        if (widget.documentId == null) {
          await FirebaseFirestore.instance.collection('videos').add(uploadedData);
        } else {
          await FirebaseFirestore.instance.collection('videos').doc(widget.documentId).update(uploadedData);
        }

        showSuccessMessage(context);
      } else {
        print('User not logged in');
      }
    } catch (e) {
      print('Error uploading data: $e');
    }
  }

  @override
  void dispose() {
    _videoControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void showSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Success',
            style: TextStyle(color: teal),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Data added successfully!',
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
          actions: [],
        );
      },
    );

    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VideosScreen(2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.index == 0
                ? (widget.type == 1 ? 'Edit Useful Information' : 'Edit Education')
                : (widget.type == 1 ? 'Add Useful Information' : 'Add Education'),
          ),
          elevation: 0,
        ),
        body: SizedBox(
          height: height,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: width * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            color: Colors.white,
                          ),
                          child: defaultTextFormField(
                            controller: titleController,
                            hintText: widget.type == 1 ? 'Title' : "Name",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: width * 0.8,
                          child: defaultTextFormField(
                            controller: desController,
                            typingType: TextInputType.multiline,
                            hintText: widget.type == 1 ? 'Description' : 'Subject',
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
                          onPressed: pickImages,
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
                          onPressed: pickVideos,
                          label: Text(
                            "Videos",
                            style: TextStyle(color: orange, fontSize: 15),
                          ),
                          icon: Icon(
                            Icons.video_call,
                            size: 28,
                            color: teal,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: pickDocuments,
                          label: Text("Documents",
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
                  images.isEmpty && newImages.isEmpty
                      ? _buildNoDataMessage('No Images Selected')
                      : _buildImagesList(height),
                  documentUrls.isEmpty && newDocuments.isEmpty
                      ? _buildNoDataMessage('No Documents Selected')
                      : _buildDocumentsList(),
                  _videoControllers.isEmpty && newVideos.isEmpty
                      ? _buildNoDataMessage('No Videos Selected')
                      : _buildVideosList(height),
                  myButton(
                    width: width,
                    text: isLoading ? 'Loading' : (widget.documentId == null ? 'Add' : 'Update'),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      showLoadingDialog(context);
                      await uploadData();
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoDetailsScreen(data: uploadedData),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagesList(double height) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.0),
      ),
      height: height * 0.15,
      child: GridView.count(
        crossAxisCount: 4,
        children: List.generate(images.length + newImages.length, (index) {
          return Stack(
            children: [
              Center(
                child: index < images.length
                    ? Image.network(
                  images[index],
                  height: height * 0.2,
                )
                    : Image.file(
                  newImages[index - images.length],
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
                      if (index < images.length) {
                        images.removeAt(index);
                      } else {
                        newImages.removeAt(index - images.length);
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

  Widget _buildDocumentsList() {
    return Container(
      child: Column(
        children: List.generate(documentUrls.length + newDocuments.length, (index) {
          int docIndex = index - documentUrls.length;
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.all(8.0),
                child: Text(index < documentUrls.length
                    ? documentUrls[index].split('/').last
                    : newDocuments[docIndex].path.split('/').last),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (index < documentUrls.length) {
                        documentUrls.removeAt(index);
                      } else {
                        newDocuments.removeAt(docIndex);
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
    return Container(
      height: height * 0.2,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _videoControllers.length + newVideos.length,
        itemBuilder: (context, index) {
          if (index < _videoControllers.length) {
            final controller = _videoControllers[index];
            return controller.value.isInitialized
                ? Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(8.0),
                  width: 150,
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _videoControllers[index].dispose();
                        _videoControllers.removeAt(index);
                        videoUrls.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            )
                : Container();
          } else {
            int newIndex = index - _videoControllers.length;
            return Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(8.0),
                  width: 150,
                  child: AspectRatio(
                    aspectRatio:
                    VideoPlayerController.file(newVideos[newIndex]).value.aspectRatio,
                    child: VideoPlayer(VideoPlayerController.file(newVideos[newIndex])),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        newVideos.removeAt(newIndex);
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

  Widget _buildNoDataMessage(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: teal,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
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
}
