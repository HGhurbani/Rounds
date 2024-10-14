import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:rounds/AddScreens/AddCloudScreen.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rounds/Network/DoctorDataModel.dart';

class CloudScreen extends StatefulWidget {
  List<Cloud> cloud;

  CloudScreen(this.cloud);

  @override
  _CloudScreenState createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  AudioPlayer advancedPlayer;
  Duration _duration = new Duration();
  Duration _position = new Duration();
  bool downloading = false;
  String progress = '0%';
  bool isDownloaded = false;
  String doctorId = '';
  String searchQuery = ''; // متغير البحث

  @override
  void initState() {
    super.initState();
    initPlayer();
    getDoctorId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTime();
    });
  }

  void getDoctorId() async {
    try {
      String userId = await DoctorID().readID();
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          doctorId = snapshot.data()['share_id'] ?? '';
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error getting doctor ID: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    advancedPlayer.dispose();
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();

    advancedPlayer.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });
    advancedPlayer.onAudioPositionChanged.listen((Duration d) {
      setState(() => _position = d);
    });
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    advancedPlayer.seek(newDuration);
  }

  void deleteCloud(String cloudId) async {
    try {
      await FirebaseFirestore.instance
          .collection('clouds')
          .doc(cloudId)
          .delete();
      setState(() {
        widget.cloud.removeWhere((cloud) => cloud.cloudId == cloudId);
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Cloud deleted successfully"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Exception Caught : $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: Text("Failed to delete cloud"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: teal),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> downloadFile(String uri, String fileName) async {
    setState(() {
      downloading = true;
    });

    String savePath = await getFilePath(fileName);

    Reference ref = FirebaseStorage.instance.ref().child(fileName);

    File file = File(savePath);
    if (!file.existsSync()) {
      await ref.writeToFile(file);
    }

    setState(() {
      isDownloaded = true;
      downloading = false;
    });
  }

  void showDownloadProgress(int received, int total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");

      setState(() {
        progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  Future<String> getFilePath(String uniqueFileName) async {
    String path = '';

    Directory dir = await getExternalStorageDirectory();

    path = '${dir.path}/$uniqueFileName';

    print('path : $path');

    return path;
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

  TextStyle style2 = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 17,
    color: teal,
  );
  TextStyle style1 = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: Colors.deepOrangeAccent,
  );

  Future<void> shareCloud(String title, List<dynamic> fileUrls) async {
    String filesText = fileUrls.map((url) => url.toString()).join("\n");
    await FlutterShare.share(
      title: 'Data',
      text: 'Title: $title \nCloud Links:\n$filesText',
      chooserTitle: 'Share with',
    );
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time_cloud_screen') ?? true;

    if (isFirstTime) {
      _showUsageInstructions();
      await prefs.setBool('first_time_cloud_screen', false);
    }
  }

  void _showUsageInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Text('Usage Instructions', style: TextStyle(color: teal)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('1. Use the add button to upload new clouds.'),
                Text('2. Tap on the cloud to edit or delete it.'),
                Text('3. Use the share option to share the cloud details.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: teal)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: teal,
        title: Text('My Clouds'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCloudScreen(
                docId: null,
                fileTitle: '',
                fileUrl: '',
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Enter file title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('clouds')
                  .where('share_id', isEqualTo: doctorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No Clouds Found",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  var filteredDocs = snapshot.data.docs.where((doc) {
                    var title = doc.data()['file_title'].toString().toLowerCase();
                    return title.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var cloudData = filteredDocs[index].data();
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 10.0,
                          child: ListTile(
                            title: Row(
                              children: [
                                Icon(Icons.cloud_upload, color: Colors.deepOrangeAccent),
                                SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    cloudData['file_title'],
                                    style: style2,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  String result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditCloudScreen(
                                        docId: filteredDocs[index].id,
                                        initialTitle: cloudData['file_title'],
                                        initialUrl: cloudData['file_url'],
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          title: Text(
                                            "Success",
                                            style: TextStyle(color: teal),
                                          ),
                                          content: Text(result),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "OK",
                                                style: TextStyle(color: teal),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Confirm Delete',
                                                style: TextStyle(
                                                  color: teal,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 20.0),
                                              Text(
                                                'Are you sure you want to delete this cloud?',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              SizedBox(height: 20.0),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10.0),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      deleteCloud(filteredDocs[index].id);
                                                    },
                                                    child: Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else if (value == 'share') {
                                  shareCloud(cloudData['file_title'], cloudData['file_urls']);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8.0),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8.0),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'share',
                                    child: Row(
                                      children: [
                                        Icon(Icons.share, color: Colors.green),
                                        SizedBox(width: 8.0),
                                        Text('Share'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
