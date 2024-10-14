import 'package:dio/dio.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Network/DailyRoundFormModel.dart';

class ShowDailryRoundScreen extends StatefulWidget {

   final int id;

  ShowDailryRoundScreen(this.id);


  @override
  _ShowDailryRoundScreenState createState() => _ShowDailryRoundScreenState();
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


class _ShowDailryRoundScreenState extends State<ShowDailryRoundScreen> {
  DailyRoundForm dailyRoundForm;

  final planController1 = TextEditingController();
  final planController2 = TextEditingController();
  final planController3 = TextEditingController();
  final planController4 = TextEditingController();
  final planController5 = TextEditingController();
  final planController6 = TextEditingController();
  final planController7 = TextEditingController();
  final planController8 = TextEditingController();
  final planController9 = TextEditingController();
  final planController10 = TextEditingController();
  final findingsController = TextEditingController();
  final commentsController = TextEditingController();
  final toController = TextEditingController();
  final whyController = TextEditingController();
  final replayController = TextEditingController();

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
 bool loaded = false;

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

  getForm() async {
    try {
      Response response = await Dio().get(
          "https://medicall-rounds.com/api/?key=os14042020ah&action=get-daily-round-form&sick_id=${widget.id}");


      dailyRoundForm = DailyRoundForm.fromJson(response.data);

      if (dailyRoundForm.st == 'success') {
        setState(() {
          loaded = true;
        });
        planController1.text = dailyRoundForm.plan[0].text;
        planController2.text = dailyRoundForm.plan[1].text;
        planController3.text = dailyRoundForm.plan[2].text;
        planController4.text = dailyRoundForm.plan[3].text;
        planController5.text = dailyRoundForm.plan[4].text;
        planController6.text = dailyRoundForm.plan[5].text;
        planController7.text = dailyRoundForm.plan[6].text;
        planController8.text = dailyRoundForm.plan[7].text;
        planController9.text = dailyRoundForm.plan[8].text;
        planController10.text = dailyRoundForm.plan[9].text;
        toController.text = dailyRoundForm.consultations[0].to;
        whyController.text = dailyRoundForm.consultations[0].why;
        replayController.text = dailyRoundForm.consultations[0].replay;
        findingsController.text = dailyRoundForm.findings;
        commentsController.text = dailyRoundForm.comments;
         isChecked1 =  dailyRoundForm.plan[0].carried == "true"?true:false;
         isChecked2 = dailyRoundForm.plan[1].carried == "true"?true:false;
         isChecked3 = dailyRoundForm.plan[2].carried == "true"?true:false;
         isChecked4 = dailyRoundForm.plan[3].carried == "true"?true:false;
         isChecked5 = dailyRoundForm.plan[4].carried == "true"?true:false;
         isChecked6 = dailyRoundForm.plan[5].carried == "true"?true:false;
         isChecked7 = dailyRoundForm.plan[6].carried == "true"?true:false;
         isChecked8 = dailyRoundForm.plan[7].carried == "true"?true:false;
         isChecked9 = dailyRoundForm.plan[8].carried == "true"?true:false;
         isChecked10 = dailyRoundForm.plan[9].carried == "true"?true:false;
      } else {
        print(dailyRoundForm.msg);

        setState(() {
          loaded = false;
        });
      }
    } catch (e) {
      print("Exception Caught : $e");
    }

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
  void initState() {
    // TODO: implement initState
    super.initState();
    getForm();
  }

  @override
  Widget build(BuildContext context) {
    return loaded? SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Daily Round"),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: MediaQuery.of(context).size.width,
                        child: TextField(
                          controller: findingsController,
                          onChanged: (val){
                            setState(() {
                              val = dailyRoundForm.findings;
                              findings = val ;
                            });
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Finding',
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
                                controller: planController1,
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
                                controller: planController2,
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
                                controller: planController3,
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
                                controller: planController4,
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
                                controller: planController5,
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
                                controller: planController6,
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
                                controller: planController7,
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
                                controller: planController8,
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
                                controller: planController9,
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
                                controller: planController10,
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
                          controller: commentsController,
                          onChanged: (val){
                            setState(() {
                              val = dailyRoundForm.comments;
                              comments = val ;
                            });
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Comment',
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
                                      controller: toController,
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
                                      controller: whyController,
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
                                      controller: replayController,
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
                            if(findingsController.text.isEmpty || commentsController.text.isEmpty)
                              {
                                missingMessage(context);
                              }
                            else{
                              consultations.clear();
                              plan.clear();

                              plan.add(Plan(planController1.text, isChecked1.toString()));
                              plan.add(Plan(planController2.text, isChecked2.toString()));
                              plan.add(Plan(planController3.text, isChecked3.toString()));
                              plan.add(Plan(planController4.text, isChecked4.toString()));
                              plan.add(Plan(planController5.text, isChecked5.toString()));
                              plan.add(Plan(planController6.text, isChecked6.toString()));
                              plan.add(Plan(planController7.text, isChecked7.toString()));
                              plan.add(Plan(planController8.text, isChecked8.toString()));
                              plan.add(Plan(planController9.text, isChecked9.toString()));
                              plan.add(Plan(planController10.text, isChecked10.toString()));

                              consultations.add(Consultations(toController.text,whyController.text,replayController.text));

                                setState(() {
                                  error = true;
                                });
                                upload(context, findingsController.text, commentsController.text);
                            }
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

                  ],
                )
              ],
            ),
          ],
        ),
      ),
    ):Center(child: Text("Loading"));


  }
}
