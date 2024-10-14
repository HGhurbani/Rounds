import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'ShowDailryRoundScreen.dart';


class DailryRoundScreenFromMenu extends StatefulWidget {

   final int id;

  DailryRoundScreenFromMenu( this.id);


  @override
  _DailryRoundScreenFromMenuState createState() => _DailryRoundScreenFromMenuState();
}

class Consultations{
  String to;
  String why;
  String replay;

  Consultations(this.to, this.why, this.replay);
}
class Plan{
  String text;
  String carried;

  Plan(this.text, this.carried);
}

class _DailryRoundScreenFromMenuState extends State<DailryRoundScreenFromMenu> {

  // Future<bool> check() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile) {
  //     return true;
  //   } else if (connectivityResult == ConnectivityResult.wifi) {
  //     return true;
  //   }
  //   return false;
  // }
  // internetMessage(BuildContext context) {
  //
  //   // set up the button
  //   Widget okButton = TextButton(
  //     child: Text("OK"),
  //     onPressed: () {
  //       Navigator.pop(context);
  //     },
  //   );
  //
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("Connection Error"),
  //     content: Text("please check your internet connection"),
  //     actions: [
  //       okButton,
  //     ],
  //   );
  //
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  bool isSelectedLaboratory = true;
  bool isSelectedRadiology = false;
  bool isSelectedNonRadiology = false;
  bool isSelectedVitalSigns = false;
  Widget body;
  SickModel sick;
  bool loaded = false;




  getSick() async {
    try {

      Response response = await Dio().get(
          "https://medicall-rounds.com/api/?key=os14042020ah&action=get-sick-data&sick-id=${widget.id}");

      sick = SickModel.fromJson(response.data);

      if (sick.st == 'success') {
        setState(() {
          loaded = true;
        });
      } else {
        setState(() {
          loaded = false;
        });
      }
    } catch (e) {
      print("Exception Caught : $e");
    }

  }
   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSick();
  }

  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;
  bool isChecked6 = false;
  bool isChecked7 = false;
  bool isChecked8 = false;
  bool isChecked9 = false;
  bool isChecked10 = false;
  bool error = false;

  String findings = "";
  String comments = "";
  String plan1 = "";
  String plan2 = "";
  String plan3 = "";
  String plan4 = "";
  String plan5 = "";
  String plan6 = "";
  String plan7 = "";
  String plan8 = "";
  String plan9 = "";
  String plan10 = "";
  String to = "";
  String why = "";
  String replay = " ";

  List<Consultations> consultations = List();
  List<Plan> plan = List();


  missingMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Check all inputs"),
      content: Text("please check findings and comments "),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  errorMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text("Check your connection or try again."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  successMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Success"),
      content: Text("Uploaded"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  internetMessage(BuildContext context) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Connection Error"),
      content: Text("please check your internet connection"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  upload(context,findings,comments) async {


    try {
      FormData formData = FormData.fromMap({
        "action": 'update-daily-round-form',
        "key": 'os14042020ah',
        "findings": findings,
        "comments":comments,
        "reminder":"empty",
        "plan":[
          for (var p in plan){
            "text":p.text,
            "carried":p.carried
          }
        ],
        "consultations":[
          for (var c in consultations){
            "to":c.to,
            "replay":c.replay,
            "why":c.why,
          }
        ],
        "sick_id":widget.id,
      });

      Response response =
      await Dio().post("https://medicall-rounds.com/api", data: formData);

      //var responseServer = jsonDecode(response.data);

      SuccessModel successModel = SuccessModel.fromJson(response.data);

      if (successModel.st == 'success') {

        successMessage(context);
        setState(() {
          error = false;
        });
      } else {
        setState(() {
          error = false;
        });
        errorMessage(context);
      }
    } catch (e) {
      print("Exception Caught : $e");
    }

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Daily Round"),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      onChanged: (val){
                        setState(() {
                          findings = val;
                        });
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Write Finding',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,top: 15),
                    child: Text(
                      'Plan :',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan1 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '1',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked1,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked1 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan2 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '2',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked2,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked2 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan3 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '3',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked3,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked3 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan4 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '4',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked4,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked4 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan5 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '5',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked5,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked5 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan6 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '6',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked6,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked6 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan7 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '7',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked7,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked7 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan8 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '8',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked8,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked8 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan9 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '9',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked9,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked9 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            onChanged: (val){
                              setState(() {
                                plan10 = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '10',
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text("Carried"),
                            Checkbox(
                              value: isChecked10,
                              onChanged: (bool value) {
                                setState(() {
                                  isChecked10 = value;
                                });
                              },

                            ),
                          ],
                        ),


                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      onChanged: (val){
                        setState(() {
                          comments = val;
                        });
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Write Comment',
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 10,top: 15),
                    child: Text(
                      'Consultations :',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10 , left: 10),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Text("To : ",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 18,
                                color: const Color(0xff000000),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                width: MediaQuery.of(context).size.width*.4,
                                child: TextField(
                                  onChanged: (val){
                                    to = val;
                                  },
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: 'Doctor name',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),


                        Row(
                          children: [
                            Text("Why : ",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 18,
                                color: const Color(0xff000000),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                width: MediaQuery.of(context).size.width*.4,
                                child: TextField(
                                  onChanged: (val){
                                    why = val;
                                  },
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: 'Write reason',
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),

                        Row(
                          children: [
                            Text("Replay : ",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 18,
                                color: const Color(0xff000000),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                width: MediaQuery.of(context).size.width*.4,
                                child: TextField(
                                  onChanged: (val){
                                    replay = val;
                                  },
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: 'replay',
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),

                      ],
                    ),
                  )


                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                        check().then((intenet) {
                          if (intenet != null && intenet) {
                            // Internet Present Case
                            if(findings.isEmpty || comments.isEmpty)
                            {
                              missingMessage(context);
                            }
                            else{
                              consultations.clear();
                              plan.clear();

                              plan.add(Plan(plan1, isChecked1.toString()));
                              plan.add(Plan(plan2, isChecked2.toString()));
                              plan.add(Plan(plan3, isChecked3.toString()));
                              plan.add(Plan(plan4, isChecked4.toString()));
                              plan.add(Plan(plan5, isChecked5.toString()));
                              plan.add(Plan(plan6, isChecked6.toString()));
                              plan.add(Plan(plan7, isChecked7.toString()));
                              plan.add(Plan(plan8, isChecked8.toString()));
                              plan.add(Plan(plan9, isChecked9.toString()));
                              plan.add(Plan(plan10, isChecked10.toString()));

                              consultations.add(Consultations(to,why,replay));

                              setState(() {
                                error = true;
                              });
                              upload(context, findings, comments);
                            }
                          } else {
                            internetMessage(context);
                          }
                        });

                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*.5,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color:  Colors.blueAccent),
                        child:Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              error?'uploading':'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),

                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ShowDailryRoundScreen(widget.id)));

                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*.5,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color:  Colors.blueAccent),
                        child:Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              'Show All',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),

                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );


  }
}
