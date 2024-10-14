import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:flutter/material.dart';

import '../AddScreens/AddMedicinesScreen.dart';

class MedicinesScreen extends StatefulWidget {
  final DoctorSicks patient;
  final String lastRound;
  final int id;

  MedicinesScreen(this.patient, this.lastRound, this.id);

  @override
  _MedicinesScreenState createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  double itemHeight;
  double itemWidth;
  var size;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    itemHeight = (size.height) / 2;
    itemWidth = size.width / 2;

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Medicines'),
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.topLeft,
                        colors: <Color>[Color(0xff1e3be8), Color(0xff8f00ff)])),
              ),
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                      gradient: LinearGradient(
                          colors: [Color(0xff1e3be8), Color(0xff8f00ff)],
                          begin: Alignment.topRight,
                          end: Alignment.topLeft)),
                ),
                ListView(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white70, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      elevation: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 8, top: 8, left: 5, bottom: 8),
                            child: SizedBox(
                              height: 100,
                              child: CircleAvatar(
                                backgroundImage: (widget.patient?.avatar == null ||
                                        widget.patient?.avatar == false)
                                    ? AssetImage('images/doctoravatar.png')
                                    : NetworkImage(widget.patient.avatar),
                                radius: 50,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    widget.patient.name,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.patient.surgery,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage("images/icons/teamwork.png"),
                                      color: Color(0xFF4d65f8),
                                    ),
                                    Text(' ${widget.lastRound}'),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Color(0xff19d7e7)),
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddMedicinesScreen(
                                                              widget.id,
                                                              widget.patient,
                                                              "",
                                                              "",
                                                              0)));
                                            },
                                            child: Text(
                                              'Add Medication',
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
                          )
                        ],
                      ),
                    ),
                  ),
                  widget.patient.medication.length == 0
                      ? Center(
                          child: Text(
                            'No Medicines',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * .3,
                          child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: (itemWidth / itemHeight),
                              ),
                              itemCount: widget.patient.medication.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                            child: Text(
                                          widget.patient.medication[index]
                                              .medicationTitle,
                                          style: TextStyle(color: Colors.blue),
                                        )),
                                        Flexible(
                                            child: Text(
                                                "${widget.patient.medication[index].medicationText}")),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                ]),
              ],
            )));
  }
}
