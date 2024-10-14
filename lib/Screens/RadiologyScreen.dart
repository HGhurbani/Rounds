import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/AddScreens/AddRadiology.dart';
import 'package:rounds/Details/RadiologyDetailScreen.dart';
import 'package:share/share.dart';
import '../colors.dart';

class RadiologyScreen extends StatefulWidget {
  final String patientId;
  final DoctorSicks patient;

  const RadiologyScreen({Key key, this.patientId, this.patient})
      : super(key: key);

  @override
  _RadiologyScreenState createState() => _RadiologyScreenState();
}

class _RadiologyScreenState extends State<RadiologyScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radiology'),
        bottom: TabBar(
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          controller: _tabController,
          tabs: [
            Tab(
              text: 'X-ray',
              icon: Icon(Icons.image), // Icon for X-ray
            ),
            Tab(
              text: 'CT-Scan',
              icon: Icon(Icons.airline_seat_flat), // Icon for CT-Scan
            ),
            Tab(
              text: 'MRI',
              icon: Icon(Icons.missed_video_call_rounded), // Icon for MRI
            ),
            Tab(
              text: 'Ultrasound',
              icon: Icon(Icons.settings_input_antenna), // Icon for Ultrasound
            ),
            Tab(
              text: 'IsotopeScan',
              icon: Icon(Icons.local_hospital), // Icon for IsotopeScan
            ),
            Tab(
              text: 'Others',
              icon: Icon(Icons.more_horiz), // Icon for Others
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
          _buildTabContent('add-radiology-xray'),
          _buildTabContent('add-radiology-ct-scan'),
          _buildTabContent('add-radiology-mri'),
          _buildTabContent('add-radiology-ultrasound'),
          _buildTabContent('add-radiology-isotope-scan'),
          _buildTabContent('add-radiology-others'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String action = '';
          switch (_tabController.index) {
            case 0:
              action = 'X-ray';
              break;
            case 1:
              action = 'CT-Scan';
              break;
            case 2:
              action = 'MRI';
              break;
            case 3:
              action = 'Ultrasound';
              break;
            case 4:
              action = 'IsotopeScan';
              break;
            case 5:
              action = 'Others';
              break;
            default:
              // Handle default case or error scenario
              break;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRadiologyScreen(
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
          .collection('radiology')
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
            'No Radiology Added',
            style: TextStyle(color: teal, fontWeight: FontWeight.bold),
          ));
        }

        return ListView.builder(
          itemCount: snapshot.data.docs.length,

          itemBuilder: (context, index) {
            var data = snapshot.data.docs[index].data();

            // Build your list item widget here using snapshot.data.docs[index]
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
                    offset: Offset(0, 2), // changes position of shadow
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
                                Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
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
                          // Handle actions based on value (share, edit, delete)
                          switch (value) {
                            case 'see_more':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RadiologyDetailScreen(
                                    data: snapshot.data.docs[index].data(),
                                  ),
                                ),
                              );
                              break;
                            case 'share':
                              _shareData(snapshot.data.docs[index]);
                              // Handle share action
                              break;
                            case 'edit':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddRadiologyScreen(
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
                                          color: Colors.deepOrangeAccent,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                        'Are you sure you want to delete this item?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: teal),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                          // Call the delete function
                                          deleteDocument(
                                              snapshot.data.docs[index].id);
                                        },
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                              color: Colors.deepOrangeAccent),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              // Handle delete action
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      '${snapshot.data.docs[index]['date']}',
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
                      Text('${snapshot.data.docs[index]['title']}',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Normal Value: ',
                          style: TextStyle(
                              color: teal, fontWeight: FontWeight.bold)),
                      Text('${snapshot.data.docs[index]['normal_value']}',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Result: ',
                          style: TextStyle(
                              color: teal, fontWeight: FontWeight.bold)),
                      Text('${snapshot.data.docs[index]['result']}',
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

  final CollectionReference collection =
      FirebaseFirestore.instance.collection('radiology');
  Future<void> deleteDocument(String documentId) async {
    try {
      await collection.doc(documentId).delete();
      print('Document deleted successfully!');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  void _showEditDialog(
      String documentId,
      String date,
      List<String> images,
      String normalValue,
      String result,
      String resultImage,
      String title,
      String video) {
    TextEditingController dateController = TextEditingController(text: date);
    TextEditingController normalValueController =
        TextEditingController(text: normalValue);
    TextEditingController resultController =
        TextEditingController(text: result);
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController videoController = TextEditingController(text: video);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Edit Data',
            style: TextStyle(color: teal, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: normalValueController,
                  decoration: InputDecoration(
                    labelText: 'Normal Value',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: resultController,
                  decoration: InputDecoration(
                    labelText: 'Result',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: videoController,
                  decoration: InputDecoration(
                    labelText: 'Video',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color:
                              teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
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
              onPressed: () async {
                // 1. الحصول على مرجع للوثيقة التي تريد تحديثها
                DocumentReference documentReference = FirebaseFirestore.instance
                    .collection('radiology')
                    .doc(documentId);

                // 2. تنفيذ عملية التحديث باستخدام القيم الجديدة
                await documentReference.update({
                  'date': dateController.text,
                  'normal_value': normalValueController.text,
                  'result': resultController.text,
                  'title': titleController.text,
                  'video': videoController.text,
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated Successfully'),
                    backgroundColor: teal,
                  ),
                );

                // 3. إغلاق مربع الحوار بعد التحديث
              },
              child: Text(
                'Update',
                style: TextStyle(color: teal),
              ),
            ),
          ],
        );
      },
    );
  }

  void _shareData(DocumentSnapshot data) {
    // جمع البيانات التي ترغب في مشاركتها
    String sharedData =
        "Date: ${data['date']}\nTitle: ${data['title']}\nNormal Value: ${data['normal_value']}\nResult: ${data['result']}";

    // مشاركة البيانات باستخدام مكتبة share
    Share.share(sharedData, subject: 'Laboratory Data');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
