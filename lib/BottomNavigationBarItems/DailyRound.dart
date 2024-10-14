import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounds/Models/CardInfo.dart';
import 'package:rounds/Network/DoctorDataModel.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/Screens/CloudScreen.dart';
import 'package:rounds/Screens/VideosScreen.dart';
import 'package:rounds/Screens/ReadyOrderScreen.dart';
import 'package:rounds/Screens/patient_list.dart';
import 'package:rounds/Screens/chatScreen.dart';

class DailyRound extends StatefulWidget {
  final DoctorData doctor;
  final List<DoctorSicks> filteredSick;

  DailyRound(this.doctor, this.filteredSick);

  @override
  _DailyRoundState createState() => _DailyRoundState();
}

class _DailyRoundState extends State<DailyRound> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 35.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PatientListScreen(widget.doctor, widget.filteredSick),
                          ),
                        );
                      },
                      child: CardInfo('Patients List', 'images/medical-record1.png'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadyOrderScreen(),
                          ),
                        );
                      },
                      child: CardInfo('Ready orders', 'images/health-check.png'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CloudScreen(widget.doctor?.cloud),
                          ),
                        );
                      },
                      child: CardInfo('Cloud', 'images/data-storage.png'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideosScreen(2),
                          ),
                        );
                      },
                      child: CardInfo('Education / CME', 'images/check-up.png'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideosScreen(1),
                          ),
                        );
                      },
                      child: CardInfo(
                          'Useful Information ( Patient Education )', 'images/healthcare.png'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Fluttertoast.showToast(
                            msg: "Working On Progress",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.deepOrangeAccent,
                            textColor: Colors.white,
                            fontSize: 18.0
                        );
                      },
                      child: CardInfo(
                          'Patient    Communication', 'images/doctors.png'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
