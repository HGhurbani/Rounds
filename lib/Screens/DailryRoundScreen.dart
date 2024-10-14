import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Screens/HomeScreen.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:rounds/colors.dart';
import 'package:rounds/component.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DailyRound extends StatefulWidget {
  DoctorSicks patient;
  final int id;
  int indexList;
  String operation;
  DailyRound({this.patient,this.indexList, this.id , this.operation});
  @override
  _DailyRoundState createState() => _DailyRoundState();
}

class Consultations {
  String to;
  String why;
  String replay;

  Consultations(this.to, this.why, this.replay);
}
class items {
  String text;
  String carried;
  String date;

  items(this.text, this.carried, this.date);
}
class _DailyRoundState extends State<DailyRound> {
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
  bool _isListeningPlan1 = false;
  bool _isListeningPlan2 = false;
  bool _isListeningPlan3 = false;
  bool _isListeningPlan4 = false;
  bool _isListeningPlan5 = false;
  bool _isListeningPlan6 = false;
  bool _isListeningPlan7 = false;
  bool _isListeningPlan8 = false;
  bool _isListeningPlan9 = false;
  bool _isListeningPlan10 = false;
  bool _isListeningFinding = false;
  bool _isListeningComment = false;
  bool _isListeningDischarge = false;
  bool _isListeningAssessment = false;
  String date1=DateFormat("d/M/yyyy").format(DateTime.now()) ;
  String date2 =DateFormat("d/M/yyyy").format(DateTime.now());
  String date3 =DateFormat("d/M/yyyy").format(DateTime.now());
  String date4 =DateFormat("d/M/yyyy").format(DateTime.now());
  String date5 =DateFormat("d/M/yyyy").format(DateTime.now());
  String date6 =DateFormat("d/M/yyyy").format(DateTime.now());
  String date7 =DateFormat("d/M/yyyy").format(DateTime.now());
  String date8 =DateFormat("d/M/yyyy").format(DateTime.now());
  String date9 =DateFormat("d/M/yyyy").format(DateTime.now());
  String date10=DateFormat("d/M/yyyy").format(DateTime.now());
  bool error = false;
  final TextEditingController findingsController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final TextEditingController dischargeController = TextEditingController();
  final TextEditingController assessmentController = TextEditingController();
  final TextEditingController plan1 = TextEditingController();
  final TextEditingController plan2 = TextEditingController();
  final TextEditingController plan3 = TextEditingController();
  final TextEditingController plan4 = TextEditingController();
  final TextEditingController plan5 = TextEditingController();
  final TextEditingController plan6 = TextEditingController();
  final TextEditingController plan7 = TextEditingController();
  final TextEditingController plan8 = TextEditingController();
  final TextEditingController plan9 = TextEditingController();
  final TextEditingController plan10 = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController whyController = TextEditingController();
  final TextEditingController replayController = TextEditingController();

