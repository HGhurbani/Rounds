import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:rounds/colors.dart';
import 'package:rounds/component.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'DailryRoundScreen.dart';

class PlanScreen extends StatefulWidget {
  DoctorSicks patient;
  int id;

  PlanScreen(this.patient, this.id);

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  deletePlan(context, index, indexList) async {
    try {
      FormData formData = FormData.fromMap({
        "action": 'delete-daily-round-form',
        "key": 'os14042020ah',
        "index": index,
        "sick_id": widget.id
      });
      Response response =
          await Dio().post("https://medicall-rounds.com/api", data: formData);
      //var responseServer = jsonDecode(response.data);
      //SuccessModel successModel = SuccessModel.fromJson(response.data);
      if (response.data['st'] == 'success') {
        Fluttertoast.showToast(
            msg: "Deleting",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.deepOrangeAccent,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          widget.patient.dailyForm.removeAt(indexList);
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

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, DailyForm dailyForm) async {
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
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Text("Plan", style: pw.TextStyle(fontSize: 20)),
                    pw.Text(dailyForm.date, style: pw.TextStyle(fontSize: 20)),
                  ],
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(20),
                  child: pw.ListView.builder(
                    itemCount: dailyForm.items.length,
                    itemBuilder: (context, index) => pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "${index + 1}.   ${dailyForm.items[index].text}",
                          style: pw.TextStyle(fontSize: 20),
                        ),
                        pw.Text("${dailyForm.items[index].date}",
                            style: pw.TextStyle(fontSize: 20)),
                        pw.Text(
                            "${dailyForm.items[index].complete == true ? 'Complete' : 'Incomplete'}",
                            style: pw.TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Text(
                      "Finding :  ${dailyForm.finding == "" ? "No Finding" : dailyForm.finding}",
                      style: pw.TextStyle(fontSize: 18)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Text(
                      "Comment :  ${dailyForm.comment == "" ? "No Comment" : dailyForm.comment}",
                      style: pw.TextStyle(fontSize: 18)),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Text(
                      "Discharge :  ${dailyForm.discharge == "" ? "No Discharge" : dailyForm.discharge}",
                      style: pw.TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  int _current = 0;
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
  @override
  Widget build(BuildContext context) {
    int dailyFormIndex = widget.patient.dailyForm.length;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return widget.patient.dailyForm.length==0?Container(
      height:height,
      child: RefreshIndicator(
        onRefresh: ()async{
          getSick();
        },
        child: ListView(
          children: [
            Center(
              child: Padding(
                padding:  EdgeInsets.only(top: height*0.3),
                child: Text("No Daily Round Added ",style: TextStyle(color: deepBlue , fontSize: 20 , fontWeight: FontWeight.w600),),
              ),
            ),
          ],
        ),
      ),
    ): Padding(
      padding: EdgeInsets.all(8.0),
      child: RefreshIndicator(
        onRefresh: ()async{
          getSick();
        },
        child: Container(
          height: height,
          child: ListView(
            children: [
              Container(
                height: height * 0.64,
                width: width,
                color: Colors.white,
                child: CarouselSlider.builder(
                  itemCount: widget.patient.dailyForm.length,
                  options: CarouselOptions(
                      autoPlay: false,
                      enlargeCenterPage: true,
                      viewportFraction: 0.98,
                      aspectRatio: height * 0.0001,
                      initialPage: dailyFormIndex - 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = dailyFormIndex - 1;
                          _current = _current - index;
                        });
                      }),
                  itemBuilder: (context, index1, itemIndex) => Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: teal, width: 1.2)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 10, right: 15, bottom: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Visit Date",
                                      style:
                                          TextStyle(color: deepBlue, fontSize: 16)),
                                  Text("${widget.patient.dailyForm[index1].date}",
                                      style: TextStyle(
                                          color: Colors.black87, fontSize: 13)),
                                ],
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  customButton: Icon(
                                    Icons.more_vert,
                                    size: 25,
                                    color: orange,
                                  ),
                                  alignment: AlignmentDirectional.topStart,
                                  customItemsIndexes: const [2],
                                  items: [
                                    ...MenuItems.Items.map(
                                        (item) => DropdownMenuItem<MenuItem>(
                                              value: item,
                                              child: MenuItems.buildItem(item),
                                            )),
                                  ],
                                  onChanged: (value) {
                                    switch (value) {
                                      case MenuItems.edit:
                                        print("edit");
                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                            DailyRound(patient:widget.patient,indexList:index1,id:widget.id,operation:"edit")));
                                        break;
                                      case MenuItems.delete:
                                        print("delete");

                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: Text(
                                                    "Do you want to remove the plan?",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: deepBlue),
                                                  ),
                                                  content: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text(
                                                            "No",
                                                            style: TextStyle(
                                                                color: teal),
                                                          )),
                                                      TextButton(
                                                          onPressed: () {
                                                            deletePlan(context, widget.patient.dailyForm[index1].index, index1);
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text("Yes",
                                                              style: TextStyle(
                                                                  color: teal))),
                                                    ],
                                                  ),
                                                ));

                                        break;
                                      case MenuItems.print:
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: Text("Printing"),
                                                  content: Container(
                                                    width: 400,
                                                    height: 500,
                                                    child: PdfPreview(
                                                      allowSharing: false,
                                                      canChangePageFormat: false,
                                                      build: (format) =>
                                                          _generatePdf(
                                                              format,
                                                              widget.patient
                                                                      .dailyForm[
                                                                  index1]),
                                                    ),
                                                  ),
                                                ));
                                        break;
                                      case MenuItems.more:
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  content: Container(
                                                    width: width,
                                                    height: height * 0.6,
                                                    child: ListView.builder(
                                                      itemBuilder:
                                                          (BuildContext context,
                                                                  int index) =>
                                                              SizedBox(
                                                        height: height * 0.6,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                "${widget.patient.dailyForm[index1].finding == "" ? "No Finding" : "Finding : ${widget.patient.dailyForm[index1].finding}"}",
                                                                style: TextStyle(
                                                                    color: teal,
                                                                    fontSize: 13),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                              child: Text(
                                                                "${widget.patient.dailyForm[index1].assessment == "" ? "No Assessment" : "Assessment : ${widget.patient.dailyForm[index1].assessment}"}",
                                                                style: TextStyle(
                                                                    color: teal,
                                                                    fontSize: 13),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                "${widget.patient.dailyForm[index1].comment == "" ? "No Comment" : "Comment : ${widget.patient.dailyForm[index1].comment}"}",
                                                                style: TextStyle(
                                                                    color: teal,
                                                                    fontSize: 13),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                "${widget.patient.dailyForm[index1].discharge == "" ? "No Discharge" : "Discharge : ${widget.patient.dailyForm[index1].discharge}"}",
                                                                style: TextStyle(
                                                                    color: teal,
                                                                    fontSize: 13),
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Container(
                                                                width: width,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey[200],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "Consultation",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                orange),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                8.0),
                                                                        child: Text(
                                                                          "${widget.patient.dailyForm[index1].consultation.to == "" ? "No Consults" : "Consultation with : ${widget.patient.dailyForm[index1].consultation.to}"}",
                                                                          style: TextStyle(
                                                                              color:
                                                                                  deepBlue,
                                                                              fontSize:
                                                                                  12),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                8.0),
                                                                        child: Text(
                                                                          "${widget.patient.dailyForm[index1].consultation.why == "" ? "No Reason" : "Consultation Reason : ${widget.patient.dailyForm[index1].consultation.why}"}",
                                                                          style: TextStyle(
                                                                              color:
                                                                                  deepBlue,
                                                                              fontSize:
                                                                                  12),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                8.0),
                                                                        child: Text(
                                                                          "${widget.patient.dailyForm[index1].consultation.why == "" ? "No Reply" : "Consultation Reply : ${widget.patient.dailyForm[index1].consultation.replay}"}",
                                                                          style: TextStyle(
                                                                              color:
                                                                                  deepBlue,
                                                                              fontSize:
                                                                                  12),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      itemCount: 1,
                                                    ),
                                                  ),
                                                ));
                                        break;
                                    }
                                  },
                                  itemHeight: height * 0.05,
                                  dropdownWidth: width * 0.39,
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  dropdownElevation: 8,
                                  offset: Offset(-width * 0.35, 5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: height * 0.55,
                          width: width,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount:
                                widget.patient.dailyForm[index1].items.length,
                            itemBuilder: (context, index) => ListTile(
                              title: Text(
                                "${index + 1}. ${widget.patient.dailyForm[index1].items[index].text}",
                                style: TextStyle(
                                    color: teal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              subtitle: Text(
                                  "${widget.patient.dailyForm[index1].items[index].date ==""?"No Date":widget.patient.dailyForm[index1].items[index].date}",
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 13)),
                              trailing: Checkbox(
                                onChanged: null,
                                value: widget.patient.dailyForm[index1]
                                            .items[index].complete ==
                                        ""
                                    ? false
                                    : true,
                                fillColor: MaterialStateProperty.all(orange),
                                //shape: CircleBorder()
                                //checkColor: orange,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: height * 0.04,
                  width: dailyFormIndex * 13.0,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.patient.dailyForm.length,
                      itemBuilder: (context, index) => Container(
                            width: 9.0,
                            height: 9.0,
                            margin: EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current == dailyFormIndex - 1 - index
                                  ? orange
                                  : Colors.grey,
                            ),
                          )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String text;
  final IconData icon;
  final Color iconColor;
  const MenuItem({
    @required this.text,
    @required this.icon,
    @required this.iconColor,
  });
}

class MenuItems {
  static const List<MenuItem> Items = [edit, delete, print, more];
  static const edit =
      MenuItem(text: 'Edit', icon: Icons.edit, iconColor: Colors.blue);
  static const delete =
      MenuItem(text: 'Delete', icon: Icons.delete, iconColor: Colors.red);
  static const print =
      MenuItem(text: 'Print', icon: Icons.print, iconColor: deepBlue);
  static const more = MenuItem(
      text: 'Show More', icon: Icons.filter_list, iconColor: Colors.deepOrangeAccent);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: item.iconColor, size: 22),
        const SizedBox(
          width: 10,
        ),
        Text(
          item.text,
          style: TextStyle(
            color: teal,
          ),
        ),
      ],
    );
  }
}
