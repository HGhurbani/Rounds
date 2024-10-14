import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rounds/AddScreens/AddSickScreen.dart';
import 'package:rounds/colors.dart';
import 'package:rounds/component.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/patient_card.dart';
import '../Network/DoctorDataModel.dart';
import '../Network/DoctorSicksModel.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'ProfileScreen.dart';

import 'PatientDetailScreen.dart';

class PatientListScreen extends StatefulWidget {
  final DoctorData doctor;
  final List<DoctorSicks> filteredSick;
  DoctorSicks patient;
  String doctorId = '';

  PatientListScreen(this.doctor, this.filteredSick);

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  String _searchText = "";
  String doctorId = '';
  TextEditingController _filter = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDoctorId();
    _showFirstTimeMessage();
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

  Future<void> _showFirstTimeMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime_PatientListScreen') ?? true;

    if (isFirstTime) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            title: Text(
              'Welcome to Patient List',
              style: TextStyle(color: teal),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Here you can view and manage all patient records.'),
                SizedBox(height: 10),
                Text('1. Use the search icon to find specific patients.'),
                Text('2. Click on a patient card to view detailed information.'),
                Text('3. Use the "+" button to add new patient records.'),
                Text('4. You can edit or delete patient records from the detail view.'),
                SizedBox(height: 20),
                Text('You can manage all patient data here.'),
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

      await prefs.setBool('isFirstTime_PatientListScreen', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: teal,
        title: Text('My Patients'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSickScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filter,
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Enter patient name or file number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('patients')
                  .where('share_id', isEqualTo: doctorId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: teal));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                  return Center(child: Text('No Patients Added', style: style));
                }

                final List<DoctorSicks> patientList = snapshot.data.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DoctorSicks(
                    id: data['id'],
                    name: data['name'],
                    age: data['age'],
                    gender: data['gender'],
                    alcohol: data['alcohol'],
                    weight: data['weight'],
                    bloodGroup: data['blood-group'],
                    height: data['height'],
                    status: data['status'],
                    surgery: data['surgery'],
                    medicalHistory: data['medical-history'],
                    surgicalHistory: data['surgical-history'],
                    diagnosis: data['diagnosis'],
                    allergies: data['allergies'],
                    fileNumber: data['file-number'],
                    dateOfDischarge: data['date-of-discharge'],
                    avatar: data['avatar'] ?? '',
                    temperature: data['temperature'] ?? '',
                    bloodPressure: data['blood-pressure'] ?? '',
                    sugarLevel: data['sugar-level'] ?? '',
                    occupation: data['occupation'],
                    smoking: data['smoking'],
                    dateOfAdmission: data['date-of-admission'],
                    createdAt: data['created-at'] as Timestamp,
                  );
                }).toList();

                final filteredList = _searchText.isEmpty
                    ? patientList
                    : patientList.where((patient) {
                  return patient.name.toLowerCase().contains(_searchText) ||
                      patient.fileNumber.toLowerCase().contains(_searchText);
                }).toList();

                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: GestureDetector(
                        onTap: () {
                          DoctorSicks selectedPatient = filteredList[index];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailScreen(
                                patient: selectedPatient,
                                id: selectedPatient.id.toString(),
                              ),
                            ),
                          );
                        },
                        child: PatientCard(
                          filteredList[index].avatar,
                          filteredList[index].name,
                          filteredList[index].fileNumber,
                          filteredList[index].bloodPressure,
                          '',
                          filteredList[index].temperature,
                          filteredList[index].bloodPressure,
                          filteredList[index].sugarLevel,
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
}
