// import 'package:dio/dio.dart';
// import 'package:rounds/AddScreens/AddDoctorToTeamScreen.dart';
// import 'package:rounds/BottomNavigationBarItems/MyPatients.dart';
// import 'package:rounds/Models/TeamsCards.dart';
// import 'package:rounds/Network/TeamsModel.dart';
// import 'package:rounds/Status/DoctorID.dart';
// import 'package:flutter/material.dart';
//
// class TeamWork extends StatefulWidget {
//   @override
//   _TeamWorkState createState() => _TeamWorkState();
// }
//
// class _TeamWorkState extends State<TeamWork> {
//   bool showSicks = false;
//   List<TeamsModel> teamList = [];
//
//   getDoctorTeams() async {
//     Response response = await Dio().get(
//         "https://medicall-rounds.com/api/?key=os14042020ah&action=get-doctor-team&doctor-id=${await DoctorID().readID()}");
//
//     var data = response.data;
//     teamList.clear();
//     setState(() {
//       teamList.add(TeamsModel.fromJson(data));
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     setState(() {
//       getDoctorTeams();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     setState(() {
//       getDoctorTeams();
//     });
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       child: WillPopScope(
//         onWillPop: () {
//           if (!showSicks) {
//             Navigator.pop(context);
//           } else {
//             setState(() {
//               showSicks = false;
//             });
//           }
//
//           return null;
//         },
//         child: Scaffold(
//           body: showSicks
//               ? MyPatients()
//               : Column(
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 15, vertical: 15),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Row(
//                             children: <Widget>[
//                               ImageIcon(
//                                 AssetImage("images/icons/teamwork.png"),
//                                 color: Color(0xFF1ad7e8),
//                               ),
//                               Text(' Your Team'),
//                             ],
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(30),
//                                 color: Color(0xff1e3be8)),
//                             child: TextButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               AddDoctorToTeamScreen()));
//                                 },
//                                 child: Text(
//                                   'Add Doctor',
//                                   style: TextStyle(
//                                     color: const Color(0xffffffff),
//                                   ),
//                                 )),
//                           )
//                         ],
//                       ),
//                     ),
//                     (teamList?.length == 0 || teamList[0].team?.length == null)
//                         ? SizedBox(
//                             width: MediaQuery.of(context).size.height * .2,
//                             height: MediaQuery.of(context).size.height * .3,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: <Widget>[Text('No Data Found')],
//                             ),
//                           )
//                         : ListView.builder(
//                             scrollDirection: Axis.vertical,
//                             shrinkWrap: true,
//                             physics: ClampingScrollPhysics(),
//                             itemCount: teamList[0].team.length,
//                             itemBuilder: (context, index) {
//                               // return  TeamsCards(teamList[0].team[index].avatar,teamList[0].team[index].name);
//                             })
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }
