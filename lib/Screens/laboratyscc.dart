import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/AddScreens/AddDailyRoundSectionsScreen.dart';
import 'package:rounds/Screens/LaboratoryDetailScreen.dart';
import 'package:share/share.dart';
import '../colors.dart';

class NewLaboratoryScreen extends StatefulWidget {
  final String patientId;
  final DoctorSicks patient;
  final id;

  const NewLaboratoryScreen({Key key, this.patientId, this.patient, this.id})
      : super(key: key);

  @override
  _NewLaboratoryScreenState createState() => _NewLaboratoryScreenState();
}

class _NewLaboratoryScreenState extends State<NewLaboratoryScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laboratory'),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              text: 'Hematology',
              icon: Icon(Icons.bloodtype),
            ),
            Tab(
              text: 'Chemistry',
              icon: Icon(Icons.science),
            ),
            Tab(
              text: 'Microbiology',
              icon: Icon(Icons.album_outlined),
            ),
            Tab(
              text: 'Histopathology',
              icon: Icon(Icons.local_hospital),
            ),
            Tab(
              text: 'Others',
              icon: Icon(Icons.more_horiz),
            ),
          ],
          indicator: BoxDecoration(
            color: Colors.deepOrangeAccent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('add-laboratory-hematology'),
          _buildTabContent('add-laboratory-chemistry'),
          _buildTabContent('add-laboratory-microbiology'),
          _buildTabContent('add-laboratory-histopathology'),
          _buildTabContent('add-laboratory-others'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String action = '';
          switch (_tabController.index) {
            case 0:
              action = 'Hematology';
              break;
            case 1:
              action = 'Chemistry';
              break;
            case 2:
              action = 'Microbiology';
              break;
            case 3:
              action = 'Histopathology';
              break;
            case 4:
              action = 'Others';
              break;
            default:
              break;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDailyRoundSectionsScreen(
                action,
                "",
                "",
                "",
                "",
                "",
                0,
                "",
                "",
                widget.patient,
                List<String>.from([]),
                List<String>.from([]),
                List<String>.from([]),
              ),
            ),
          );
        },
        backgroundColor: teal,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabContent(String action) {
    return StreamBuilder(
      stream: firestore
          .collection('laboratory')
          .where('sick_id', isEqualTo: widget.patient.id)
          .where('action', isEqualTo: action)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data.docs.isEmpty) {
          return Center(
              child: Text(
                'No Laboratory Added',
                style: TextStyle(color: teal, fontWeight: FontWeight.bold),
              ));
        }

        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data.docs[index].data();
            return Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              padding: EdgeInsets.only(left: 20, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton<String>(
                        itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share),
                                SizedBox(width: 8),
                                Text('Share'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'see_more',
                            child: Row(
                              children: [
                                Icon(Icons.remove_red_eye_outlined,
                                    color: teal),
                                SizedBox(width: 8),
                                Text('See more'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (String value) {
                          switch (value) {
                            case 'see_more':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LaboratoryDetailScreen(
                                    data: data,
                                  ),
                                ),
                              );
                              break;
                            case 'share':
                              _shareData(data);
                              break;
                            case 'edit':
                              print("Videos: ${data['videos']}");
                              print("Images: ${data['images']}");
                              print("Documents: ${data['documents']}");

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddDailyRoundSectionsScreen(
                                    data['action'],
                                    snapshot.data.docs[index].id, // استخدم معرف المستند هنا
                                    data['title'],
                                    data['date'],
                                    data['result'],
                                    data['normal_value'],
                                    1,
                                    data['result_image'] ?? '',
                                    data['sick_id'].toString(),
                                    widget.patient,
                                    List<String>.from(data['videos'] ?? []),
                                    List<String>.from(data['images'] ?? []),
                                    List<String>.from(data['documents'] ?? []),
                                    data['normal_value'],
                                  ),
                                ),
                              );


                              break;
                            case 'delete':
                              _showDeleteDialog(snapshot.data.docs[index].id);
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      '${data['date']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrangeAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Title: ',
                          style: TextStyle(
                              color: teal, fontWeight: FontWeight.bold)),
                      Text('${data['title']}',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Normal Value: ',
                          style: TextStyle(
                              color: teal, fontWeight: FontWeight.bold)),
                      Text('${data['normal_value']}',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Result: ',
                          style: TextStyle(
                              color: teal, fontWeight: FontWeight.bold)),
                      Text('${data['result']}',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Confirm Deletion',
            style: TextStyle(
                color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: teal),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteDocument(documentId);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.deepOrangeAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  final CollectionReference collection =
  FirebaseFirestore.instance.collection('laboratory');

  Future<void> deleteDocument(String documentId) async {
    try {
      await collection.doc(documentId).delete();
      print('Document deleted successfully!');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  void _shareData(Map<String, dynamic> data) {
    String sharedData = "Date: ${data['date']}\n"
        "Title: ${data['title']}\n"
        "Normal Value: ${data['normal_value']}\n"
        "Result: ${data['result']}\n";

    if (data.containsKey('images')) {
      sharedData += "Images: ${data['images'].join(', ')}\n";
    }
    if (data.containsKey('videos')) {
      sharedData += "Videos: ${data['videos'].join(', ')}\n";
    }
    if (data.containsKey('documents')) {
      sharedData += "Documents: ${data['documents'].join(', ')}\n";
    }

    Share.share(sharedData, subject: 'Laboratory Data');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}