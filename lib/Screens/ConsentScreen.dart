// import 'package:dio/dio.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:rounds/AddScreens/AddConsentScreen.dart';
// import 'package:rounds/Models/VideoCardInfo.dart';
// import 'package:rounds/Network/DoctorSicksModel.dart';
// import 'package:rounds/Network/SickModel.dart';
// import 'package:rounds/Network/SuccessModel.dart';
// import 'package:flutter/material.dart';
// import 'package:connectivity/connectivity.dart';
// import 'package:rounds/colors.dart';
// import 'package:rounds/component.dart';
// import 'ConsentDetailsScreen.dart';
//
// class ConsentScreen extends StatefulWidget {
//   List<Consebt> consebt;
//   int id;
//   DoctorSicks patient;
//
//   ConsentScreen(this.consebt, this.id,this.patient);
//
//   @override
//   _ConsentScreenState createState() => _ConsentScreenState();
// }
//
// class _ConsentScreenState extends State<ConsentScreen> {
//   Future<bool> check() async {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.mobile) {
//       return true;
//     } else if (connectivityResult == ConnectivityResult.wifi) {
//       return true;
//     }
//     return false;
//   }
//
//   final String KEY = 'os14042020ah';
//   final String ACTIONDELETE = 'delete-sick-consebt';
//
//   internetMessage(BuildContext context) {
//     // set up the button
//     Widget okButton = TextButton(
//       child: Text("OK"),
//       onPressed: () {
//         Navigator.pop(context);
//         Navigator.pop(context);
//       },
//     );
//
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text("Connection Error"),
//       content: Text("please check your internet connection"),
//       actions: [
//         okButton,
//       ],
//     );
//
//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   successMessage(BuildContext context) {
//     // set up the button
//     Widget okButton = TextButton(
//       child: Text("OK"),
//       onPressed: () {
//         Navigator.pop(context);
//       },
//     );
//
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text("Success"),
//       content: Text(""),
//       actions: [
//         okButton,
//       ],
//     );
//
//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   errorMessage(BuildContext context) {
//     // set up the button
//     Widget okButton = TextButton(
//       child: Text("OK"),
//       onPressed: () {
//         Navigator.pop(context);
//       },
//     );
//
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text("ERROR"),
//       content: Text("something went wrong"),
//       actions: [
//         okButton,
//       ],
//     );
//
//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   edit(context, title, description, index) async {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) =>
//                 AddConsentScreen(widget.id, title, description, index)));
//   }
//
//   delete(context, index, indexList) async {
//     try {
//       FormData formData = FormData.fromMap({
//         "action": ACTIONDELETE,
//         "key": KEY,
//         "index": index,
//         "sick_id": widget.patient.id,
//       });
//
//       Response response =
//           await Dio().post("https://medicall-rounds.com/api", data: formData);
//
//       SuccessModel successModel = SuccessModel.fromJson(response.data);
//
//       if (successModel.st == 'success') {
//         setState(() {
//           widget.consebt.removeAt(indexList);
//         });
//       } else {
//         Fluttertoast.showToast(
//             msg: "Please try again ..",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.grey,
//             textColor: Colors.white,
//             fontSize: 16.0);
//       }
//     } catch (e) {
//       print("Exception Caught : $e");
//     }
//   }
//   getSick() async {
//     print(widget.id.toString());
//     try {
//       Response response = await Dio().get(
//           "https://medicall-rounds.com/api/?key=os14042020ah&action=get-sick-data&sick-id=${widget.patient.id}");
//       setState(() {
//         widget.patient = DoctorSicks.fromJson(response.data);
//       });
//     } catch (e) {
//       Fluttertoast.showToast(
//           msg: "Please try again ..",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.grey,
//           textColor: Colors.white,
//           fontSize: 16.0
//       );
//       print("Exception Caught : $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.of(context).size.height;
//     return Column(
//       children: <Widget>[
//         (widget.consebt == null || widget.consebt?.length == 0)
//             ? Container(
//           height: height,
//           child: RefreshIndicator(
//             onRefresh: ()async{
//               getSick();
//               setState(() {
//                   widget.consebt=widget.patient.consebt;
//               });
//             },
//             child: RefreshIndicator(
//               onRefresh: ()async{
//                 getSick();
//                 setState(() {
//                     widget.consebt=widget.patient.consebt;
//                 });
//               },
//               child: ListView(
//                 children: <Widget>[
//                   SizedBox(height: height*0.3,),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Center(
//                       child: Text(
//                         'No Consent Illustration Found',
//                         style: style,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         )
//             : RefreshIndicator(
//           onRefresh: ()async{
//             getSick();
//             setState(() {
//                 widget.consebt=widget.patient.consebt;
//             });
//           },
//               child: ListView.builder(
//                   scrollDirection: Axis.vertical,
//                   shrinkWrap: true,
//                //   physics: ClampingScrollPhysics(),
//                   itemCount: widget.consebt.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                         onTap: () {
//                           check().then((intenet) {
//                             if (intenet != null && intenet) {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => ConsentDetailsScreen(
//                                           widget.consebt[index].video,
//                                           widget.consebt[index].title,
//                                           widget.consebt[index].audio, widget.consebt[index],)));
//                             } else {
//                               internetMessage(context);
//                             }
//                           });
//                         },
//                         child: VideoCardInfo(
//                             name: widget.consebt[index].title,
//                             img: widget.consebt[index].image.isEmpty ? ['images/play.png'] : widget.consebt[index].image,
//                             desc: widget.consebt[index].description,
//                             context: context,
//                             index: widget.consebt[index].index,
//                             indexInList: index,
//                             delete: delete,
//                             edit: edit));
//                   }),
//             ),
//       ],
//     );
//   }
// }