  List<Consultations> consultations = [];
  List<items> item = [];
  getSick() async {
    print(widget.id.toString());
    try {
      Response response = await Dio().get(
          "https://medicall-rounds.com/api/?key=os14042020ah&action=get-sick-data&sick-id=${widget.patient.id}");
      setState(() {
        widget.patient = DoctorSicks.fromJson(response.data);
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Please try again ..",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepOrangeAccent,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print("Exception Caught : $e");
    }
  }
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
       /* Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);*/
        Navigator.pop(context);
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
  update(context, findings, assessment,comments, discharge, index) async {
    try {
      FormData formData = FormData.fromMap({
        "action": 'update-daily-round-form',
        "key": 'os14042020ah',
        "sick_id": widget.id,
        "doctor_id": await DoctorID().readID(),
        "finding": findings,
        "assessment": assessment,
        "comment": comments,
        "discharge": discharge,
        "index":index,
        "items": [
          for (var p in item)
            {
              "item_text": p.text,
              "item_date": p.date,
              "item_complete": p.carried
            }
        ],
        "consultation": [
          for (var c in consultations)
            {
              "consultation_to": c.to,
              "consultation_replay": c.replay,
              "consultation_why": c.why,
            }
        ],
      });
      Response response =
      await Dio().post("https://medicall-rounds.com/api", data: formData);
      //print(response.data['status']);
      print('${widget.id}');
      //var responseServer = jsonDecode(response.data);
      //SuccessModel successModel = SuccessModel.fromJson(response.data);
      if (response.data['status'] == 'success') {
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
  upload(context, findings, assessment,comments, discharge, date) async {
    try {
      FormData formData = FormData.fromMap({
        "action": 'add-daily-round-form',
        "key": 'os14042020ah',
        "sick_id": widget.id,
        "doctor_id": await DoctorID().readID(),
        "finding": findings,
        "assessment": assessment,
        "comment": comments,
        "discharge": discharge,
        "date": date,
        "items": [
          for (var p in item)
            {
              "item_text": p.text,
              "item_date": p.date,
              "item_complete": p.carried
            }
        ],
        "consultation": [
          for (var c in consultations)
            {
              "consultation_to": c.to,
              "consultation_replay": c.replay,
              "consultation_why": c.why,
            }
        ],
      });
      Response response =
          await Dio().post("https://medicall-rounds.com/api", data: formData);
      //print(response.data['status']);
      print('${widget.id}');
      //var responseServer = jsonDecode(response.data);
      //SuccessModel successModel = SuccessModel.fromJson(response.data);
      if (response.data['status'] == 'success') {
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
  stt.SpeechToText _speech;
  Future<bool> _listen(TextEditingController controller, bool coloring) async {
    if (!coloring) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => coloring = true);
        _speech.listen(
          onResult: (val) => setState(() {
            controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => coloring = false);
      _speech.stop();
    }
    return coloring;
  }

  String planDate;

  @override
  void initState() {
    super.initState();
    planDate = DateFormat("d/M/yyyy").format(DateTime.now());
    _speech = stt.SpeechToText();
    if(widget.operation=="edit"){
      if(widget.patient.dailyForm[widget.indexList].items.length>=1)
        {
          plan1.text=widget.patient.dailyForm[widget.indexList].items[0].text;
          date1=planDate/*widget.sick.dailyForm[widget.indexList].items[0].date*/;
          isChecked1=widget.patient.dailyForm[widget.indexList].items[0].complete.isEmpty?false:true;
        }
      if(widget.patient.dailyForm[widget.indexList].items.length>=2)
      {
        plan2.text=widget.patient.dailyForm[widget.indexList].items[1].text;
        date2=planDate/*widget.sick.dailyForm[widget.indexList].items[1].date*/;
        isChecked2=widget.patient.dailyForm[widget.indexList].items[1].complete.isEmpty?false:true;
      }
      if(widget.patient.dailyForm[widget.indexList].items.length>=3)
      {
        plan3.text=widget.patient.dailyForm[widget.indexList].items[2].text;
        date3=planDate/*widget.sick.dailyForm[widget.indexList].items[2].date*/;
        isChecked3=widget.patient.dailyForm[widget.indexList].items[2].complete.isEmpty?false:true;
      }
      if(widget.patient.dailyForm[widget.indexList].items.length>=4)
      {
        plan4.text=widget.patient.dailyForm[widget.indexList].items[3].text;
        date4=planDate/*widget.sick.dailyForm[widget.indexList].items[3].date*/;
        isChecked4=widget.patient.dailyForm[widget.indexList].items[3].complete.isEmpty?false:true;
      }
      if(widget.patient.dailyForm[widget.indexList].items.length>=5)
      {
        plan5.text=widget.patient.dailyForm[widget.indexList].items[4].text;
        date5=planDate;//widget.sick.dailyForm[widget.indexList].items[4].date;
        isChecked5=widget.patient.dailyForm[widget.indexList].items[4].complete.isEmpty?false:true;
      }
      if(widget.patient.dailyForm[widget.indexList].items.length>=6)
      {
        plan6.text=widget.patient.dailyForm[widget.indexList].items[5].text;
        date6=planDate;//widget.sick.dailyForm[widget.indexList].items[5].date;
        isChecked6=widget.patient.dailyForm[widget.indexList].items[5].complete.isEmpty?false:true;
      }
      if(widget.patient.dailyForm[widget.indexList].items.length>=7)
      {
        plan7.text=widget.patient.dailyForm[widget.indexList].items[6].text;
        date7=planDate;//widget.sick.dailyForm[widget.indexList].items[6].date;
        isChecked7=widget.patient.dailyForm[widget.indexList].items[6].complete.isEmpty?false:true;
      }
      if(widget.patient.dailyForm[widget.indexList].items.length>=8)
      {
        plan8.text=widget.patient.dailyForm[widget.indexList].items[7].text;
        date8=planDate;//widget.sick.dailyForm[widget.indexList].items[7].date;
        isChecked8=widget.patient.dailyForm[widget.indexList].items[7].complete.isEmpty?false:true;
      }
      if(widget.patient.dailyForm[widget.indexList].items.length>=9)
      {
        plan9.text=widget.patient.dailyForm[widget.indexList].items[8].text;
        date9=planDate;//widget.sick.dailyForm[widget.indexList].items[8].date;
        isChecked9=widget.patient.dailyForm[widget.indexList].items[8].complete.isEmpty?false:true;
      }
      if(widget.patient.dailyForm[widget.indexList].items.length>=10)
      {
        plan10.text=widget.patient.dailyForm[widget.indexList].items[9].text;
        date10=planDate;//widget.sick.dailyForm[widget.indexList].items[9].date;
        isChecked10=widget.patient.dailyForm[widget.indexList].items[9].complete.isEmpty?false:true;
      }
      commentsController.text=widget.patient.dailyForm[widget.indexList].comment;
      dischargeController.text=widget.patient.dailyForm[widget.indexList].discharge;
      findingsController.text=widget.patient.dailyForm[widget.indexList].finding;
      assessmentController.text=widget.patient.dailyForm[widget.indexList].assessment;
      toController.text= widget.patient.dailyForm[widget.indexList].consultation.to;
      whyController.text= widget.patient.dailyForm[widget.indexList].consultation.why;
      replayController.text= widget.patient.dailyForm[widget.indexList].consultation.replay;
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("The Plan"),
        elevation: 0,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Instruction :',
              style: TextStyle(
                color: teal,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.only(left: width * 0.05),
                    width: width * 0.8,
                    child: defaultTextFormField(
                      controller: findingsController,
                      hintText: 'Finding',
                      typingType: TextInputType.multiline,
                    )),
                Padding(
                  padding: EdgeInsets.only(right: width * 0.06),
                  child: CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor:
                      _isListeningFinding ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(findingsController, _isListeningFinding)
                              .then((value) {
                            setState(() {
                              _isListeningFinding = value;
                            });
                          });
                        },
                      )),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.only(left: width * 0.05),
                    width: width * 0.8,
                    child: defaultTextFormField(
                      controller: assessmentController,
                      hintText: 'Assessment',
                      typingType: TextInputType.multiline,
                    )),
                Padding(
                  padding: EdgeInsets.only(right: width * 0.06),
                  child: CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor:
                      _isListeningAssessment ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(assessmentController, _isListeningAssessment)
                              .then((value) {
                            setState(() {
                              _isListeningAssessment = value;
                            });
                          });
                        },
                      )),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.only(
                      left: width * 0.05,
                    ),
                    width: width * 0.8,
                    child: defaultTextFormField(
                      controller: commentsController,
                      hintText: 'Comment',
                      typingType: TextInputType.multiline,
                    )),
                Padding(
                  padding: EdgeInsets.only(right: width * 0.06),
                  child: CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor:
                      _isListeningComment ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(commentsController, _isListeningComment)
                              .then((value) {
                            setState(() {
                              _isListeningComment = value;
                            });
                          });
                        },
                      )),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: EdgeInsets.only(left: width * 0.05),
                    width: width * 0.8,
                    child: defaultTextFormField(
                      controller: dischargeController,
                      hintText: 'Discharge Plan',
                      typingType: TextInputType.multiline,
                    )),
                Padding(
                  padding: EdgeInsets.only(right: width * 0.06),
                  child: CircleAvatar(
                      radius: (width - (width * 0.8)) / 4,
                      backgroundColor:
                      _isListeningDischarge ? Colors.red : teal,
                      child: IconButton(
                        icon: Icon(
                          Icons.mic_none_outlined,
                        ),
                        onPressed: () {
                          _listen(dischargeController,
                              _isListeningDischarge)
                              .then((value) {
                            setState(() {
                              _isListeningDischarge = value;
                            });
                          });
                        },
                      )),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                planItem(
                    width: width,
                    controller: plan1,
                    hint: "1.",
                    checkRecord: _isListeningPlan1,
                    date:  date1,
                    isCheck: isChecked1,
                    function: () {
                      _listen(plan1, _isListeningPlan1).then((value) {
                        setState(() {
                          _isListeningPlan1 = value;
                          print("5${_isListeningPlan1}");
                        });
                      });
                    },
                    functionData: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                      ).then((d) {
                        setState(() {
                          date1 = DateFormat("d/M/yyyy").format(d);
                        });
                        //  print(_dateOfAdmission);
                      });
                    },
                  functionCheck: (bool value) {
                    setState(() {
                      isChecked1 = value;
                    });
                  },
                ),
                planItem(
                    width: width,
                    controller: plan2,
                    hint: "2.",
                    checkRecord: _isListeningPlan2,
                    date: date2==null ? "Pick Date" : date2,
                    isCheck: isChecked2,
                    function: () {
                      _listen(plan2, _isListeningPlan2).then((value) {
                        setState(() {
                          _isListeningPlan2 = value;
                        });
                      });
                    },
                    functionData: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                      ).then((d) {
                        setState(() {
                          date2 = DateFormat("d/M/yyyy").format(d);
                        });
                        //  print(_dateOfAdmission);
                      });
                    },
                  functionCheck: (bool value) {
                    setState(() {
                      isChecked2 = value;
                    });
                  },
                    ),
                planItem(
                    width: width,
                    controller: plan3,
                    hint: "3.",
                    checkRecord: _isListeningPlan3,
                    date: date3==null ? "Pick Date" : date3,
                    isCheck: isChecked3,
                    function: () {
                      _listen(plan3, _isListeningPlan3).then((value) {
                        setState(() {
                          _isListeningPlan3 = value;
                        });
                      });
                    },
                    functionData: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                      ).then((d) {
                        setState(() {
                          date3 = DateFormat("d/M/yyyy").format(d);
                        });
                        //  print(_dateOfAdmission);
                      });
                    },
                  functionCheck: (bool value) {
                    setState(() {
                      isChecked3 = value;
                    });
                  },
                ),
                planItem(
                    width: width,
                    controller: plan4,
                    hint: "4.",
                    checkRecord: _isListeningPlan4,
                    date: date4==null ? "Pick Date" : date4,
                    isCheck: isChecked4,
                    function: () {
                      _listen(plan4, _isListeningPlan4).then((value) {
                        setState(() {
                          _isListeningPlan4 = value;
                        });
                      });
                    },
                    functionData: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                      ).then((d) {
                        setState(() {
                          date4 = DateFormat("d/M/yyyy").format(d);
                        });
                        //  print(_dateOfAdmission);
                      });
                    },
                  functionCheck: (bool value) {
                    setState(() {
                      isChecked4 = value;
                    });
                  },),
                planItem(
                    width: width,
                    controller: plan5,
                    hint: "5.",
                    checkRecord: _isListeningPlan5,
                    date: date5==null ? "Pick Date" : date5,
                    isCheck: isChecked5,
                    function: () {
                      _listen(plan5, _isListeningPlan5).then((value) {
                        setState(() {
                          _isListeningPlan5 = value;
                        });
                      });
                    },
                    functionData: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                      ).then((d) {
                        setState(() {
                          date5 = DateFormat("d/M/yyyy").format(d);
                        });
                        //  print(_dateOfAdmission);
                      });
                    },
                  functionCheck: (bool value) {
                    setState(() {
                      isChecked5 = value;
                    });
                  },),
                planItem(
                    width: width,
                    controller: plan6,
                    hint: "6.",
                    checkRecord: _isListeningPlan6,
                    date: date6==null ? "Pick Date" : date6,
                    isCheck: isChecked6,
                    function: () {
                      _listen(plan6, _isListeningPlan6).then((value) {
                        setState(() {
                          _isListeningPlan6 = value;
                        });
                      });
                    },
                    functionData: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                      ).then((d) {
                        setState(() {
                          date6 = DateFormat("d/M/yyyy").format(d);
                        });
                        //  print(_dateOfAdmission);
                      });
                    },
                  functionCheck: (bool value) {
                    setState(() {
                      isChecked6 = value;
                    });
                  },),
                planItem(
                    width: width,
                    controller: plan7,
                    hint: "7.",
                    checkRecord: _isListeningPlan7,
                    date: date7==null ? "Pick Date" : date7,
                    isCheck: isChecked7,
                    function: () {
                      _listen(plan7, _isListeningPlan7).then((value) {
                        setState(() {
                          _isListeningPlan7 = value;
                        });
                      });
                    },
                    functionData: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                      ).then((d) {
                        setState(() {
                          date7 = DateFormat("d/M/yyyy").format(d);
                        });
                        //  print(_dateOfAdmission);
                      });
                    },
                  functionCheck: (bool value) {
                    setState(() {
                      isChecked7 = value;
                    });
                  },),
                planItem(
                    width: width,
                    controller: plan8,
                    hint: "8.",
                    checkRecord: _isListeningPlan8,
                    date: date8==null ? "Pick Date" : date8,
                    isCheck: isChecked8,
                    function: () {
                      _listen(plan8, _isListeningPlan8).then((value) {
                        setState(() {
                          _isListeningPlan8 = value;
                        });
                      });
                    },
                    functionData: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                      ).then((d) {
                        setState(() {
                          date8 = DateFormat("d/M/yyyy").format(d);
                        });
                        //  print(_dateOfAdmission);
                      });
                    },
                  functionCheck: (bool value) {
                    setState(() {
                      isChecked8 = value;
                    });
                  },),
                planItem(
                    width: width,
                    controller: plan9,
                    hint: "9.",
                    checkRecord: _isListeningPlan9,
                    date: date9==null ? "Pick Date" : date9,
                    isCheck: isChecked9,
                    function: () {
                      _listen(plan9, _isListeningPlan9).then((value) {
                        setState(() {
                          _isListeningPlan9 = value;
                        });
                      });
                    },
                    functionData: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                      ).then((d) {
                        setState(() {
                          date9 = DateFormat("d/M/yyyy").format(d);
                        });
                        //  print(_dateOfAdmission);
                      });
                    },
                  functionCheck: (bool value) {
                    setState(() {
                      isChecked9 = value;
                    });
                  },),
                planItem(
                    width: width,
                    controller: plan10,
                    hint: "10.",
                    checkRecord: _isListeningPlan10,
                    date: date10==null ? "Pick Date" :date10,
                    isCheck: isChecked10,
                    function: () {
                      _listen(plan10, _isListeningPlan10).then((value) {
                        setState(() {
                          _isListeningPlan10 = value;
                        });
                      });
                    },functionData: (){
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(3000),
                  ).then((d) {
                    setState(() {
                      date10 =DateFormat("d/M/yyyy").format(d) ;
                    });
                    //  print(_dateOfAdmission);
                  });
                },
                functionCheck: (bool value) {
                    setState(() {
                      isChecked10 = value;
                    });
                  },
                ),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Consultations',
                      style: TextStyle(
                        color: teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "to: ",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Container(
                                width: width * 0.7,
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextField(
                                  controller: toController,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: "Doctor name",
                                    hintStyle: TextStyle(
                                        color: deepBlue, fontSize: 14),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: teal, width: 2)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: orange, width: 2)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "why: ",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Container(
                                width: width * 0.7,
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextField(
                                  controller: whyController,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: "Reason",
                                    hintStyle: TextStyle(
                                        color: deepBlue, fontSize: 14),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: teal, width: 2)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: orange, width: 2)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "reply: ",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Container(
                                width: width * 0.7,
                                padding: const EdgeInsets.only(
                                    left: 8.0, bottom: 8.0),
                                child: TextField(
                                  controller: replayController,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: "reply",
                                    hintStyle: TextStyle(
                                        color: deepBlue, fontSize: 14),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: teal, width: 2)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: orange, width: 2)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          myButton(
              width: width,
              onPressed: () {
                check().then((intenet) {
                  if (intenet != null && intenet) {
                    // Internet Present Case
                    consultations.clear();
                    item.clear();
                    plan1.text.isNotEmpty? item.add(items(plan1.text, isChecked1==false?"":isChecked1.toString(), date1 )):"";
                    plan2.text.isNotEmpty?   item.add(items(plan2.text, isChecked2==false?"":isChecked2.toString(), date2 )):"";
                    plan3.text.isNotEmpty? item.add(items(plan3.text, isChecked3==false?"":isChecked3.toString(), date3 )):"";
                    plan4.text.isNotEmpty?  item.add(items(plan4.text, isChecked4==false?"":isChecked4.toString(), date4 )):"";
                    plan5.text.isNotEmpty? item.add(items(plan5.text, isChecked5==false?"":isChecked5.toString(), date5 )):"";
                    plan6.text.isNotEmpty?   item.add(items(plan6.text, isChecked6==false?"":isChecked6.toString(), date6 )):"";
                    plan7.text.isNotEmpty?   item.add(items(plan7.text, isChecked7==false?"":isChecked7.toString(), date7 )):"";
                    plan8.text.isNotEmpty?  item.add(items(plan8.text, isChecked8==false?"":isChecked8.toString(), date8 )):"";
                    plan9.text.isNotEmpty?   item.add(items(plan9.text, isChecked9==false?"":isChecked9.toString(), date9 )):"";
                    plan10.text.isNotEmpty? item.add(items(plan10.text, isChecked10==false?"":isChecked10.toString(), date10)):"";
                    consultations.add(Consultations(toController.text, whyController.text, replayController.text));
                    setState(() {
                      error = true;
                    });
                    if(widget.operation=="add"){
                      upload(
                          context,
                          findingsController.text,
                          assessmentController.text,
                          commentsController.text,
                          dischargeController.text,
                          planDate);
                    }
                    else if(widget.operation=="edit"){
                      update(
                          context,
                          findingsController.text,
                          assessmentController.text,
                          commentsController.text,
                          dischargeController.text,
                          widget.patient.dailyForm[widget.indexList].index);
                    }
                  } else {
                    internetMessage(context);
                  }
                });
              },
              text: error ? 'Uploading' : 'Save')
        ],
      ),
    );
  }
  Widget planItem(
      {double width,
      TextEditingController controller,
      String hint,
      bool checkRecord,
      String date,
      bool isCheck,
      Function function,
      Function functionData,
      Function functionCheck}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300], width: 2)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: width * 0.7,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: deepBlue, fontSize: 14),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: teal, width: 2)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: orange, width: 2)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: width * 0.01),
                    child: CircleAvatar(
                        radius: width * 0.05,
                        backgroundColor: checkRecord ? Colors.red : teal,
                        child: IconButton(
                          icon: Icon(
                            Icons.mic_none_outlined,
                          ),
                          onPressed: function,
                        )),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Row(
                    children: [
                     /* IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: teal,
                        ),
                        onPressed: functionData,
                      ),*/
                      Checkbox(
                        value: isCheck,
                        onChanged: functionCheck,
                        fillColor: MaterialStateProperty.all(orange),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
