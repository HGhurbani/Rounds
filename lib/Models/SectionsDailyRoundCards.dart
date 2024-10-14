import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rounds/AddScreens/AddDailyRoundSectionsScreen.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:rounds/Screens/HomeScreen.dart';
import 'package:rounds/Screens/ProfileScreen.dart';
import 'package:rounds/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:rounds/VideoItems.dart';
import 'package:http/http.dart' as http;
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:flutter/services.dart';

class SectionsDailyRoundCards extends StatefulWidget {
  final String section;
  final int id;
  final List<dynamic> sick;
  final String actionName;
  final String NonormalValue;

  SectionsDailyRoundCards(this.section, this.sick, this.id, this.actionName,
      [this.NonormalValue]);

  @override
  _SectionsDailyRoundCardsState createState() =>
      _SectionsDailyRoundCardsState();
}

class _SectionsDailyRoundCardsState extends State<SectionsDailyRoundCards> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer advancedPlayer;

  @override
  void initState() {
    super.initState();
    initPlayer();
    //print("NormalValue ======== ${widget.NonormalValue}");
  }

  @override
  void dispose() {
    super.dispose();
    advancedPlayer.dispose();
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

  Widget slider() {
    return Slider(
        activeColor: deepBlue,
        inactiveColor:teal,
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

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    advancedPlayer.seek(newDuration);
  }

  successMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> HomeScreen()), (route) => false);
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

  delete(context, index, indexList) async {
    try {
      FormData formData = FormData.fromMap({
        "action": 'delete-sick-daily-round',
        "key": 'os14042020ah',
        "index": index,
        "sick_id": widget.id,
        "action_name": widget.actionName
      });

      Response response =
          await Dio().post("https://medicall-rounds.com/api", data: formData);
      //var responseServer = jsonDecode(response.data);
      SuccessModel successModel = SuccessModel.fromJson(response.data);
      if (successModel.st == 'success') {
        setState(() {
          widget.sick.removeAt(indexList);
        });
      } else {
        Fluttertoast.showToast(
            msg: "Please try again ..",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.deepOrangeAccent,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } catch (e) {
      print("Exception Caught : $e");
    }
  }

  Future<void> share({test, date, result, val, filePath}) async {

    if(filePath!=null){
      http.Response response = await http.get(filePath);
      await WcFlutterShare.share(
          sharePopupTitle: 'share',
          subject: 'Data',
          text: 'test :  $test\ndate :  $date\nresult :  $result\nval :  ',
          fileName: 'image.jpg',
          mimeType: 'image/jpg',
          bytesOfFile: response.bodyBytes);

    }else{
      await FlutterShare.share(
                  title: 'Data',
                  text: 'test :  $test\ndate :  $date\nresult :  $result\nval :  ',
                  chooserTitle: 'Share with');
    }

  }
_showToast(){
  Fluttertoast.showToast(
      msg: "Please Wait, Collecting Data ..",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.deepOrangeAccent,
      textColor: Colors.white,
      fontSize: 20.0
  );
}
  @override
  Widget build(BuildContext context) {
   double width= MediaQuery.of(context).size.width;
   double height= MediaQuery.of(context).size.height;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              widget.section,
              style: TextStyle(color: teal, fontWeight: FontWeight.bold),
            ),
          ),
          widget.sick.length == 0
              ? Center(
                  child: Text(
                    'No data',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : Container(
                  height:height * .5,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: widget.sick.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.red),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Container(
                                                  width: 9,
                                                  height: 9,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle, color: Colors.white,
                                                  ),

                                                  //   child: Image.network(widget.sick[index].result_image),
                                                ),
                                                Text(
                                                  widget.sick[index].title,
                                                  style: TextStyle(
                                                      color: teal),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              widget.sick[index].date,
                                              style:
                                                  TextStyle(color: teal),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  "Result: " +
                                                      widget.sick[index].result,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    right: 30,
                                                    top: 10,
                                                    bottom: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      (widget.sick[index].image.length == 0 &&
                                              widget.sick[index].image ==
                                                  null &&
                                              widget.sick[index].image.length ==
                                                  null &&
                                              widget.sick[index].video.length ==
                                                  0)
                                          ? Container()
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                (widget.sick[index].image
                                                                .length ==
                                                            0 ||
                                                        widget.sick[index]
                                                                .image ==
                                                            null ||
                                                        widget.sick[index].image
                                                                .length ==
                                                            null)
                                                    ? Container()
                                                    : CarouselSlider(
                                                        options:
                                                            CarouselOptions(),
                                                        items: widget
                                                            .sick[index].image
                                                            .map<Widget>(
                                                                (item) =>
                                                                    Container(
                                                                      child: GestureDetector(
                                                                          onTap: () {
                                                                            AlertDialog alert = AlertDialog(
                                                                                title: Text("Picture"),
                                                                                content: Container(
                                                                                    width: 300,
                                                                                    height: 400,
                                                                                    child: PhotoView(
                                                                                      imageProvider: NetworkImage(item),
                                                                                      minScale: 0.25,
                                                                                      maxScale: 0.5,
                                                                                    )));
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return alert;
                                                                              },
                                                                            );
                                                                          },
                                                                          child: Center(child: Image.network(item, fit: BoxFit.cover, width: 1000))),
                                                                    ))
                                                            .toList(),
                                                      ),
                                                (widget.sick[index].video
                                                            .length ==
                                                        0)
                                                    ? Container()
                                                    : Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: VideoItems(
                                                          videoPlayerController:
                                                              VideoPlayerController
                                                                  .network(widget
                                                                      .sick[
                                                                          index]
                                                                      .video),
                                                          looping: false,
                                                          autoplay: true,
                                                        ),
                                                      ),
                                                (widget.sick[index].audio
                                                            .length ==
                                                        0)
                                                    ? Container()
                                                    : Container(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .03,
                                                                  top: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .1),
                                                              child: Text(
                                                                'Audio : ',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                            ),
                                                            slider(),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                IconButton(
                                                                  icon: Icon(Icons
                                                                      .play_arrow),
                                                                  onPressed:
                                                                      () {
                                                                    advancedPlayer.play(widget
                                                                        .sick[
                                                                            index]
                                                                        .audio);
                                                                  },
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(Icons
                                                                      .pause),
                                                                  onPressed:
                                                                      () {
                                                                    advancedPlayer
                                                                        .pause();
                                                                  },
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .stop),
                                                                  onPressed:
                                                                      () {
                                                                    advancedPlayer
                                                                        .stop();
                                                                  },
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                              ],
                                            ),
                                      widget.sick[index].result_image != null
                                          ? widget.sick[index].result_image ==
                                                  ""
                                              ? Container()
                                              : Container(
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          "Result Image",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 200,
                                                        child: GestureDetector(
                                                            onTap: () {
                                                              AlertDialog alert = AlertDialog(
                                                                  title: Text("Result Picture"),
                                                                  content: Container(
                                                                      width: 250,
                                                                      height: 300,
                                                                      child: PhotoView(
                                                                        imageProvider: NetworkImage(widget
                                                                            .sick[index]
                                                                            .result_image),
                                                                        minScale:
                                                                            0.25,
                                                                        maxScale:
                                                                            0.5,
                                                                      )));
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return alert;
                                                                },
                                                              );
                                                            },
                                                            child: Center(
                                                                child: // Image.asset("images/approval.png", fit: BoxFit.cover, width: 1000)
                                                                    Container(
                                                              width: 250,
                                                              height: 200,
                                                              decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                      image: NetworkImage(widget
                                                                          .sick[
                                                                              index]
                                                                          .result_image))),
                                                            ))),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                          : Container()
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: () {
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             AddDailyRoundSectionsScreen(
                                          //               widget.section,
                                          //               widget.id,
                                          //               widget
                                          //                   .sick[index].title,
                                          //               widget.sick[index].date,
                                          //               widget
                                          //                   .sick[index].result,
                                          //               widget.sick[index]
                                          //                   .normalValue,
                                          //               widget
                                          //                   .sick[index].index,
                                          //               widget.NonormalValue,
                                          //             )));
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        )),
                                    GestureDetector(
                                        onTap: () {
                                          Fluttertoast.showToast(
                                              msg: "Deleting",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.deepOrangeAccent,
                                              textColor: Colors.white,
                                              fontSize: 16.0
                                          );
                                          delete(context,
                                              widget.sick[index].index, index);
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        )),
                                    GestureDetector(
                                        onTap: () {
                                          _showToast();
                                          if(widget.sick[index].image.length == 0){
                                            share(
                                             test:    widget.sick[index].title,
                                             date: widget.sick[index].date,
                                             result: widget.sick[index].result,
                                             val: widget.sick[index].normalValue,
                                           );
                                          }else(
                                              share(
                                                  test:    widget.sick[index].title,
                                                  date: widget.sick[index].date,
                                                  result: widget.sick[index].result,
                                                  val: widget.sick[index].normalValue,
                                                  filePath: widget.sick[index].image[0]
                                          )
                                          );
                                        },
                                        child: Icon(
                                          Icons.share,
                                          color: Colors.black,
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 10),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.blue),
                  child: TextButton(
                      onPressed: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             AddDailyRoundSectionsScreen(
                        //                 widget.section,
                        //                 widget.id,
                        //                 "",
                        //                 "",
                        //                 "",
                        //                 "",
                        //                 0,
                        //                 widget.NonormalValue)));
                      },
                      child: Text(
                        'Add New',
                        style: TextStyle(
                          color: const Color(0xffffffff),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
