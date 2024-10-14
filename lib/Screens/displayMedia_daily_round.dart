import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:video_player/video_player.dart';

import '../VideoItems.dart';
import '../colors.dart';
import '../slider_widget.dart';

class DailyRoundMediaScreen extends StatefulWidget {
  var item;
  String noResult;

  DailyRoundMediaScreen(this.item, this.noResult);

  @override
  State<DailyRoundMediaScreen> createState() => _DailyRoundMediaScreenState();
}

class _DailyRoundMediaScreenState extends State<DailyRoundMediaScreen> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer advancedPlayer;

  @override
  void initState() {
    super.initState();
    initPlayer();
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

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    advancedPlayer.seek(newDuration);
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Container(
                height: height * 0.3,
                child: BuildSliderWidget(
              images: widget.item.image,
            )),
            widget.noResult == "NoResult"
                ? Container()
                : Container(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            "Result Image:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: orange),
                          ),
                         CachedNetworkImage(imageUrl: widget.item.result_image??"",
                           width: double.infinity,
                           fit: BoxFit.fill,
                           placeholder: (context, url) => Center(child: CircularProgressIndicator(color: teal,)),
                           errorWidget: (context, url, error) => Center(child: Text("No Result Image",style: style,)),)
                        ],
                      ),
                    ),
                  ),
            widget.item.video.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "No Video",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: orange),
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.width * 0.8,
                    child: VideoItems(
                      videoPlayerController:
                          VideoPlayerController.network(widget.item.video),
                      looping: false,
                      autoplay: true,
                    ),
                  ),
            widget.item.audio.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "No Audio",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: orange),
                      ),
                    ),
                  )
                : Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .03,
                              top: MediaQuery.of(context).size.width * .1),
                          child: Text(
                            'Audio : ',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                        slider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () {
                                advancedPlayer.play(widget.item.audio);
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
    );
  }
}
