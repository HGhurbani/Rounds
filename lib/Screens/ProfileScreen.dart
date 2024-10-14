// import 'package:dio/dio.dart';
// import 'package:flutter_share/flutter_share.dart';
// import 'package:rounds/AddScreens/AddConsentScreen.dart';
// import 'package:rounds/AddScreens/AddReportScreen.dart';
// import 'package:rounds/Network/DoctorDataModel.dart';
// import 'package:rounds/Network/DoctorSicksModel.dart';
// import 'package:rounds/Screens/sickDailyRound.dart';
// import 'package:rounds/Models/profile_patient_card.dart';
// import 'package:rounds/Network/SickModel.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:rounds/colors.dart';
// import 'package:rounds/component.dart';
// import 'ConsentScreen.dart';
// import 'GeneralProfileScreen.dart';
// import 'package:rounds/Screens/ReportScreen.dart';
// import 'package:rounds/Screens/DailryRoundScreen.dart';
// import 'HomeScreen.dart';
// import 'RayScreen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   final int id;
//   final DoctorSicks patient;
//
//   const ProfileScreen({Key key, this.id, this.patient}) : super(key: key);
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   bool loaded = false;
//   bool isSelectedGeneral = true;
//   bool isSelectedConsent = false;
//   bool isSelectedDaily = false;
//   bool isSelectedReport = false;
//   DoctorSicks patient;
//   double itemHeight;
//   double itemWidth;
//   var size;
//   Widget body;
//
//   Future<void> share() async {
//     await FlutterShare.share(
//         title: '${patient.name} data',
//         text:
//             'Name : ${patient.name}\n File number : ${patient.fileNumber}\n Age : ${patient.age}\n Gender : ${patient.gender}\n'
//             ' Date of Admission : ${patient.dateOfAdmission}\n Date of Discharge : ${patient.dateOfDischarge}\n'
//             ' Diagnosis : ${patient.diagnosis}\n Height : ${patient.height}\n'
//             ' Weight : ${patient.weight}\n Blood Group : ${patient.bloodGroup}\n'
//             ' Past medical history : ${patient.medicalHistory}\n Past surgical history : ${patient.surgicalHistory}\n'
//             ' Smoking : ${patient.smoking}\n Alcohol : ${patient.alcohol}\n',
//         chooserTitle: 'Share with');
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//
//   Widget generalProfileScreen(DoctorSicks patient, int id) {
//     return GeneralProfileScreen(patient, id);
//   }
//
//   Widget consent(DoctorSicks patient, int id) {
//     return ConsentScreen(patient.consebt, id, patient);
//   }
//
//   Widget report(DoctorSicks patient, int id) {
//     return ReportScreen(id, patient);
//   }
//
//   Widget dailryRoundScreen(DoctorSicks patient, id) {
//     return PlanScreen(patient, id);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     size = MediaQuery.of(context).size;
//     itemHeight = (size.height) / 2;
//     itemWidth = size.width / 2;
//     isSelectedGeneral
//         ? body = generalProfileScreen(patient, widget.id)
//         : Container();
//     return Scaffold(
//         floatingActionButton: isSelectedGeneral
//             ? null
//             : FloatingActionButton(
//                 onPressed: () {
//                   if (isSelectedDaily) {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => DailyRound(
//                                 patient: patient,
//                                 id: widget.id,
//                                 operation: "add")));
//                   } else if (isSelectedConsent) {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>
//                                 AddConsentScreen(widget.id, "", "", 0)));
//                   } else if (isSelectedReport) {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => AddReportScreen(
//                                 widget.id, patient, "", "", 0)));
//                   }
//                 },
//                 child: Icon(Icons.add),
//                 backgroundColor: teal,
//               ),
//         appBar: AppBar(
//           //title: Text("Sick Profile"),
//           backgroundColor: teal,
//           actions: <Widget>[
//             GestureDetector(
//                 onTap: () {
//                   share();
//                 },
//                 child: Icon(Icons.share))
//           ],
//           elevation: 0,
//         ),
//         body: loaded
//             ? Stack(
//                 children: <Widget>[
//                   headApp(),
//                   RefreshIndicator(
//                     onRefresh: () async {},
//                     child: Container(
//                       child: ListView(
//                         children: <Widget>[
//                           Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 10.0),
//                             child: ProfilePatientCard(
//                               widget.patient,
//                             ),
//                           ),
//                           Container(
//                             height: MediaQuery.of(context).size.height * .07,
//                             child: ListView(
//                               physics: BouncingScrollPhysics(),
//                               scrollDirection: Axis.horizontal,
//                               children: <Widget>[
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16, top: 4, right: 6, bottom: 4),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(8),
//                                         color:
//                                             isSelectedGeneral ? orange : teal),
//                                     child: TextButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             isSelectedDaily = false;
//                                             isSelectedConsent = false;
//                                             isSelectedReport = false;
//                                             isSelectedGeneral = true;
//                                             body = generalProfileScreen(
//                                                 patient, widget.id);
//                                           });
//                                         },
//                                         child: Text(
//                                           'General information',
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18),
//                                         )),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 6, vertical: 4),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(8),
//                                         color: isSelectedDaily ? orange : teal),
//                                     child: TextButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             isSelectedDaily = true;
//                                             isSelectedConsent = false;
//                                             isSelectedReport = false;
//                                             isSelectedGeneral = false;
//                                             body = dailryRoundScreen(
//                                                 patient, widget.id);
//                                           });
//                                         },
//                                         child: Text(
//                                           'Daily round',
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18),
//                                         )),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 6,
//                                     vertical: 4,
//                                   ),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(8),
//                                         color:
//                                             isSelectedConsent ? orange : teal),
//                                     child: TextButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             isSelectedDaily = false;
//                                             isSelectedConsent = true;
//                                             isSelectedReport = false;
//                                             isSelectedGeneral = false;
//                                             body = consent(patient, widget.id);
//                                           });
//                                         },
//                                         child: Text(
//                                           'Consent Illustration',
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18),
//                                         )),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 6, top: 4, right: 16, bottom: 4),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(8),
//                                         color:
//                                             isSelectedReport ? orange : teal),
//                                     child: TextButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             isSelectedDaily = false;
//                                             isSelectedConsent = false;
//                                             isSelectedReport = true;
//                                             isSelectedGeneral = false;
//                                             body = report(patient, widget.id);
//                                           });
//                                         },
//                                         child: Text(
//                                           'Medical Report',
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18),
//                                         )),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           body,
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             : Center(
//                 child: CircularProgressIndicator(color: teal),
//               ));
//   }
// }
