import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:photo_view/photo_view.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../colors.dart';

class VitalSignDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  VitalSignDetailScreen({this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vital Sign Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text Data Section
            SectionTitle(title: 'General Info', icon: Icons.info),
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  DataRow('Heart Rate', Icons.favorite_border, data['heart_rate']),
                  DataRow('Respiratory Rate', Icons.air, data['respiratary_rate']),
                  DataRow('Blood Sugar', Icons.favorite, data['blood_suger']),
                  DataRow('Blood Pressure', Icons.favorite_outline, data['blood_pressure']),
                  DataRow('Temperature', Icons.thermostat_outlined, data['temperature']),
                  DataRow('Others', Icons.error_outline, data['others']),
                  DataRow('Date', Icons.calendar_today, data['date']),
                ],
              ),
            ),

            SizedBox(height: 16.0),

            // Images Section
            SectionTitle(title: 'Images', icon: Icons.image),
            data['images'] != null && data['images'].isNotEmpty
                ? SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data['images'].length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageScreen(imageUrl: data['images'][index]),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: NetworkImage(data['images'][index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: 200,
                    ),
                  );
                },
              ),
            )
                : Center(child: Text('No images available')),

            SizedBox(height: 16.0),

            // Video Section
            SectionTitle(title: 'Videos', icon: Icons.videocam),
            data['videos'] != null && data['videos'].isNotEmpty
                ? Column(
              children: data['videos'].map<Widget>((videoUrl) {
                return ChewieVideoPlayer(videoUrl: videoUrl);
              }).toList(),
            )
                : Center(child: Text('No videos available')),

            SizedBox(height: 16.0),

            // Audio Section
            SectionTitle(title: 'Audio', icon: Icons.audiotrack),
            data['audio'] != null && data['audio'].isNotEmpty
                ? AudioPlayerWidget(audioUrl: data['audio'])
                : Center(child: Text('No audio available')),

            SizedBox(height: 16.0),

            // Documents Section
            SectionTitle(title: 'Documents', icon: Icons.insert_drive_file),
            data['documents'] != null && data['documents'].isNotEmpty
                ? Column(
              children: data['documents'].map<Widget>((docUrl) {
                return GestureDetector(
                  onTap: () => launch(docUrl),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file, color: teal),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            docUrl.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
                : Center(child: Text('No documents available')),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  SectionTitle({this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: teal),
          SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: teal),
          ),
        ],
      ),
    );
  }
}

class DataRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final dynamic value;

  DataRow(this.title, this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepOrange),
              SizedBox(width: 8.0),
              Text(title),
            ],
          ),
          Text(value != null ? value.toString() : 'Not available'),
        ],
      ),
    );
  }
}

class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  FullScreenImageScreen({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}

class ChewieVideoPlayer extends StatefulWidget {
  final String videoUrl;

  ChewieVideoPlayer({this.videoUrl});

  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  AudioPlayerWidget({this.audioUrl});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState = AudioPlayerState.STOPPED;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
      setState(() {
        _audioPlayerState = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, color: teal),
              SizedBox(width: 8.0),
              Text('Audio', style: TextStyle(color: teal)),
            ],
          ),
          IconButton(
            icon: Icon(
              _audioPlayerState == AudioPlayerState.PLAYING
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: teal,
            ),
            onPressed: () {
              _audioPlayerState == AudioPlayerState.PLAYING
                  ? _audioPlayer.pause()
                  : _audioPlayer.play(widget.audioUrl);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
