import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rounds/VideoItems.dart';
import 'package:rounds/colors.dart';
import 'package:video_player/video_player.dart';
import '../Network/SickModel.dart';

class ConsentDetailsScreen extends StatefulWidget {
  String audioUrl;
  String videoUrl;
  String title;
  Consebt consebt;

  ConsentDetailsScreen(this.videoUrl, this.title, this.audioUrl, this.consebt);

  @override
  _ConsentDetailsScreenState createState() => _ConsentDetailsScreenState();
}

class _ConsentDetailsScreenState extends State<ConsentDetailsScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Consent'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.consebt.image.isEmpty
                ? Text(
                    "No Consent Image",
                    style: style,
                  )
                : CachedNetworkImage(
                    imageUrl: widget.consebt.image ?? "",
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
            widget.videoUrl.isEmpty
                ? Text(
                    "No Video",
                    style: style,
                  )
                : Container(
                    width: 400,
                    height: 400,
                    child: VideoItems(
                      videoPlayerController:
                          VideoPlayerController.network(widget.videoUrl),
                      looping: true,
                      autoplay: true,
                    ),
                  ),
            widget.audioUrl.isEmpty
                ? Text(
                    "No Audio",
                    style: style,
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
                                advancedPlayer.play(widget.audioUrl);
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
