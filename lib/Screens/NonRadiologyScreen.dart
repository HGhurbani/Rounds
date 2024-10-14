import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/AddScreens/AddNonRadiology.dart';
import 'package:rounds/Details/NonRadiologyDetailScreen.dart';
import 'package:share/share.dart';
import '../colors.dart';

class NonRadiologyScreen extends StatefulWidget {
  final String patientId;
  final DoctorSicks patient;

  const NonRadiologyScreen({Key key, this.patientId, this.patient}) : super(key: key);

  @override
  _NonRadiologyScreenState createState() => _NonRadiologyScreenState();
}

class _NonRadiologyScreenState extends State<NonRadiologyScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Non Radiology'),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              text: 'Nervous System',
              icon: Icon(Icons.emoji_people),
            ),
            Tab(
              text: 'Skin',
              icon: Icon(Icons.brightness_5),
            ),
            Tab(
              text: 'Eye',
              icon: Icon(Icons.remove_red_eye),
            ),
            Tab(
              text: 'Musculoskeletal System',
              icon: Icon(Icons.accessibility_new),
            ),
            Tab(
              text: 'Cardiovascular System',
              icon: Icon(Icons.favorite_border),
            ),
            Tab(
              text: 'Blood',
              icon: Icon(Icons.invert_colors),
            ),
            Tab(
              text: 'Digestive System',
              icon: Icon(Icons.local_dining),
            ),
            Tab(
              text: 'Genital System',
              icon: Icon(Icons.wc),
            ),
            Tab(
              text: 'Prenatal',
              icon: Icon(Icons.pregnant_woman),
            ),
            Tab(
              text: 'Infertility',
              icon: Icon(Icons.sentiment_very_dissatisfied),
            ),
            Tab(
              text: 'Lymphatic System',
              icon: Icon(Icons.healing),
            ),
            Tab(
              text: 'Non Radiology Others',
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
          _buildTabContent('add-non-radiology-nervous-system'),
          _buildTabContent('add-non-radiology-skin'),
          _buildTabContent('add-non-radiology-eye'),
          _buildTabContent('add-non-radiology-musculoskeletal-system'),
          _buildTabContent('add-non-radiology-cardiovascular-system'),
          _buildTabContent('add-non-radiology-blood'),
          _buildTabContent('add-non-radiology-digestive-system'),
          _buildTabContent('add-non-radiology-genital-system'),
          _buildTabContent('add-non-radiology-prenatal'),
          _buildTabContent('add-non-radiology-infertility'),
          _buildTabContent('add-non-radiology-lymphatic-system'),
          _buildTabContent('add-non-radiology-others'),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String action = '';
          switch (_tabController.index) {
            case 0:
              action = 'Nervous System';
              break;
            case 1:
              action = 'Skin';
              break;
            case 2:
              action = 'Eye';
              break;
            case 3:
              action = 'Musculoskeletal System';
              break;
            case 4:
              action = 'Cardiovascular System';
              break;
            case 5:
              action = 'Blood';
              break;
            case 6:
              action = 'Digestive System';
              break;
            case 7:
              action = 'Genital System';
              break;
            case 8:
              action = 'Prenatal';
              break;
            case 9:
              action = 'Infertility';
              break;
            case 10:
              action = 'Lymphatic System';
              break;
            case 11:
              action = 'Non Radiology Others';
              break;

            default:
            // Handle default case or error scenario
              break;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNonRadiologyScreen(
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
          .collection('non-radiology')
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
          return Center(child: Text('No Non Radiology Added ',style: TextStyle(color: teal,fontWeight: FontWeight.bold),));
        }

        return ListView.builder(
          itemCount: snapshot.data.docs.length,

          itemBuilder: (context, index) {
            var data = snapshot.data.docs[index].data();

            // Build your list item widget here using snapshot.data.docs[index]
            return Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              padding: EdgeInsets.only(left: 20,bottom: 10),
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
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                                Icon(Icons.edit,color: Colors.blue,),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete,color: Colors.red,),
                                SizedBox(width: 8),
                                Text('Delete'),

                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'see_more',
                            child: Row(
                              children: [
                                Icon(Icons.remove_red_eye_outlined, color: teal),
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
                                  builder: (context) => NonRadiologyDetailScreen(
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
                                  builder: (context) => AddNonRadiologyScreen(
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
                                    title: Text('Confirm Deletion', style: TextStyle(color: Colors.deepOrangeAccent,fontWeight: FontWeight.bold),),
                                    content: Text('Are you sure you want to delete this item?'),
                                    actions: [

                                      TextButton(
                                        onPressed: () {
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel',style: TextStyle(color: teal),),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                          // Call the delete function
                                          deleteDocument(snapshot.data.docs[index].id);
                                        },
                                        child: Text('Delete',style: TextStyle(color: Colors.deepOrangeAccent),),
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
                      Text('Title: ', style: TextStyle(color: teal, fontWeight: FontWeight.bold)),
                      Text('${snapshot.data.docs[index]['title']}', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Normal Value: ', style: TextStyle(color: teal, fontWeight: FontWeight.bold)),
                      Text('${snapshot.data.docs[index]['normal_value']}', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Result: ', style: TextStyle(color: teal, fontWeight: FontWeight.bold)),
                      Text('${snapshot.data.docs[index]['result']}', style: TextStyle(color: Colors.black)),
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
  final CollectionReference collection = FirebaseFirestore.instance.collection('non-radiology');
  Future<void> deleteDocument(String documentId) async {
    try {
      await collection.doc(documentId).delete();
      print('Document deleted successfully!');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  void _showEditDialog(String documentId, String date, List<String> images, String normalValue, String result, String resultImage, String title, String video) {
    TextEditingController dateController = TextEditingController(text: date);
    TextEditingController normalValueController = TextEditingController(text: normalValue);
    TextEditingController resultController = TextEditingController(text: result);
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
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
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
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
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
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
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
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
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
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون غير محدد
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: teal), // هنا يتم تعيين لون المربع عندما يكون محدداً
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
                DocumentReference documentReference = FirebaseFirestore.instance.collection('non-radiology').doc(documentId);

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
    String sharedData = "Date: ${data['date']}\nTitle: ${data['title']}\nNormal Value: ${data['normal_value']}\nResult: ${data['result']}";

    // مشاركة البيانات باستخدام مكتبة share
    Share.share(sharedData, subject: 'Laboratory Data');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
