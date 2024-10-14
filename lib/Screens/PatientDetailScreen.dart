import 'package:rounds/AddScreens/AddReportScreen.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share/share.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rounds/Screens/RadiologyScreen.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:flutter_share/flutter_share.dart';
import 'package:printing/printing.dart';
import 'package:rounds/Screens/VitalSignScreen.dart';
import 'package:rounds/Screens/NonRadiologyScreen.dart';
import 'package:rounds/Screens/laboratyscc.dart';
import 'package:rounds/AddScreens/AddSickScreen.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'dart:io';
import '../AddScreens/AddConsentScreen.dart';
import '../AddScreens/AddMedicinesScreen.dart';
import '../AddScreens/AddVaccinationScreen.dart';
import '../AddScreens/add_daily_round_page.dart';
import '../Details/ConceptDetailsScreen.dart';
import '../colors.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PatientDetailScreen extends StatefulWidget {
  final DoctorSicks patient;
  final Consebt consent;
  final Medication medication;
  final String id;
  const PatientDetailScreen(
      {Key key, this.patient, this.id, this.consent, this.medication})
      : super(key: key);

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class ViewReportScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  ViewReportScreen({@required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reportData['report_title']),
        backgroundColor: teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reportData['report_title'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: teal,
              ),
            ),
            SizedBox(height: 16),
            Text(
              reportData['report_text'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            if (reportData['pdf_files'] != null &&
                (reportData['pdf_files'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attached Documents:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...reportData['pdf_files'].map<Widget>((pdf) {
                    return ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: Colors.teal),
                      title: Text(pdf.split('/').last),
                      onTap: () {
                        // Handle PDF view action
                      },
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}


class _PatientDetailScreenState extends State<PatientDetailScreen> {
  List<Map<String, dynamic>> tasks = [];
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() {
                  _text = val.recognizedWords;
                }));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _startListening(int index) async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _text = val.recognizedWords;
          tasks[index]['task'] = _text;
        }),
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void showWorkInProgressMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Work in Progress"),
          content: Text("This feature is still under development."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق الحوار
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _deletePatient(BuildContext context) async {
    try {
      // العثور على المريض حسب الحقل 'id'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('id', isEqualTo: widget.patient.id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // حذف كل الوثائق المطابقة
        for (var doc in snapshot.docs) {
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .delete();
        }

        // إغلاق دايلوج التأكيد
        Navigator.of(context).pop();

        // عرض دايلوج النجاح
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text('Success'),
              content: Text('Patient has been successfully deleted.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK', style: TextStyle(color: teal)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // الرجوع إلى الصفحة السابقة
                  },
                ),
              ],
            );
          },
        );
      } else {
        // في حالة عدم العثور على المريض
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text('Error'),
              content: Text('Patient not found.'),
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
    } catch (e) {
      // إغلاق دايلوج التأكيد
      Navigator.of(context).pop();

      // عرض دايلوج الخطأ
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Text('Error'),
            content: Text('Failed to delete patient: $e'),
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
  }

  List<Map<String, dynamic>> tasksList = [];
  List<String> dailyRoundsList = []; // قائمة الدايلي راودنس
  bool hasMedicalInfo =
      false; // Default value assuming no medical info is available

  CollectionReference patientsRef =
      FirebaseFirestore.instance.collection('patients');

  void _showEditDialog() async {
    bool updateSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AddSickScreen(
          sickData: widget.patient,
        ),
      ),
    );
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    Reference storageRef =
        FirebaseStorage.instance.ref().child('patient_images');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Profile'),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  Share.share(
                    'Patient Name: ${widget.patient.name ?? ''}\nFile Number: ${widget.patient.fileNumber ?? ''}',
                  );
                },
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الصورة الرمزية
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: teal,
                        child: ClipOval(
                          child: Image(
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                            image: widget.patient.avatar != null &&
                                widget.patient.avatar.isNotEmpty
                                ? NetworkImage(widget.patient.avatar)
                                : AssetImage('images/doctoravatar.png') as ImageProvider,
                          ),
                        ),
                      ),
                      SizedBox(width: 22),

                      // النصوص والمعلومات
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.patient.name ?? ''}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: teal,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${widget.patient.diagnosis ?? ''}',
                              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                _buildInfoItem('File.No', widget.patient.age),
                                SizedBox(width: 10),
                                _buildInfoItem('Surgery', widget.patient.surgery),
                                SizedBox(width: 10),
                                _buildInfoItem('Gender', widget.patient.gender),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // زر الثلاث نقاط
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PopupMenuButton<int>(
                            icon: Icon(Icons.more_vert, color: Colors.grey[800]),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: ListTile(
                                  leading: Icon(Icons.edit, color: Colors.blue),
                                  title: Text('Edit'),
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 1) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      title: Text('Confirm Delete'),
                                      content: Text(
                                          'Are you sure you want to delete this patient?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancel', style: TextStyle(color: teal)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Delete', style: TextStyle(color: Colors.deepOrangeAccent)),
                                          onPressed: () {
                                            _deletePatient(context);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (value == 2) {
                                _showEditDialog();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [],
            ),
            DefaultTabController(
              length: 5, // Number of tabs
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'General Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.today_outlined, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Daily Rounds',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Consent Illustration',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_outlined, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Medical Report',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services_outlined, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Other Medical Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    indicator: BoxDecoration(
                      // تخصيص لون علامة التبويب المحددة
                      color: Colors
                          .deepOrangeAccent, // لون علامة التبويب المحددة (الأسفل)
                      borderRadius: BorderRadius.circular(60), // حواف مستديرة
                    ),
                    labelColor: Colors.white, // لون النص عند تحديد التبويب
                    unselectedLabelColor:
                        teal, // لون النص عند عدم تحديد التبويب
                    isScrollable: true, // يجعل عناوين التبويب قابلة للتمريرر
                  ),
                  SizedBox(height: 0),
                  Container(
                    height: MediaQuery.of(context)
                        .size
                        .height, // Height of the container according to screen height
                    width: MediaQuery.of(context)
                        .size
                        .width, // Width of the container according to screen width
                    decoration: BoxDecoration(
                      color: Colors.grey[80], // Grey background color for tabs
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBarView(
                      children: [
                        _buildGeneralInfoTab(), // Placeholder for General Info tab content
                        _buildDailyRoundsInfoTab(), // Placeholder for Daily Rounds Info tab content
                        _buildConsentInfoTab(), // Placeholder for Medical Info tab content
                        _buildMedicalReportInfoTab(), // Placeholder for Medical Info tab content
                        _buildMedicalInfoTab(), // Placeholder for Medical Info tab content
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentInfoTab() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('consebts')
          .where('sick_id', isEqualTo: widget.patient.id)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final List<QueryDocumentSnapshot> documents = snapshot.data?.docs ?? [];
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddConsentScreen(
                            widget.patient.id,
                            "",
                            "",
                            0,
                            "",
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Add Consent',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: documents.isEmpty
                      ? Center(
                    child: Text(
                      'No Consent Added',
                      style: TextStyle(color: teal),
                    ),
                  )
                      : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      var concept = documents[index];
                      String title = concept['title'] ?? '';
                      String description = concept['description'] ?? '';
                      String risk = concept['procedure_risk'] ?? '';
                      List<dynamic> images = concept['images'] ?? [];
                      String imageUrl = images.isNotEmpty ? images[0] : '';
                      String videoUrl = concept['videos'] != null && concept['videos'].isNotEmpty ? concept['videos'][0] : '';
                      String audioUrl = concept['audio'] ?? '';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  imageUrl.isNotEmpty
                                      ? CircleAvatar(
                                    backgroundImage: NetworkImage(imageUrl),
                                    radius: 30,
                                  )
                                      : Icon(
                                    Icons.image,
                                    size: 50,
                                    color: teal,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: teal,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          description,
                                          style: TextStyle(
                                            color: Colors.deepOrangeAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      if (value == 'View') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ConceptDetailsScreen(
                                              data: concept.data(),
                                            ),
                                          ),
                                        );
                                      } else if (value == 'Share') {
                                        _shareConsent(concept);
                                      } else if (value == 'Edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddConsentScreen(
                                              widget.patient.id, // تمرير معرف المريض
                                              title, // تمرير العنوان
                                              description, // تمرير الوصف
                                              index, // تمرير الفهرس أو المعرف
                                              risk, // تمرير المخاطر
                                              documentId: concept.id,  // تمرير معرف الوثيقة من أجل التعديل
                                            ),
                                          ),
                                        );
                                      } else if (value == 'Delete') {
                                        _deleteConsentt(context, concept.id);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        PopupMenuItem<String>(
                                          value: 'View',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility, color: Colors.green),
                                              SizedBox(width: 8),
                                              Text('View'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'Share',
                                          child: Row(
                                            children: [
                                              Icon(Icons.share, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text('Share'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'Edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, color: Colors.orange),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'Delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
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
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _shareConsent(QueryDocumentSnapshot concept) {
    String title = concept['title'] ?? '';
    String description = concept['description'] ?? '';
    String risk = concept['procedure_risk'] ?? '';
    List<dynamic> images = concept['images'] ?? [];
    List<dynamic> videos = concept['videos'] ?? [];
    String audioUrl = concept['audio'] ?? '';

    StringBuffer shareContent = StringBuffer();
    shareContent.write('Title: $title\n');
    shareContent.write('Description: $description\n');
    shareContent.write('Risk: $risk\n\n');

    if (images.isNotEmpty) {
      shareContent.write('Images:\n');
      images.forEach((image) {
        shareContent.write('$image\n');
      });
    }

    if (videos.isNotEmpty) {
      shareContent.write('Videos:\n');
      videos.forEach((video) {
        shareContent.write('$video\n');
      });
    }

    if (audioUrl.isNotEmpty) {
      shareContent.write('Audio:\n$audioUrl\n');
    }

    Share.share(shareContent.toString());
  }


  Widget _buildMedicalReportInfoTab() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('medical_reports')
          .where('sick_id', isEqualTo: widget.patient.id)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final List<QueryDocumentSnapshot> documents = snapshot.data?.docs ?? [];
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddReportScreen(
                                widget.patient.id,
                                widget.patient,
                                widget.patient.name,
                                widget.patient.email,
                                widget.patient.id)),
                      );
                    },
                    child: Text(
                      'Add Report',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: documents.isEmpty
                      ? Center(
                    child: Text(
                      'No Reports Added',
                      style: TextStyle(color: teal),
                    ),
                  )
                      : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      var concept = documents[index];
                      String title = concept['report_title'] ?? '';
                      String description = concept['report_text'] ?? '';
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          subtitle: Text(
                            description,
                            style: TextStyle(
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          trailing: PopupMenuButton<int>(
                            onSelected: (item) => _onSelected(context, item, concept),
                            itemBuilder: (context) => [
                              PopupMenuItem<int>(
                                value: 0,
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, color: Colors.deepOrangeAccent),
                                    SizedBox(width: 8),
                                    Text('View'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<int>(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(Icons.print, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text('Print'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<int>(
                                value: 2,
                                child: Row(
                                  children: [
                                    Icon(Icons.share, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('Share'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<int>(
                                value: 3,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<int>(
                                value: 4,
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            _viewReport(context, concept);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onSelected(BuildContext context, int item, QueryDocumentSnapshot concept) {
    switch (item) {
      case 0:
        _viewReport(context, concept);
        break;
      case 1:
        _printReport(context, concept);
        break;
      case 2:
        _shareReport(context, concept);
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddReportScreen(
              concept['sick_id'],
              widget.patient,
              concept['report_title'],
              concept['report_text'],
              widget.patient.id,
              documentId: concept.id, // Pass documentId for editing
            ),
          ),
        );
        break;
      case 4:
        _deleteConsent(context, concept.id);
        break;
    }
  }

  void _viewReport(BuildContext context, QueryDocumentSnapshot concept) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewReportScreen(
          reportData: concept.data(),
        ),
      ),
    );
  }

  void _printReport(BuildContext context, QueryDocumentSnapshot concept) {
    // Implement print functionality here
  }

  void _shareReport(BuildContext context, QueryDocumentSnapshot concept) {
    // Implement share functionality here
  }

  void _deleteConsent(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Report'),
        content: Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('medical_reports').doc(documentId).delete();
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }



  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: teal),
        ),
        SizedBox(height: 4),
        Text(
          value ?? '-',
          style: TextStyle(
              color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _editMedication(String docId, String title, String text, bool isStopped) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController textController = TextEditingController(text: text);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text('Edit Medication'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Medication Title',
                    ),
                  ),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      labelText: 'Medication Text',
                    ),
                  ),
                  Row(
                    children: [
                      Text('Is Stopped'),
                      Checkbox(
                        value: isStopped,
                        onChanged: (value) {
                          setState(() {
                            isStopped = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.teal)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save', style: TextStyle(color: Colors.deepOrange)),
                  onPressed: () async {
                    // Start a batch write
                    WriteBatch batch = FirebaseFirestore.instance.batch();

                    // Update medications collection
                    DocumentReference medicationRef = FirebaseFirestore.instance.collection('medications').doc(docId);
                    batch.update(medicationRef, {
                      'medication_title': titleController.text,
                      'medication_text': textController.text,
                      'is_stopped': isStopped,
                    });

                    // Update daily_rounds collection
                    QuerySnapshot dailyRoundSnapshot = await FirebaseFirestore.instance
                        .collection('daily_rounds')
                        .where('medication', isEqualTo: title)
                        .get();

                    dailyRoundSnapshot.docs.forEach((doc) {
                      batch.update(doc.reference, {
                        'is_stopped': isStopped,
                      });
                    });

                    try {
                      // Commit the batch
                      await batch.commit();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Medication updated successfully'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.teal,
                        ),
                      );
                      Navigator.of(context).pop();
                    } catch (error) {
                      print('Failed to update medication: $error');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update medication'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _editVaccination(String docId, String name, String date, String age) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController dateController = TextEditingController(text: date);
    TextEditingController ageController = TextEditingController(text: age);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text('Edit Vaccination'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Vaccination Name',
                    ),
                  ),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                    ),
                  ),
                  TextField(
                    controller: ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.teal)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save', style: TextStyle(color: Colors.deepOrange)),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('vaccinations')
                        .doc(docId)
                        .update({
                      'vaccination_name': nameController.text,
                      'vaccination_date': dateController.text,
                      'age': ageController.text,
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGeneralInfoTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // General Info Containers
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 0,
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'Date Of Admission',
                      widget.patient.dateOfAdmission,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Date Of Discharge',
                      widget.patient.dateOfDischarge,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 0,
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'Diagnosis',
                      widget.patient.diagnosis,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Blood Group',
                      widget.patient.bloodGroup,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 0,
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'Weight',
                      widget.patient.weight,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Height',
                      widget.patient.height,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 0,
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'Medical History',
                      widget.patient.medicalHistory,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Surgical History',
                      widget.patient.surgicalHistory,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 0,
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'Smoker',
                      widget.patient.smoking,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Allergies',
                      widget.patient.allergies,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 0,
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'Occupation',
                      widget.patient.occupation,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Alcohol',
                      widget.patient.alcohol,
                    ),
                  ),
                ],
              ),
            ),
            // Add more Container with Row for other info items
            SizedBox(height: 7),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: GridView.count(
                shrinkWrap: true,  // السماح لـ GridView بأخذ حجم المحتوى فقط
                crossAxisCount: 2,  // عدد الأعمدة في الشبكة
                crossAxisSpacing: 10.0,  // المسافة الأفقية بين الأعمدة
                mainAxisSpacing: 10.0,  // المسافة العمودية بين الصفوف
                childAspectRatio: 2.5,  // نسبة العرض إلى الارتفاع لعناصر الشبكة
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewLaboratoryScreen(
                            patient: widget.patient,
                            patientId: widget.patient.id.toString(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                    child: Text(
                      'Laboratory',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NonRadiologyScreen(
                            patient: widget.patient,
                            patientId: widget.patient.id.toString(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                    child: Text('Non Radiology',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RadiologyScreen(
                            patient: widget.patient,
                            patientId: widget.patient.id.toString(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                    child: Text('Radiology',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VitalSignScreen(
                            patient: widget.patient,
                            patientId: widget.patient.id.toString(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                    child: Text('Vital Signs',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Medications :',
                    style: TextStyle(
                      color: deepBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMedicinesScreen(
                            widget.patient.id,
                            widget.patient,
                            "",
                            "",
                            0,
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
            // Display Medications List
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('medications')
                  .where('sick_id', isEqualTo: widget.patient.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.data.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text('No Medication Added')),
                  );
                }

                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data.docs[index];
                    String title = doc['medication_title'] ?? '';
                    String text = doc['medication_text'] ?? '';
                    bool isStopped = doc.data().containsKey('is_stopped') ? doc['is_stopped'] : false;

                    // تحديد لون الدائرة بناءً على حالة العلاج
                    Color statusColor = isStopped ? Colors.red : Colors.green;
                    IconData statusIcon = isStopped ? Icons.close : Icons.check;

                    return Container(
                      padding: EdgeInsets.all(7),
                      child: Card(
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Title : ',
                                    style: TextStyle(
                                      color: deepBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: teal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (String result) {
                                      if (result == 'edit') {
                                        _editMedication(doc.id, title, text, isStopped);
                                      } else if (result == 'share') {
                                        Share.share('Medication Title: $title\nMedication Text: $text');
                                      } else if (result == 'delete') {
                                        _confirmDelete(context, doc.id); // استدعاء دالة التأكيد قبل الحذف
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(Icons.edit, color: Colors.teal),
                                          title: Text('Edit'),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'share',
                                        child: ListTile(
                                          leading: Icon(Icons.share, color: Colors.deepOrange),
                                          title: Text('Share'),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(Icons.delete, color: Colors.red),
                                          title: Text('Delete'),
                                        ),
                                      ),
                                    ],
                                    icon: Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Text(
                                        'Text : ',
                                        style: TextStyle(
                                          color: deepBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        text,
                                        style: TextStyle(
                                          color: teal,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // إضافة الدائرة مع الأيقونة هنا
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: statusColor,
                                    ),
                                    child: Icon(
                                      statusIcon,
                                      color: Colors.white,
                                      size: 16,
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
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vaccinations : ',
                    style: TextStyle(
                      color: deepBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddVaccinationScreen(
                            widget.patient.id,
                            widget.patient,
                            "",
                            "",
                            "",
                            0,
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vaccinations')
                  .where('sick_id', isEqualTo: widget.patient.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.data.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text('No Vaccination Added')),
                  );
                }

                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data.docs[index];
                    String name = doc['vaccination_name'] ?? '';
                    String date = doc['vaccination_date'] ?? '';
                    String age = doc['age'] ?? '';

                    return Container(
                      padding: EdgeInsets.all(7),
                      child: Card(
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Name : ',
                                    style: TextStyle(
                                      color: deepBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: teal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (String result) {
                                      if (result == 'edit') {
                                        _editVaccination(doc.id, name, date, age);
                                      } else if (result == 'share') {
                                        Share.share(
                                          'Vaccination Name: $name\nDate: $date\nAge: $age',
                                        );
                                      } else if (result == 'delete') {
                                        _confirmDeletev(context, doc.id); // دالة التأكيد للحذف
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(Icons.edit, color: Colors.teal),
                                          title: Text('Edit'),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'share',
                                        child: ListTile(
                                          leading: Icon(Icons.share, color: Colors.deepOrange),
                                          title: Text('Share'),
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(Icons.delete, color: Colors.red),
                                          title: Text('Delete'),
                                        ),
                                      ),
                                    ],
                                    icon: Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Date : ',
                                    style: TextStyle(
                                      color: deepBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    date,
                                    style: TextStyle(
                                      color: teal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Age : ',
                                    style: TextStyle(
                                      color: deepBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    age,
                                    style: TextStyle(
                                      color: teal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
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
            SizedBox(height: 500), // مسافة بين العناصر والحافة السفلية
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0),
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.2),
        //     spreadRadius: 3,
        //     blurRadius: 7,
        //     offset: Offset(0, 3),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
          SizedBox(height: 0),
          Text(
            value ?? '-',
            style: TextStyle(
                fontSize: 14, color: teal, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoTab() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('medical_fields')
          .where('patientId', isEqualTo: widget.id)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final List<QueryDocumentSnapshot> documents = snapshot.data.docs;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showAddMedicalFieldDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Add Medical Field',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16), // مسافة بين الأزرار

                for (var doc in documents)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              doc['label'],
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (String result) {
                                if (result == 'edit') {
                                  _showEditMedicalFieldDialog(doc);
                                } else if (result == 'delete') {
                                  _showDeleteConfirmation(context, doc.id);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // SizedBox(height: 8),
                        Text(
                          doc['value'] ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: teal,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

    void _showAddMedicalFieldDialog(BuildContext context) {
      TextEditingController labelController = TextEditingController();
      TextEditingController valueController = TextEditingController();

      final ThemeData dialogTheme = ThemeData(
        dialogBackgroundColor: Colors.white,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.deepOrangeAccent,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: teal,
          ),
        ),
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Theme(
            data: dialogTheme, // dialogTheme is assumed to be predefined
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // حواف مربعة ناعمة
              ),
              title: Text(
                'Add Medical Field',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: teal, // Title color
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        'Note: This place is for adding the title and value of the field you want.',
                        style: TextStyle(fontSize: 14),
                      ),
                      dense: true,
                    ),
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(
                        labelText: 'Field Label',
                        labelStyle: TextStyle(
                          color: teal, // Label color
                        ),
                      ),
                    ),
                    TextField(
                      controller: valueController,
                      decoration: InputDecoration(
                        labelText: 'Field Value',
                        labelStyle: TextStyle(
                          color: teal, // Label color
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.red, // Button text color
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () async {
                    await addMedicalFieldToFirestore(
                      labelController.text,
                      valueController.text,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: teal, // Button color
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    void _showEditMedicalFieldDialog(QueryDocumentSnapshot doc) {
      TextEditingController labelController =
          TextEditingController(text: doc['label']);
      TextEditingController valueController =
          TextEditingController(text: doc['value']);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // حواف مربعة ناعمة
            ),
            title: Text(
              'Edit Medical Field',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: teal, // لون العنوان
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      labelText: 'Field Label',
                      labelStyle: TextStyle(
                        color: teal, // لون النص
                      ),
                    ),
                  ),
                  TextField(
                    controller: valueController,
                    decoration: InputDecoration(
                      labelText: 'Field Value',
                      labelStyle: TextStyle(
                        color: teal, // لون النص
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red, // لون النص
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white, // لون النص
                  ),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('medical_fields')
                      .doc(doc.id)
                      .update({
                    'label': labelController.text,
                    'value': valueController.text,
                  });
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: teal, // لون الزر
                ),
              ),
            ],
          );
        },
      );
    }

    void _showDeleteConfirmation(BuildContext context, String id) async {
      // عرض دايلوج تأكيد الحذف
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // حواف مربعة ناعمة
            ),
            title: Text(
              "Delete Confirmation",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.red, // Title color
              ),
            ),
            content: Text(
              "Are you sure you want to delete this medical field?",
              style: TextStyle(
                fontSize: 16.0, // Content font size
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(true); // Close dialog and confirm deletion
                },
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.red, // Button text color
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // Close dialog and cancel deletion
                },
                child: Text("No"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Button color
                ),
              ),
            ],
          );
        },
      );

      // تأكيد الحذف وحذف الحقل الطبي
      if (confirmDelete ?? false) {
        await _deleteMedicalField(id);
        // عرض رسالة نجاح بعد حذف الحقل الطبي بنجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sccussfully Deleted"),
          ),
        );
      }
    }

    void _deleteMedicalField(String id) async {
      try {
        await FirebaseFirestore.instance
            .collection('medical_fields')
            .doc(id)
            .delete();
      } catch (error) {
        print("ُُError: $error");
        // يمكنك إضافة رمز تحذير هنا
      }
    }

    Future<void> addMedicalFieldToFirestore(String label, String value) async {
      try {
        CollectionReference medicalFieldsRef =
            FirebaseFirestore.instance.collection('medical_fields');
        await medicalFieldsRef.add({
          'label': label,
          'value': value,
          'patientId': widget.id, // Add patientId to the medical field
        });
      } catch (e) {
        print('Error adding medical field to Firestore: $e');
      }
    }

    List<Map<String, String>> medicalFields = [];

    Widget _buildMedicalInfoColumn(String label, String value) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value ?? '-',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

  void _showTasksDialog(BuildContext context, String date, List<dynamic> tasks, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Daily Round - $date',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display date
                Text('Date: $date', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 16),

                // Display medication
                if (data['medication'] != null)
                  Row(
                    children: [
                      Text('Medication: ${data['medication']}'),
                      SizedBox(width: 8),
                      Icon(data['is_stopped'] ? Icons.stop : Icons.check, color: data['is_stopped'] ? Colors.red : Colors.green),
                    ],
                  ),
                SizedBox(height: 16),

                // Instruction Section Header
                Text(
                  'Instruction',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // Findings
                if (data['findings'] != null)
                  Text('Findings: ${data['findings']}'),
                SizedBox(height: 8),

                // Assessment
                if (data['assessment'] != null)
                  Text('Assessment: ${data['assessment']}'),
                SizedBox(height: 8),

                // Comment
                if (data['comment'] != null)
                  Text('Comment: ${data['comment']}'),
                SizedBox(height: 8),

                // Discharge Plan
                if (data['discharge_plan'] != null)
                  Text('Discharge Plan: ${data['discharge_plan']}'),
                SizedBox(height: 16),

                // Consultation Section Header
                Text(
                  'Consultation',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // Doctor Name
                if (data['doctor_name'] != null)
                  Text('Doctor Name: ${data['doctor_name']}'),
                SizedBox(height: 8),

                // Reason
                if (data['reason'] != null)
                  Text('Reason: ${data['reason']}'),
                SizedBox(height: 8),

                // Reply
                if (data['reply'] != null)
                  Text('Reply: ${data['reply']}'),
                SizedBox(height: 16),

                // Display tasks
                Text(
                  'Tasks:',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
                ...tasks.map<Widget>((task) {
                  // Check if task is related to medication
                  if (task.containsKey('medication') && task.containsKey('is_stopped')) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: task['completed'] ?? false,
                              onChanged: null, // Disable checkbox in display dialog
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${task['task']} - Medication: ${task['medication']} (${task['is_stopped'] ? 'Stopped' : 'Active'})',
                                style: TextStyle(
                                  decoration: task['completed']
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            if (task['completed'])
                              Icon(Icons.check, color: Colors.green), // Show check icon if task completed
                          ],
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  } else {
                    // Regular task display
                    return Row(
                      children: [
                        Checkbox(
                          value: task['completed'] ?? false,
                          onChanged: null, // Disable checkbox in display dialog
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task['task'],
                            style: TextStyle(
                              decoration: task['completed']
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (task['completed'])
                          Icon(Icons.check, color: Colors.green), // Show check icon if task completed
                      ],
                    );
                  }
                }).toList(),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share), // Icon for sharing
              onPressed: () {
                _shareTasks(context, date, data, tasks);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.print,
                color: Colors.deepOrangeAccent,
              ), // Icon for printing
              onPressed: () {
                _printTasks(context, date, data, tasks);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text(
                'Close',
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ],
        );
      },
    );
  }

  void _shareTasks(BuildContext context, String date, Map<String, dynamic> data, List tasks) {
    StringBuffer shareContent = StringBuffer();
    shareContent.writeln('Daily Round - $date');
    shareContent.writeln('Medication: ${data['medication']} (${data['is_stopped'] ? 'Stopped' : 'Active'})');
    shareContent.writeln('Findings: ${data['findings']}');
    shareContent.writeln('Assessment: ${data['assessment']}');
    shareContent.writeln('Comment: ${data['comment']}');
    shareContent.writeln('Discharge Plan: ${data['discharge_plan']}');
    shareContent.writeln('Doctor Name: ${data['doctor_name']}');
    shareContent.writeln('Reason: ${data['reason']}');
    shareContent.writeln('Reply: ${data['reply']}');
    shareContent.writeln('Tasks:');
    for (var task in tasks) {
      shareContent.writeln('- ${task['task']} (${task['completed'] ? 'Completed' : 'Not Completed'})');
    }

    Share.share(shareContent.toString());
  }

  void _printTasks(BuildContext context, String date, Map<String, dynamic> data, List tasks) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Daily Round - $date', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Medication: ${data['medication']} (${data['is_stopped'] ? 'Stopped' : 'Active'})'),
              pw.SizedBox(height: 16),
              pw.Text('Instruction', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Findings: ${data['findings']}'),
              pw.SizedBox(height: 8),
              pw.Text('Assessment: ${data['assessment']}'),
              pw.SizedBox(height: 8),
              pw.Text('Comment: ${data['comment']}'),
              pw.SizedBox(height: 8),
              pw.Text('Discharge Plan: ${data['discharge_plan']}'),
              pw.SizedBox(height: 16),
              pw.Text('Consultation', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Doctor Name: ${data['doctor_name']}'),
              pw.SizedBox(height: 8),
              pw.Text('Reason: ${data['reason']}'),
              pw.SizedBox(height: 8),
              pw.Text('Reply: ${data['reply']}'),
              pw.SizedBox(height: 16),
              pw.Text('Tasks:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ...tasks.map<pw.Widget>((task) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    '${task['task']} (${task['completed'] ? 'Completed' : 'Not Completed'})',
                    style: pw.TextStyle(decoration: task['completed'] ? pw.TextDecoration.lineThrough : null),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }




    Widget _buildDailyRoundsInfoTab() {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('daily_rounds')
            .where('patientId', isEqualTo: widget.patient.id)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final List<QueryDocumentSnapshot> documents = snapshot.data?.docs ?? [];
          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddDailyRoundPage(patient: widget.patient),
                          ),
                        );
                      },
                      child: Text(
                        'Add Daily Round',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                  ),
                  SizedBox(height: 16),
                  Container(
                    width: MediaQuery.of(context)
                        .size
                        .width, // Set width according to screen width
                    constraints: BoxConstraints(
                        // minHeight: documents.isEmpty ? 100.0 : 0.0, // Minimum height when no data
                        // maxHeight: constraints.maxHeight - 100, // Adjust maximum height dynamically
                        ),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: documents.isEmpty
                        ? Center(
                            child: Text(
                              'No Rounds Added',
                              style: TextStyle(color: teal),
                            ),
                          )
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              var dailyRound = documents[index];
                              return GestureDetector(
                                onTap: () {
                                  _showTasksDialog(
                                      context,
                                      dailyRound['date'],
                                      dailyRound['tasks'],
                                      {
                                        'medication': dailyRound['medication'] ?? '',
                                        'is_stopped': dailyRound['is_stopped'] ?? false,
                                        'findings': dailyRound['findings'] ?? '',
                                        'assessment': dailyRound['assessment'] ?? '',
                                        'comment': dailyRound['comment'] ?? '',
                                        'discharge_plan': dailyRound['discharge_plan'] ?? '',
                                        'doctor_name': dailyRound['doctor_name'] ?? '',
                                        'reason': dailyRound['reason'] ?? '',
                                        'reply': dailyRound['reply'] ?? '',
                                      }
                                  );
                                },

                                child: Container(
                                  margin: EdgeInsets.all(6),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Date : ${dailyRound['date']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              teal, // Set the text color to teal
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            color: Colors.blue,
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddDailyRoundPage(
                                                    patient: widget.patient,
                                                    dailyRound: dailyRound.data() as Map<String, dynamic>,  // Extracting data from QueryDocumentSnapshot
                                                    documentId: dailyRound.id,  // Passing documentId
                                                    isEditMode: true,  // Flag to indicate edit mode
                                                  ),
                                                ),
                                              );
                                            },
                                          ),


                                          IconButton(
                                            color: Colors.red,
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              _deleteDailyRound(
                                                  context, dailyRound.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

  void _showEditDialogInPatientScreen(
      BuildContext context,
      QueryDocumentSnapshot dailyRound,
      ) {
    String date = dailyRound['date'];
    List<dynamic> tasks = List.from(dailyRound['tasks']); // استنساخ القائمة لتفادي التعديل المباشر على الأصلية
    String documentId = dailyRound.id;

    String selectedMedication = dailyRound['medication'];
    bool isStopped = dailyRound['is_stopped'] ?? false;

    String findings = dailyRound['findings'] ?? '';
    String assessment = dailyRound['assessment'] ?? '';
    String comment = dailyRound['comment'] ?? '';
    String dischargePlan = dailyRound['discharge_plan'] ?? '';
    String doctorName = dailyRound['doctor_name'] ?? '';
    String reason = dailyRound['reason'] ?? '';
    String reply = dailyRound['reply'] ?? '';

    stt.SpeechToText _speech = stt.SpeechToText();
    List<DropdownMenuItem<String>> dropdownItems = [];

    TextEditingController findingsController = TextEditingController(text: findings);
    TextEditingController assessmentController = TextEditingController(text: assessment);
    TextEditingController commentController = TextEditingController(text: comment);
    TextEditingController dischargePlanController = TextEditingController(text: dischargePlan);
    TextEditingController doctorNameController = TextEditingController(text: doctorName);
    TextEditingController reasonController = TextEditingController(text: reason);
    TextEditingController replyController = TextEditingController(text: reply);

    // Initialize listening states for each field
    Map<String, bool> listeningStates = {
      'findings': false,
      'assessment': false,
      'comment': false,
      'dischargePlan': false,
      'doctorName': false,
      'reason': false,
      'reply': false,
    };

    Future<void> loadMedications() async {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where('sick_id', isEqualTo: widget.patient.id)
          .get();
      snapshot.docs.forEach((doc) {
        if (!doc['is_stopped']) {
          dropdownItems.add(DropdownMenuItem(
            child: Text(doc['medication_title']),
            value: doc['medication_title'],
          ));
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: loadMedications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                Future<void> _startListening(TextEditingController controller, String field) async {
                  bool available = await _speech.initialize();
                  if (available) {
                    setState(() {
                      listeningStates[field] = true;
                    });
                    _speech.listen(
                      onResult: (result) {
                        setState(() {
                          controller.text = '${controller.text} ${result.recognizedWords}'.trim();
                        });
                      },
                      listenFor: Duration(minutes: 1),
                    );
                  }
                }

                void _stopListening(String field) {
                  if (listeningStates[field] == true) {
                    _speech.stop();
                    setState(() {
                      listeningStates[field] = false;
                    });
                  }
                }

                void _toggleListening(TextEditingController controller, String field) {
                  if (listeningStates[field] == true) {
                    _stopListening(field);
                  } else {
                    _startListening(controller, field);
                  }
                }

                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  title: Text(
                    'Edit Daily Round',
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Widget for selecting date (date)
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            onTap: () async {
                              DateTime selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2025),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  date = '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
                                });
                              }
                            },
                            readOnly: true,
                            controller: TextEditingController(text: date),
                            decoration: InputDecoration(
                              hintText: 'Select Date',
                              suffixIcon: Icon(Icons.calendar_today),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: selectedMedication,
                          items: dropdownItems,
                          onChanged: (value) {
                            setState(() {
                              selectedMedication = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Select Medication',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Checkbox to indicate if the medication is stopped
                        Row(
                          children: [
                            Checkbox(
                              value: isStopped,
                              onChanged: (value) {
                                setState(() {
                                  isStopped = value ?? false;
                                });
                              },
                            ),
                            Text('Is Medication Stopped?'),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Widget for entering tasks (tasks)
                        Column(
                          children: tasks.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> task = entry.value;
                            TextEditingController taskController = TextEditingController(text: task['task']);
                            return Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: task['completed'] ?? false,
                                          onChanged: (value) {
                                            setState(() {
                                              tasks[index]['completed'] = value;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: TextField(
                                            onChanged: (value) {
                                              tasks[index]['task'] = value;
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Enter Task ${index + 1}',
                                              border: InputBorder.none,
                                            ),
                                            controller: taskController,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _toggleListening(taskController, 'task$index'),
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor: listeningStates['task$index'] == true ? Colors.red : Colors.teal,
                                            child: Icon(
                                              listeningStates['task$index'] == true ? Icons.pause : Icons.mic,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      tasks.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        // Button to add new task
                        Center(
                          child: Text(
                            '(Add Task from "+" icon)',
                            style: TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14, // يمكنك تعديل الحجم إذا لزم الأمر
                            ),
                            textAlign: TextAlign.center, // محاذاة النص في الوسط
                          ),
                        ),

                        SizedBox(height: 8),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              tasks.add({'task': '', 'completed': false});
                              listeningStates['task${tasks.length - 1}'] = false;
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        // Instruction Section Header
                        Text(
                          'Instruction',
                          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),

                        // Findings
                        _buildVoiceInputField('Findings', findingsController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 8),

                        // Assessment
                        _buildVoiceInputField('Assessment', assessmentController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 8),

                        // Comment
                        _buildVoiceInputField('Comment', commentController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 8),

                        // Discharge Plan
                        _buildVoiceInputField('Discharge Plan', dischargePlanController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 16),

                        // Consultation Section Header
                        Text(
                          'Consultation',
                          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),

                        // Doctor Name
                        _buildVoiceInputField('Doctor Name', doctorNameController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 8),

                        // Reason
                        _buildVoiceInputField('Reason', reasonController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 16),
                        _buildVoiceInputField('Reply', replyController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 16),

                        // Button to save daily round data to Firestore
                        ElevatedButton(
                          onPressed: () async {
                            // Validate date and tasks
                            if (date.isEmpty || tasks.isEmpty) {
                              return; // Do nothing if date or tasks are empty
                            }

                            // Start a batch write
                            WriteBatch batch = FirebaseFirestore.instance.batch();

                            // Update daily_rounds collection
                            DocumentReference dailyRoundRef = FirebaseFirestore.instance.collection('daily_rounds').doc(documentId);
                            batch.update(dailyRoundRef, {
                              'date': date,
                              'tasks': tasks,
                              'medication': selectedMedication ?? '',
                              'is_stopped': isStopped ?? false,
                              'findings': findingsController.text,
                              'assessment': assessmentController.text,
                              'comment': commentController.text,
                              'discharge_plan': dischargePlanController.text,
                              'doctor_name': doctorNameController.text,
                              'reason': reasonController.text,
                              'reply': replyController.text,
                            });

                            // Update medications collection
                            QuerySnapshot medicationSnapshot = await FirebaseFirestore.instance
                                .collection('medications')
                                .where('sick_id', isEqualTo: widget.patient.id)
                                .where('medication_title', isEqualTo: selectedMedication)
                                .get();

                            if (medicationSnapshot.docs.isNotEmpty) {
                              DocumentReference medicationRef = medicationSnapshot.docs.first.reference;
                              batch.update(medicationRef, {
                                'is_stopped': isStopped ?? false,
                              });
                            }

                            try {
                              // Commit the batch
                              await batch.commit();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Daily round updated successfully'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                              Navigator.pop(context); // إغلاق الحوار الفرعي
                            } catch (error) {
                              print('Failed to update daily round: $error');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update daily round'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text('Update'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.teal, // لون الزر
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildVoiceInputField(
      String hintText,
      TextEditingController controller,
      StateSetter setState,
      Map<String, bool> listeningStates,
      Function toggleListening) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  // تحديث واجهة المستخدم عند تغيير النص
                });
              },
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
              controller: controller,
              maxLines: null, // السماح بالتمدد العمودي
              minLines: 1, // سطر واحد في البداية
              keyboardType: TextInputType.multiline, // تمكين الإدخال متعدد الأسطر
              scrollPhysics: BouncingScrollPhysics(), // لتمكين التمرير العمودي
            ),
          ),
          GestureDetector(
            onTap: () {
              toggleListening(controller, hintText.toLowerCase());
            },
            child: CircleAvatar(
              radius: 15,
              backgroundColor: listeningStates[hintText.toLowerCase()] == true
                  ? Colors.red
                  : Colors.teal,
              child: Icon(
                listeningStates[hintText.toLowerCase()] == true
                    ? Icons.pause
                    : Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }







  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this medication?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق حوار التأكيد
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteMedication(docId); // استدعاء دالة الحذف
                Navigator.pop(context); // إغلاق حوار التأكيد
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  void _deleteMedication(String docId) {
    FirebaseFirestore.instance.collection('medications').doc(docId).delete().then((_) {
      print('Medication deleted successfully');
    }).catchError((error) {
      print('Failed to delete medication: $error');
    });
  }


    void _deleteReport(BuildContext context, String documentId) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // حواف مربعة ناعمة
            ),
            title: Text(
              'Confirm Deletion',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.red, // لون العنوان
              ),
            ),
            content: Text(
              'Are you sure you want to delete this Report?',
              style: TextStyle(
                fontSize: 16.0, // حجم النص
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق الحوار
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: teal, // لون النص
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Perform the deletion
                  FirebaseFirestore.instance
                      .collection('medical_reports')
                      .doc(documentId)
                      .delete()
                      .then((value) {
                    // Show success message using SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Report deleted successfully'),
                        duration:
                            Duration(seconds: 2), // Adjust duration as needed
                        backgroundColor: Colors.green, // لون الخلفية
                      ),
                    );

                    // Handle successful deletion (optional)
                    // For example, you can trigger any necessary updates or actions here
                  }).catchError((error) {
                    // Handle deletion error
                    print('Failed to delete document: $error');
                    // You can display an error message using SnackBar as well
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete report'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red, // لون الخلفية
                      ),
                    );
                  });

                  Navigator.of(context).pop(); // إغلاق الحوار
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white, // لون النص
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // لون الزر
                ),
              ),
            ],
          );
        },
      );
    }

    void _deleteDailyRound(BuildContext context, String documentId) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // حواف مربعة ناعمة
            ),
            title: Text(
              'Confirm Deletion',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.red, // لون العنوان
              ),
            ),
            content: Text(
              'Are you sure you want to delete this daily round?',
              style: TextStyle(
                fontSize: 16.0, // حجم النص
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق الحوار
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: teal, // لون النص
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Perform the deletion
                  FirebaseFirestore.instance
                      .collection('daily_rounds')
                      .doc(documentId)
                      .delete()
                      .then((value) {
                    // Show success message using SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Daily round deleted successfully'),
                        duration:
                            Duration(seconds: 2), // Adjust duration as needed
                        backgroundColor: Colors.green, // لون الخلفية
                      ),
                    );

                    // Handle successful deletion (optional)
                    // For example, you can trigger any necessary updates or actions here
                  }).catchError((error) {
                    // Handle deletion error
                    print('Failed to delete document: $error');
                    // You can display an error message using SnackBar as well
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete daily round'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red, // لون الخلفية
                      ),
                    );
                  });

                  Navigator.of(context).pop(); // إغلاق الحوار
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white, // لون النص
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // لون الزر
                ),
              ),
            ],
          );
        },
      );
    }

  void _showAddDailyRoundDialog() {
    String newDate = '';
    List<Map<String, dynamic>> newTasks = [];
    String selectedMedication;
    bool isStopped = false;
    String findings = '';
    String assessment = '';
    String comment = '';
    String dischargePlan = '';
    String doctorName = '';
    String reason = '';
    String reply = '';
    stt.SpeechToText _speech = stt.SpeechToText();
    List<DropdownMenuItem<String>> dropdownItems = [];

    TextEditingController findingsController = TextEditingController();
    TextEditingController assessmentController = TextEditingController();
    TextEditingController commentController = TextEditingController();
    TextEditingController dischargePlanController = TextEditingController();
    TextEditingController doctorNameController = TextEditingController();
    TextEditingController reasonController = TextEditingController();
    TextEditingController replyController = TextEditingController();

    // Initialize listening states for each field
    Map<String, bool> listeningStates = {
      'findings': false,
      'task': false,
      'assessment': false,
      'comment': false,
      'dischargePlan': false,
      'doctorName': false,
      'reason': false,
      'reply': false,
    };

    Future<void> loadMedications() async {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where('sick_id', isEqualTo: widget.patient.id)
          .get();
      snapshot.docs.forEach((doc) {
        if (!doc['is_stopped']) {
          dropdownItems.add(DropdownMenuItem(
            child: Text(doc['medication_title']),
            value: doc['medication_title'],
          ));
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: loadMedications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                Future<void> _startListening(TextEditingController controller, String field) async {
                  bool available = await _speech.initialize();
                  if (available) {
                    setState(() {
                      listeningStates[field] = true;
                    });

                    String originalText = controller.text; // تخزين النص الأصلي في بداية الاستماع
                    List<String> recognizedWordsList = []; // لتتبع الكلمات المعترف بها بشكل فردي

                    _speech.listen(
                      onResult: (result) {
                        setState(() {
                          String currentRecognizedWords = result.recognizedWords.trim(); // تنظيف وتقليم النص المعترف به
                          List<String> currentWords = currentRecognizedWords.split(' '); // تقسيم النص إلى كلمات

                          // تحديد الكلمات الجديدة التي لم تُعترف بها من قبل
                          List<String> newWords = currentWords.where((word) => !recognizedWordsList.contains(word)).toList();

                          if (newWords.isNotEmpty) {
                            controller.text = originalText + (originalText.isEmpty ? "" : " ") + newWords.join(' '); // إضافة الكلمات الجديدة فقط
                            originalText = controller.text; // تحديث النص الأصلي بالكامل
                            recognizedWordsList.addAll(newWords); // إضافة الكلمات الجديدة إلى قائمة الكلمات المعترف بها
                          }
                        });
                      },
                      listenFor: Duration(minutes: 1),
                    );
                  }
                }

                void _stopListening(String field) {
                  if (listeningStates[field] == true) {
                    _speech.stop();
                    setState(() {
                      listeningStates[field] = false;
                    });
                  }
                }

                void _toggleListening(TextEditingController controller, String field) {
                  if (listeningStates[field] == true) {
                    _stopListening(field);
                  } else {
                    _startListening(controller, field);
                  }
                }



                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  title: Text(
                    'Add Daily Round',
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Widget for selecting date (newDate)
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            onTap: () async {
                              DateTime selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2025),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  newDate =
                                  '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
                                });
                              }
                            },
                            readOnly: true,
                            controller: TextEditingController(text: newDate),
                            decoration: InputDecoration(
                              hintText: 'Select Date',
                              suffixIcon: Icon(Icons.calendar_today),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: selectedMedication,
                          items: dropdownItems,
                          onChanged: (value) {
                            setState(() {
                              selectedMedication = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Select Medication',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Widget for entering tasks (newTasks)
                        Column(
                          children: newTasks.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> task = entry.value;
                            TextEditingController taskController = TextEditingController(text: task['task']);
                            return Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: task['completed'] ?? false,
                                          onChanged: (value) {
                                            setState(() {
                                              newTasks[index]['completed'] = value;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: TextField(
                                            onChanged: (value) {
                                              newTasks[index]['task'] = value;
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Enter Task ${index + 1}',
                                              border: InputBorder.none,
                                            ),
                                            controller: taskController,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _toggleListening(taskController, 'task$index'),
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor: listeningStates['task$index'] == true ? Colors.red : Colors.teal,
                                            child: Icon(
                                              listeningStates['task$index'] == true ? Icons.pause : Icons.mic,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      newTasks.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        // Button to add new task
                        Center(
                          child: Text(
                            '(Add Task from "+" icon)',
                            style: TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14, // يمكنك تعديل الحجم إذا لزم الأمر
                            ),
                            textAlign: TextAlign.center, // محاذاة النص في الوسط
                          ),
                        ),

                        SizedBox(height: 8),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              newTasks.add({'task': '', 'completed': false});
                              listeningStates['task${newTasks.length - 1}'] = false;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        // Instruction Section Header
                        Text(
                          'Instruction',
                          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),

                        // Findings
                        _buildVoiceInputField('Findings', findingsController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 8),

                        // Assessment
                        _buildVoiceInputField('Assessment', assessmentController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 8),

                        // Comment
                        _buildVoiceInputField('Comment', commentController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 8),

                        // Discharge Plan
                        _buildVoiceInputField('Discharge Plan', dischargePlanController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 16),

                        // Consultation Section Header
                        Text(
                          'Consultation',
                          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),

                        // Doctor Name
                        _buildVoiceInputField('Doctor Name', doctorNameController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 8),

                        // Reason
                        _buildVoiceInputField('Reason', reasonController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 16),
                        _buildVoiceInputField('Reply', replyController, setState, listeningStates, _toggleListening),
                        SizedBox(height: 16),

                        // Button to save daily round data to Firestore
                        ElevatedButton(
                          onPressed: () {
                            // Validate only the essential fields (e.g., newDate)
                            if (newDate.isEmpty) {
                              return; // Do nothing if date is empty
                            }

                            // Create the data map to upload to Firestore
                            Map<String, dynamic> dailyRoundData = {
                              'date': newDate,
                              'patientId': widget.patient.id,
                              'tasks': newTasks.isNotEmpty ? newTasks : [], // إذا كانت المهام فارغة، أرسل قائمة فارغة
                              'medication': selectedMedication ?? '', // حفظ فارغ إذا لم يكن هناك دواء مختار
                              'is_stopped': isStopped,
                              'findings': findingsController.text.isNotEmpty ? findingsController.text : '', // حفظ فارغ إذا كان الحقل فارغًا
                              'assessment': assessmentController.text.isNotEmpty ? assessmentController.text : '',
                              'comment': commentController.text.isNotEmpty ? commentController.text : '',
                              'discharge_plan': dischargePlanController.text.isNotEmpty ? dischargePlanController.text : '',
                              'doctor_name': doctorNameController.text.isNotEmpty ? doctorNameController.text : '',
                              'reason': reasonController.text.isNotEmpty ? reasonController.text : '',
                              'reply': replyController.text.isNotEmpty ? replyController.text : '',
                            };

                            // Upload data to Firestore
                            FirebaseFirestore.instance.collection('daily_rounds').add(dailyRoundData).then((value) {
                              Navigator.pop(context); // Close dialog on success
                            }).catchError((error) {
                              // Handle error
                              print('Failed to add daily round: $error');
                            });
                          },
                          child: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Widget _buildVoiceInputField(String hintText, TextEditingController controller, StateSetter setState, Map<String, bool> listeningStates, Function toggleListening) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 8),
  //     padding: EdgeInsets.all(8),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[200],
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: TextField(
  //             onChanged: (value) {
  //               setState(() {
  //                 // Here we don't need to do anything, just updating the UI
  //               });
  //             },
  //             decoration: InputDecoration(
  //               hintText: hintText,
  //               border: InputBorder.none,
  //             ),
  //             maxLines: 2,
  //             controller: controller,
  //           ),
  //         ),
  //         GestureDetector(
  //           onTap: () {
  //             toggleListening(controller, hintText.toLowerCase());
  //           },
  //           child: CircleAvatar(
  //             radius: 15,
  //             backgroundColor: listeningStates[hintText.toLowerCase()] == true ? Colors.red : Colors.teal,
  //             child: Icon(
  //               listeningStates[hintText.toLowerCase()] == true ? Icons.pause : Icons.mic,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _deleteConsentt(BuildContext context, String documentId) {
    // طباعة معرف المستند للتحقق منه
    print('Deleting document with ID: $documentId');

    // عرض رسالة التأكيد
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this consent?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق حوار التأكيد
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // إذا تم التأكيد، احذف الوثيقة من Firestore
                FirebaseFirestore.instance
                    .collection('consebts') // تحقق من اسم المجموعة هنا
                    .doc(documentId)
                    .delete()
                    .then((_) {
                  print('Document deleted successfully'); // تأكيد الحذف

                  // إغلاق حوار التأكيد
                  Navigator.pop(context);

                  // عرض رسالة النجاح
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Consent deleted successfully')),
                  );
                }).catchError((error) {
                  // طباعة الخطأ المفصل
                  print('Failed to delete document: $error');

                  // إغلاق حوار التأكيد
                  Navigator.pop(context);

                  // عرض رسالة الخطأ
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete consent: $error')),
                  );
                });
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }



  void _confirmDeletev(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this vaccination record?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق حوار التأكيد
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteVaccination(docId); // استدعاء دالة الحذف
                Navigator.pop(context); // إغلاق حوار التأكيد
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteVaccination(String docId) {
    FirebaseFirestore.instance.collection('vaccinations').doc(docId).delete().then((_) {
      print('Vaccination record deleted successfully');
    }).catchError((error) {
      print('Failed to delete vaccination record: $error');
    });
  }

  Future<void> shareMedication(text, title) async {
      await FlutterShare.share(
          title: 'Medication',
          text: ' $text \n $title\n',
          chooserTitle: 'Share with');
    }
  }
