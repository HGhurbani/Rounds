// import 'package:dio/dio.dart';
// import 'package:rounds/AddScreens/AddSickScreen.dart';
// import 'package:rounds/Models/VerticalCards.dart';
// import 'package:rounds/Network/DoctorSicksModel.dart';
// import 'package:rounds/Screens/ProfileScreen.dart';
// import 'package:rounds/Status/DoctorID.dart';
// import 'package:flutter/material.dart';
//
// class MyPatientsScreen extends StatefulWidget {
//   @override
//   _MyPatientsScreenState createState() => _MyPatientsScreenState();
// }
//
// class _MyPatientsScreenState extends State<MyPatientsScreen> {
//   List<DoctorSicks> sickList = [];
//   getDoctorSicks() async {
//     Response response = await Dio().get(
//         "https://medicall-rounds.com/api/?key=os14042020ah&action=get-doctor-sicks&doctor-id=${await DoctorID().readID()}");
//
//     var data = response.data;
//     sickList.clear();
//     setState(() {
//       for(var i in data) {
//         sickList.add(DoctorSicks.fromJson(i));
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getDoctorSicks();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     setState(() {
//       getDoctorSicks();
//
//     });
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("My Patients"),
//         ),
//         body: ListView(
//           scrollDirection: Axis.vertical,
//           children: <Widget>[
//             !(sickList?.length == 0 || sickList?.length == null)
//                 ? Padding(
//               padding: const EdgeInsets.only(top:15),
//               child: Column(
//                 children: <Widget>[
//                   Center(child: Text('No Data Found')),
//                   Padding(
//                     padding: EdgeInsets.only(top: 10),
//                     child: Container(
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: Colors.blue),
//
//                       child: TextButton(
//                       onPressed: (){
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (context) => AddSickScreen()));
//                       }
//                       ,child: Text("Add Patients",style: TextStyle(
//                           color:  Colors.white,fontSize: 20),
//                       )
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             )
//                 : ListView.builder(
//                     scrollDirection: Axis.vertical,
//                     shrinkWrap: true,
//                     physics: ClampingScrollPhysics(),
//                     itemCount: sickList.length,
//                     itemBuilder: (cnt, index) {
//                       return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => ProfileScreen(id:sickList[index].id,patient: sickList[index],)));
//                           },
//                           child: Cards(
//                               sickList[index].avatar.toString(),
//                               sickList[index].name,
//                               sickList[index].lastNote?.noteText == null
//                                   ? 'No note found'
//                                   : sickList[index].lastNote.noteText,
//                               sickList[index].lastNote?.noteDoctor == null
//                                   ? 'No doctor note found'
//                                   : sickList[index].lastNote?.noteDoctor,
//                               sickList[index].temperature,
//                               sickList[index].bloodPressure,
//                               sickList[index].sugarLevel,
//
//                           ));
//                     }),
//           ],
//         ),
//       ),
//     );
//   }
// }
