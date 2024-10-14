import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounds/AddScreens/AddReportScreen.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../colors.dart';
import '../handling_new_featuers/pdf_screen.dart';

class ReportScreen extends StatefulWidget {
  int id;
  DoctorSicks patient;

  ReportScreen(this.id, this.patient);

  @override
  _ReadyOrderScreen createState() => _ReadyOrderScreen();
}

class _ReadyOrderScreen extends State<ReportScreen> {
  popLoaderDialog(BuildContext context) {
    Navigator.pop(context);
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
      content: Text(""),
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

  Future<void> share(name, info) async {
    await FlutterShare.share(
        title: 'Data',
        text: 'Patient name: $name \n Report: $info\n',
        chooserTitle: 'Share with');
  }

  final String KEY = 'os14042020ah';
  final String ACTIONDELETE = 'delete-sick-report';

  deleteReport(context, index, indexList) async {
    try {
      FormData formData = FormData.fromMap({
        "action": ACTIONDELETE,
        "key": KEY,
        "index": index,
        "sick_id": widget.id,
      });

      Response response =
          await Dio().post("https://medicall-rounds.com/api", data: formData);

      //var responseServer = jsonDecode(response.data);

      SuccessModel successModel = SuccessModel.fromJson(response.data);

      if (successModel.st == 'success') {
        Fluttertoast.showToast(
            msg: "Deleting",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.deepOrangeAccent,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          widget.patient.reports.removeAt(indexList);
        });
      } else {
        Fluttertoast.showToast(
            msg: "Please try again ..",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.deepOrangeAccent,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print("Exception Caught : $e");
    }
  }

  @override
  void initState() {
    initPlayer();
    super.initState();
  }

  @override
  void dispose() {
    advancedPlayer.dispose();
    super.dispose();
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();

    advancedPlayer.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });
    advancedPlayer.onAudioPositionChanged.listen((Duration d) {
      setState(() => _position = d);
    });
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    advancedPlayer.seek(newDuration);
  }

  AudioPlayer advancedPlayer;
  Duration _duration = new Duration();
  Duration _position = new Duration();

  Widget slider(int index) {
    return Slider(
        activeColor: deepBlue,
        inactiveColor: teal,
        value: _position.inSeconds.toDouble(),
        min: 0.0,
        max: _duration.inSeconds.toDouble(),
        onChanged: (double value) {
          setState(() {
            seekToSecond(value.toInt());
            value = value;
          });
        });
  }

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    String title,
    String desc,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Patient Name : $title",
                    style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 20),
                pw.Text("Report : $desc", style: pw.TextStyle(fontSize: 22)),
                pw.SizedBox(height: 20),
                //    pw.Text(title),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

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
          fontSize: 16.0);
      print("Exception Caught : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    TextStyle style = TextStyle(
      fontSize: 14.0,
      color: deepBlue,
    );
    TextStyle style2 =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: teal);
    return Column(
      children: <Widget>[
        (widget.patient.reports?.length == null ||
                widget.patient.reports?.length == 0 ||
                widget.patient.reports == null)
            ? Container(
                height: height,
                child: RefreshIndicator(
                  onRefresh: () async {
                    getSick();
                  },
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: height * 0.3,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'No Reports Found',
                            style: style2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  getSick();
                },
                child: Column(
                  children: <Widget>[
                    GridView.builder(
                      //   physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.patient.reports.length,
                      itemBuilder: (context, index) {
                        //  if(index==widget.sick.reports.length) return CircularProgressIndicator();
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  content: Container(
                                      width: width,
                                      height: height * 0.7,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                      child: SingleChildScrollView(
                                        physics: BouncingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Patient Name:  ",
                                                  style: style,
                                                ),
                                                Container(
                                                    width: width * 0.3,
                                                    child: Text(
                                                      widget.patient.reports[index]
                                                          .reportTitle,
                                                      style: style2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30.0),
                                              child: Divider(
                                                thickness: 1.5,
                                                color: deepBlue,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Report:",
                                                  style: style,
                                                ),
                                                widget.patient.reports[index]
                                                            .reportText !=
                                                        ""
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          widget
                                                              .patient
                                                              .reports[index]
                                                              .reportText,
                                                          style: style2,
                                                          maxLines: 20,
                                                        ),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20.0),
                                                        child: Text(
                                                          "No Report",
                                                          style: style2,
                                                        ),
                                                      ),

                                                widget.patient.reports[index]
                                                            .reportFile ==
                                                        ""
                                                    ? Container()
                                                    : Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        20.0),
                                                            child: Divider(
                                                              thickness: 1.5,
                                                              color: deepBlue,
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                "Audio :",
                                                                style: style,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                children: <Widget>[
                                                                  IconButton(
                                                                    icon: Icon(Icons
                                                                        .play_arrow),
                                                                    onPressed: () {
                                                                      advancedPlayer.play(widget
                                                                          .patient
                                                                          .reports[
                                                                      index]
                                                                          .reportFile);
                                                                    },
                                                                  ),
                                                                  IconButton(
                                                                    icon: Icon(Icons
                                                                        .pause),
                                                                    onPressed: () {
                                                                      advancedPlayer
                                                                          .pause();
                                                                    },
                                                                  ),
                                                                  IconButton(
                                                                    icon: Icon(
                                                                        Icons.stop),
                                                                    onPressed: () {
                                                                      advancedPlayer
                                                                          .stop();
                                                                    },
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          widget.patient.reports[index].reportPdf == "" ? Text("No PDF",style: style,):OutlinedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (_)=>PDFScreen(data:widget.patient.reports[index])));}, child: Text("Read PDF",style:style1)),

                                                        ],
                                                      )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              elevation: 6.0,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Patient Name",
                                      style: style,
                                    ),
                                    Container(
                                        width: width * 0.3,
                                        child: Center(
                                          child: Text(
                                            widget.patient.reports[index]
                                                .reportTitle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: style2,
                                          ),
                                        )),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddReportScreen(
                                                              widget.id,
                                                              widget.patient,
                                                              widget
                                                                  .patient
                                                                  .reports[
                                                                      index]
                                                                  .reportTitle,
                                                              widget
                                                                  .patient
                                                                  .reports[
                                                                      index]
                                                                  .reportText,
                                                              widget
                                                                  .patient
                                                                  .reports[
                                                                      index]
                                                                  .index)));
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            )),
                                        GestureDetector(
                                            onTap: () {
                                              deleteReport(
                                                  context,
                                                  widget.patient.reports[index]
                                                      .index,
                                                  index);
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            )),
                                        GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title: Text("Printing"),
                                                        content: Container(
                                                          width: 400,
                                                          height: 500,
                                                          child: PdfPreview(
                                                            allowSharing: false,
                                                            canChangePageFormat:
                                                                false,
                                                            build: (format) => _generatePdf(
                                                                format,
                                                                widget
                                                                    .patient
                                                                    .reports[
                                                                        index]
                                                                    .reportTitle,
                                                                widget
                                                                    .patient
                                                                    .reports[
                                                                        index]
                                                                    .reportText),
                                                          ),
                                                        ),
                                                      ));
                                            },
                                            child: Icon(
                                              Icons.print,
                                              color: teal,
                                            )),
                                        GestureDetector(
                                          onTap: () {
                                            share(
                                                widget.patient.reports[index]
                                                    .reportTitle,
                                                widget.patient.reports[index]
                                                    .reportText);
                                          },
                                          child: Icon(
                                            Icons.share,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
