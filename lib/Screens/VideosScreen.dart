import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rounds/AddScreens/AddVideoScreen.dart';
import 'package:rounds/Screens/VideoDetailsScreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'package:rounds/colors.dart';

class VideosScreen extends StatefulWidget {
  final int type;

  VideosScreen(this.type);

  @override
  _VideosScreenState createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User user = FirebaseAuth.instance.currentUser;
  String shareId = '';
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    loadShareId();
    _showFirstTimeMessage();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void loadShareId() async {
    try {
      if (user != null) {
        String doctorId = user.uid;
        DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctorId)
            .get();
        setState(() {
          shareId = doctorSnapshot.get('share_id');
        });
      } else {
        // Handle case where user is not logged in
      }
    } catch (e) {
      print('Error loading share ID: $e');
    }
  }

  Future<void> _showFirstTimeMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime_VideosScreen') ?? true;

    if (isFirstTime) {
      // عرض الرسالة للمرة الأولى
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            title: Text(
              'Welcome to Education & Useful info',
              style: TextStyle(color: teal),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Here you can add and manage education or any useful information.'),
                SizedBox(height: 10),
                Text('1. Use the search icon to find specific information.'),
                Text('2. Click on an item to view detailed information.'),
                Text('3. Use the "+" button to add new information.'),
                Text('4. You can edit, delete, share, or print the information.'),
                SizedBox(height: 20),
                Text('You can manage all your educational and useful information here.'),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(teal),
                ),
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      await prefs.setBool('isFirstTime_VideosScreen', false);
    }
  }

  Future<void> printFunction(List<Map<String, dynamic>> videosData) async {
    final pdf = pw.Document();

    for (final videoData in videosData) {
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Container(
              padding: pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(videoData['title'],
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text(videoData['description'],
                      style: pw.TextStyle(fontSize: 16)),
                  pw.Container(
                    margin: pw.EdgeInsets.symmetric(vertical: 10),
                    alignment: pw.Alignment.center,
                    child: pw.Image(
                      pw.MemoryImage(videoData['imageBytes']),
                      fit: pw.BoxFit.cover,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<Map<String, dynamic>> prepareDataForPrinting(String videoId) async {
    var docSnapshot = await _firestore.collection('videos').doc(videoId).get();
    var data = docSnapshot.data() as Map<String, dynamic>;

    final imageBytes = data['images'] != null && data['images'].isNotEmpty
        ? await _getImageBytesFromUrl(data['images'][0])
        : null;

    return {
      'title': data['title'],
      'description': data['description'],
      'imageBytes': imageBytes,
    };
  }

  Future<Uint8List> _getImageBytesFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> deleteItem(String videoId) async {
    bool confirm = await showDialog(
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
                  'Confirm Deletion',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Are you sure you want to delete this item?',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
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

    if (confirm != null && confirm) {
      var docSnapshot = await _firestore.collection('videos').doc(videoId).get();
      var data = docSnapshot.data();
      if (data != null) {
        if (data['videoUrl'] != null && data['videoUrl'].isNotEmpty) {
          await _storage.refFromURL(data['videoUrl']).delete();
        }
        if (data['images'] != null && data['images'].isNotEmpty) {
          for (String imageUrl in data['images']) {
            await _storage.refFromURL(imageUrl).delete();
          }
        }
      }
      await _firestore.collection('videos').doc(videoId).delete();

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
                    'Success',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Item deleted successfully!',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Videos List')),
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 1 ? 'Useful information' : 'Education'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddVideoScreen(type: widget.type)));
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('videos')
                  .where('share_id', isEqualTo: shareId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var filteredDocs = snapshot.data.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['title'].toLowerCase().contains(_searchText) ||
                      data['description'].toLowerCase().contains(_searchText);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                      child: Text(
                        'No Data Found',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: teal,
                        ),
                      ));
                }
                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.all(10),
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoDetailsScreen(data: data),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 0,
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        image: DecorationImage(
                                          image: NetworkImage(data['images'] != null &&
                                              data['images'].isNotEmpty
                                              ? data['images'][0]
                                              : 'https://via.placeholder.com/150'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['title'],
                                          style: TextStyle(
                                            color: teal,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          data['description'],
                                          style: TextStyle(
                                            color: Colors.deepOrangeAccent,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            PopupMenuButton<String>(
                                              icon: Icon(Icons.more_vert),
                                              onSelected: (value) async {  // جعل الدالة async لانتظار النتائج
                                                if (value == 'edit') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => AddVideoScreen(
                                                        type: widget.type,
                                                        title: data['title'],
                                                        description: data['description'],
                                                        index: index,
                                                        documentId: doc.id,
                                                        images: List<String>.from(data['images'] ?? []),
                                                        videoUrls: List<String>.from(data['videoUrls'] ?? []),
                                                        documentUrls: List<String>.from(data['documentUrls'] ?? []),
                                                      ),
                                                    ),
                                                  );
                                                } else if (value == 'delete') {
                                                  deleteItem(doc.id);
                                                } else if (value == 'share') {
                                                  _shareContent(
                                                    data['videoUrl'],
                                                    List<String>.from(data['images'] ?? []),
                                                    data['title'],
                                                    data['description'],
                                                  );
                                                } else if (value == 'print') {
                                                  var videoData = await prepareDataForPrinting(doc.id);  // استخدام await لانتظار البيانات
                                                  printFunction([videoData]);  // تمرير البيانات للطباعة
                                                }
                                              },
                                              itemBuilder: (BuildContext context) {
                                                return [
                                                  PopupMenuItem<String>(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit, color: Colors.blue),  // إضافة الأيقونة
                                                        SizedBox(width: 8),  // إضافة مسافة بين الأيقونة والنص
                                                        Text('Edit'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete, color: Colors.red),  // إضافة الأيقونة
                                                        SizedBox(width: 8),
                                                        Text('Delete'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'share',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.share, color: Colors.green),  // إضافة الأيقونة
                                                        SizedBox(width: 8),
                                                        Text('Share'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'print',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.print, color: Colors.grey),  // إضافة الأيقونة
                                                        SizedBox(width: 8),
                                                        Text('Print'),
                                                      ],
                                                    ),
                                                  ),
                                                ];
                                              },

                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _shareContent(String videoUrl, List<String> imageUrls, String title, String description) async {
    List<String> paths = [];

    if (videoUrl != null && videoUrl.isNotEmpty) {
      final videoFile = await _downloadFile(videoUrl, 'video.mp4');
      paths.add(videoFile.path);
    }

    for (String imageUrl in imageUrls) {
      final imageFile = await _downloadFile(imageUrl, 'image_${Uuid().v4()}.jpg');
      paths.add(imageFile.path);
    }

    final message = '$title\n$description';

    if (paths.isNotEmpty) {
      await Share.shareFiles(paths, text: message);
    } else {
      await Share.share(message);
    }
  }

  Future<File> _downloadFile(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Please wait'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Processing...'),
            ],
          ),
        );
      },
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({@required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Full Screen Image')),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
