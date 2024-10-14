import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounds/Models/SectionsDailyRoundCards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import 'package:rounds/colors.dart';
import 'package:rounds/Network/SickModel.dart';
import '../Network/SuccessModel.dart';
import 'add_vital.dart';

class VitalSignsScreen extends StatefulWidget {
  DoctorSicks sick;
  final int id;

  VitalSignsScreen(this.sick, this.id);

  @override
  _VitalSignsScreenState createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  AudioPlayer advancedPlayer;
  Duration _duration = Duration();
  Duration _position = Duration();
  List<VitalSigns> vitalSigns = [];

  @override
  void initState() {
    super.initState();
    initPlayer();
    getSick();
  }

  @override
  void dispose() {
    super.dispose();
    advancedPlayer.dispose();
  }

  void initPlayer() {
    advancedPlayer = AudioPlayer();

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
      },
    );
  }

  void delete(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('vital_signs')
          .doc(id)
          .delete();
      Fluttertoast.showToast(
        msg: "Deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: teal,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      getSick();
    } catch (e) {
      print("Exception Caught : $e");
    }
  }

  void getSick() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('vital_signs')
          .where('sick_id', isEqualTo: widget.id)
          .get();
      List<VitalSigns> vitalList = snapshot.docs
          .map((doc) => VitalSigns.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        vitalSigns = vitalList;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Please try again ..",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("Exception Caught : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    TextStyle style = TextStyle(
      fontSize: 15.0,
      color: deepBlue,
    );
    TextStyle style2 =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: teal);
    return Scaffold(
        appBar: AppBar(
          title: Text("Vital Signs"),
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddVitalScreen(widget.sick, widget.id, null)));
          },
          child: Icon(Icons.add),
          backgroundColor: teal,
        ),
        body: vitalSigns.isEmpty
            ? RefreshIndicator(
          onRefresh: () async {
            getSick();
          },
          child: ListView(
            children: [
              SizedBox(
                height: height * 0.3,
              ),
              Center(
                child: Text(
                  "No Vital Signs yet",
                  style: style2,
                ),
              ),
            ],
          ),
        )
            : SizedBox(
            height: height,
            child: RefreshIndicator(
                onRefresh: () async {
                  getSick();
                },
                child: ListView.builder(
                itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Slidable(
        key: ValueKey(index),
    actionPane: SlidableBehindActionPane(),
    actionExtentRatio: 0.25,
    child: Card(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0)),
    elevation: 4.0,
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Column(
    children: [
    Row(
    mainAxisAlignment:
    MainAxisAlignment.spaceBetween,
    children: [
    Container(),
    Text(
    "${vitalSigns[index].date}",
    style: style,
    ),
    IconButton(
    onPressed: () async {
    await FlutterShare.share(
    title: 'Data',
    text: 'Date: ${vitalSigns[index].date}\n'
    'Heart Rate: ${vitalSigns[index].heart_rate} \n'
    'Blood Pressure: ${vitalSigns[index].blood_pressure}\n'
    'Temperature: ${vitalSigns[index].temperature}\n'
    'Respiratory Rate: ${vitalSigns[index].respiratory_rate}\n'
    'Blood Sugar: ${vitalSigns[index].blood_sugar}\n'
    'Other: ${vitalSigns[index].other}\n',
    chooserTitle: 'Share with',
    );
    },
    icon: Icon(Icons.share),
    ),
    ],
    ),
    Row(
    mainAxisAlignment:
    MainAxisAlignment.spaceBetween,
    children: [
    Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
    buildColumn(
    "Heart Rate",
    vitalSigns[index].heart_rate,
    style,
    style2,
    ),
    buildColumn(
    "Blood Pressure",
    vitalSigns[index].blood_pressure,
    style,
    style2,
    ),
    buildColumn(
    "Temperature",
    vitalSigns[index].temperature,
    style,
    style2,
    ),
    ],
    ),
    Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
    buildColumn(
    "Respiratory Rate",
    vitalSigns[index].respiratory_rate,
    style,
    style2,
    ),
    buildColumn(
    "Blood Sugar",
    vitalSigns[index].blood_sugar,
    style,
    style2,
    ),
    buildColumn(
    "Others",
    vitalSigns[index].other,
    style,
    style2,
    ),
    ],
    ),
    ],
    ),
    Padding(
    padding: const EdgeInsets.all(4.0),
    child: vitalSigns[index].vital_file.isEmpty
    ? Container()
        : Column(
    children: [
    Padding(
    padding: const EdgeInsets.symmetric(
    horizontal: 20.0),
    child: Divider(
    thickness: 0.3,
    color: deepBlue,
    ),
    ),
    Text(
    "Audio",
    style: TextStyle(
    color: deepBlue, fontSize: 17),
    ),
    slider(index),
    Row(
    mainAxisAlignment:
    MainAxisAlignment.center,
    children: <Widget>[
    IconButton(
    icon: Icon(Icons.play_arrow),
    onPressed: () {
    advancedPlayer.play(
    vitalSigns[index]
        .vital_file);
    },
    ),
    IconButton(
    icon: Icon(Icons.pause),
    onPressed: () {
    advancedPlayer.pause();
    },
    ),
    IconButton(
    icon: Icon(Icons.stop),
    onPressed: () {
    advancedPlayer.stop();
    },
    )
    ],
    )
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    secondaryActions: <Widget>[
    Padding(
    padding: const EdgeInsets.symmetric(
    vertical: 6.0, horizontal: 2                          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: IconSlideAction(
          caption: 'Edit',
          color: Colors.blueAccent,
          icon: Icons.edit,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddVitalScreen(
                    widget.sick,
                    widget.id,
                    vitalSigns[index],
                  ),
                ));
          },
        ),
      ),
    ),
      Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 6.0, horizontal: 2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              delete(vitalSigns[index].id);
            },
          ),
        ),
      ),
    ],
        ),
                ),
                  itemCount: vitalSigns.length,
                ),
            ),
        ),
    );
  }

  Widget buildColumn(
      String text,
      String txt,
      TextStyle style,
      TextStyle style2,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: style,
        ),
        Container(
          width: 80,
          child: Text(
            txt,
            style: style2,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

