import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounds/AddScreens/AddMedicinesScreen.dart';
import 'package:rounds/AddScreens/AddVaccinationScreen.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:rounds/Screens/LaboratoryScreen.dart';
import 'package:rounds/Screens/NonRadiologyScreen.dart';
import 'package:rounds/Screens/RadiologyScreen.dart';
// import 'package:rounds/Screens/VitalSignsScreen.dart';
import 'package:rounds/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_share/flutter_share.dart';

class GeneralProfileScreen extends StatefulWidget {
  final DoctorSicks patient;
  final int id;

  GeneralProfileScreen(this.patient, this.id);

  @override
  _GeneralProfileScreenState createState() => _GeneralProfileScreenState();
}

class _GeneralProfileScreenState extends State<GeneralProfileScreen> {
  double itemHeight;
  double itemWidth;
  var size;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    size = MediaQuery.of(context).size;
    itemHeight = (size.height) / 2;
    itemWidth = size.width / 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Existing widgets for displaying patient data

          // Medications Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medications :',
                  style: TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          // Share all medications
                        },
                        child: Icon(Icons.share)),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddMedicinesScreen(
                                      widget.id, widget.patient, "", "", 0)));
                        },
                        child: Icon(Icons.add)),
                  ],
                ),
              ],
            ),
          ),

          // Display Medications List
          widget.patient.medication == null || widget.patient.medication.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text('No Medication Added')),
                )
              : Container(
                  height: height * 0.21,
                  padding: EdgeInsets.all(7),
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.patient.medication.length,
                      itemBuilder: (ctx, index) {
                        return Slidable(
                          key: ValueKey(index),
                          actionPane: SlidableBehindActionPane(),
                          actionExtentRatio: 0.25,
                          secondaryActions: <Widget>[
                            // Edit Medication
                            IconSlideAction(
                              caption: 'Edit',
                              color: Colors.blueAccent,
                              icon: Icons.edit,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddMedicinesScreen(
                                                widget.id,
                                                widget.patient,
                                                widget.patient.medication[index]
                                                    .medicationTitle,
                                                widget.patient.medication[index]
                                                    .medicationText,
                                                widget.patient.medication[index]
                                                    .index)));
                              },
                            ),
                            // Delete Medication
                            IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                // Call function to delete medication
                              },
                            ),
                          ],
                          child: Card(
                            elevation: 6.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: width * 0.86, // Adjust the width
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              'Title : ',
                                              style: TextStyle(
                                                color: deepBlue,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              widget.patient.medication[index]
                                                      .medicationTitle ??
                                                  '', // Display empty if title is null
                                              style: TextStyle(
                                                color: teal,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                // Share medication text
                                              },
                                              child: Icon(
                                                Icons.share,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'Text : ',
                                            style: TextStyle(
                                              color: deepBlue,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            widget.patient.medication[index]
                                                    .medicationText ??
                                                '', // Display empty if text is null
                                            style: TextStyle(
                                              color: teal,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
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
                      }),
                ),

          // Vaccinations Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vaccinations : ',
                  style: TextStyle(
                    color: deepBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          // Share all vaccinations
                        },
                        child: Icon(Icons.share)),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddVaccinationScreen(
                                      widget.id,
                                      widget.patient,
                                      "",
                                      "",
                                      "",
                                      0)));
                        },
                        child: Icon(Icons.add)),
                  ],
                ),
              ],
            ),
          ),

          // Display Vaccinations List
          widget.patient.vaccination == null ||
                  widget.patient.vaccination.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text('No Vaccinations Added')),
                )
              : Container(
                  height: height * 0.29,
                  padding: EdgeInsets.all(7),
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.patient.vaccination.length,
                      itemBuilder: (ctx, index) {
                        return Slidable(
                          key: ValueKey(index),
                          actionPane: SlidableBehindActionPane(),
                          actionExtentRatio: 0.25,
                          secondaryActions: <Widget>[
                            // Edit Vaccination
                            IconSlideAction(
                              caption: 'Edit',
                              color: Colors.blueAccent,
                              icon: Icons.edit,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddVaccinationScreen(
                                                widget.id,
                                                widget.patient,
                                                widget
                                                    .patient
                                                    .vaccination[index]
                                                    .vaccinationName,
                                                widget
                                                    .patient
                                                    .vaccination[index]
                                                    .vaccinationDate,
                                                widget
                                                    .patient
                                                    .vaccination[index]
                                                    .vaccinationAge,
                                                widget
                                                    .patient
                                                    .vaccination[index]
                                                    .index)));
                              },
                            ),
                            // Delete Vaccination
                            IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                // Call function to delete vaccination
                              },
                            ),
                          ],
                          child: Card(
                            elevation: 6.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: width * 0.86, // Adjust the width
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              'Name ',
                                              style: TextStyle(
                                                color: deepBlue,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              widget.patient.vaccination[index]
                                                      .vaccinationName ??
                                                  '', // Display empty if name is null
                                              style: TextStyle(
                                                color: teal,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                // Share vaccination details
                                              },
                                              child: Icon(
                                                Icons.share,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'Date ',
                                            style: TextStyle(
                                              color: deepBlue,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            widget.patient.vaccination[index]
                                                    .vaccinationDate ??
                                                '', // Display empty if date is null
                                            style: TextStyle(
                                              color: teal,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            'Age ',
                                            style: TextStyle(
                                              color: deepBlue,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            widget.patient.vaccination[index]
                                                    .vaccinationAge ??
                                                '', // Display empty if age is null
                                            style: TextStyle(
                                              color: teal,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
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
                      }),
                ),
        ],
      ),
    );
  }
}
