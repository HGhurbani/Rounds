import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../colors.dart';

class ProfilePatientCard extends StatefulWidget {
  final DoctorSicks patient;

  ProfilePatientCard(this.patient);

  @override
  State<ProfilePatientCard> createState() => _ProfilePatientCardState();
}

class _ProfilePatientCardState extends State<ProfilePatientCard> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    TextStyle style = TextStyle(
        fontSize: 16, color: Colors.orange, fontWeight: FontWeight.w600);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.white,
      elevation: 10,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.patient.avatar != null &&
                      widget.patient.avatar.isNotEmpty
                  ? NetworkImage(widget.patient.avatar)
                  : AssetImage('images/doctoravatar.png'),
              radius: width * 0.1,
            ),
            title: Text(
              widget.patient.name ?? '', // Display empty if name is null
              style: TextStyle(
                  color: teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 20),
            ),
            subtitle: Text(
              widget.patient.surgery ?? '', // Display empty if surgery is null
              style: TextStyle(color: teal, fontSize: 14),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // Add edit functionality here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // _showChoiceDialog(context);
                  },
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'File Number: ${widget.patient.fileNumber ?? ''}', // Display empty if file number is null
                  style: style,
                ),
                Text('Age: ${widget.patient.age ?? ''}',
                    style: style), // Display empty if age is null
                Text('Gender: ${widget.patient.gender ?? ''}',
                    style: style), // Display empty if gender is null
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add _showChoiceDialog and _deletePatient methods here as in the previous code snippet
}
