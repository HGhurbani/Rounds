import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

import 'package:rounds/Network/SickModel.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Network/SuccessModel.dart';



class AddNoteScreen extends StatefulWidget {
  final int id;
  final SickModel sick;

  AddNoteScreen(this.id,this.sick);

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {

  final textConroler = TextEditingController();

  String _text = '';

  bool error = false;
  bool complete = false;

  final String KEY = 'os14042020ah';
  final String ACTION = 'add-note-to-sick';

  uploadNote(context,text) async {

    try {
      FormData formData = FormData.fromMap({
        "action": ACTION,
        "key": KEY,
        "note-text": text,
        "sick-id":widget.id,
        "note-doctor-id": await DoctorID().readID(),
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
      title: Text("ERROR"),
      content: Text("something went wrong"),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Container(
              height: 150,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30)),
                  color: Color(0xff395ef2)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.only(
                        right: 8, top: 8, left: 5, bottom: 8),
                    child: SizedBox(
                      height: 100,
                      child: CircleAvatar(
                        backgroundImage: (widget.sick?.avatar == null || widget.sick?.avatar == false)
                            ? AssetImage('images/doctoravatar.png')
                            : NetworkImage(widget.sick.avatar),
                        radius: 50,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                    widget.sick.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          widget.sick.surgery,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15), color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: textConroler,
                      onChanged: (val) {
                        _text = val;
                        if (_text.length != 0 ) {
                          setState(() {
                            complete = true;
                          });
                        }
                        else{
                          setState(() {
                            complete = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Note Text',
                        hintStyle: TextStyle(
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                ),



                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color:  complete ? Color(0xff19d7e7) : Colors.blueGrey),
                        child: TextButton(
                            onPressed: () async{
                              check().then((intenet) {
                                if (intenet != null && intenet) {
                                  // Internet Present Case
                                  if (textConroler.text.isEmpty) {
                                  } else {
                                    setState(() {
                                      error = true;
                                    });

                                    uploadNote(context,_text);

                                  }
                                }
                                else{
                                  internetMessage(context);
                                }
                              });

                            },
                            child: Text(
                              error ? 'Uploading' :'Add Note',
                              style: TextStyle(
                                color: const Color(0xffffffff),
                              ),
                            )),
                      ),
                    ],
                  ),
                )

              ],
            ),

          ],
        ),
      ),
    );
  }
}
