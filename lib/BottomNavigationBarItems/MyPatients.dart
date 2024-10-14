// import 'package:dio/dio.dart';
// import 'package:rounds/Models/VerticalCards.dart';
// import 'package:rounds/Network/DoctorSicksModel.dart';
// import 'package:rounds/Screens/ProfileScreen.dart';
// import 'package:rounds/Status/DoctorID.dart';
// import 'package:flutter/material.dart';
//
// class MyPatients extends StatefulWidget {
//   @override
//   _MyPatientsState createState() => _MyPatientsState();
// }
//
// class _MyPatientsState extends State<MyPatients> {
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
//     super.initState();
//     getDoctorSicks();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     setState(() {
//       getDoctorSicks();
//     });
//     return Column(
//       children: <Widget>[
//         (sickList?.length == 0 || sickList?.length == null)
//             ? SizedBox(
//                 width: MediaQuery.of(context).size.height * .2,
//                 height: MediaQuery.of(context).size.height * .3,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                     Text('No Data Found')
//                   ],
//                 ),
//               )
//             : ListView.builder(
//                 scrollDirection: Axis.vertical,
//                 shrinkWrap: true,
//                 physics: ClampingScrollPhysics(),
//                 itemCount: sickList.length,
//                 itemBuilder: (cnt, index) {
//                   return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => ProfileScreen(id:sickList[index].id,patient:sickList[index])));
//                       },
//                       child: Cards(
//                           sickList[index].avatar.toString(),
//                           sickList[index].name,
//                           sickList[index].lastNote?.noteText == null
//                               ? 'No note found'
//                               : sickList[index].lastNote.noteText,
//                           sickList[index].lastNote?.noteDoctor == null
//                               ? 'No doctor note found'
//                               : sickList[index].lastNote?.noteDoctor,
//                           sickList[index].temperature,
//                           sickList[index].bloodPressure,
//                           sickList[index].sugarLevel));
//                 })
//       ],
//     );
//   }
// }
