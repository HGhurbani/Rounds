import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:photo_view/photo_view.dart';
import 'package:chewie/chewie.dart';
import '../colors.dart';

class ConceptDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  ConceptDetailsScreen({this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consent Details'),
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
                  DataRow('Title', Icons.title, data['title']),
                  DataRow('Description', Icons.description, data['description']),
                  DataRow('Procedure Risk', Icons.assignment, data['procedure_risk']),
                ],
              ),
            ),

            SizedBox(height: 16.0),

            // Images Section
            SectionTitle(title: 'Images', icon: Icons.image),
            SizedBox(
              height: 200,
              child: data['images'] != null && data['images'].isNotEmpty
                  ? ListView.builder(
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
              )
                  : Center(child: Text('No images available')),
            ),

            SizedBox(height: 16.0),

            // Video Section
            SectionTitle(title: 'Videos', icon: Icons.videocam),
            SizedBox(
              height: 200,
              child: data['videos'] != null && data['videos'].isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data['videos'].length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChewieVideoPlayer(videoUrl: data['videos'][index]),
                  );
                },
              )
                  : Center(child: Text('No videos available')),
            ),

            SizedBox(height: 16.0),

            // Audio Section
            SectionTitle(title: 'Audios', icon: Icons.audiotrack),
            SizedBox(
              height: 100,
              child: data['audios'] != null && data['audios'].isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data['audios'].length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: AudioPlayerWidget(audioUrl: data['audios'][index]),
                  );
                },
              )
                  : Center(child: Text('No audios available')),
            ),
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
  bool _isLoading = true;  // متغير لمتابعة حالة التحميل
  bool _hasError = false;  // متغير لمتابعة حالة وجود خطأ

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
        setState(() {
          // تحقق مما إذا كان الفيديو جاهزًا
          if (_videoPlayerController.value.isInitialized) {
            _isLoading = false;  // انتهى التحميل
          } else if (_videoPlayerController.value.hasError) {
            _isLoading = false;
            _hasError = true;  // حدث خطأ
          }
        });
      })
      ..initialize().catchError((error) {
        setState(() {
          _isLoading = false;
          _hasError = true;  // معالجة الخطأ
        });
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // عرض مؤشر التحميل أثناء انتظار الفيديو
      return Center(child: CircularProgressIndicator());
    } else if (_hasError) {
      // عرض رسالة خطأ إذا لم يتمكن من تحميل الفيديو
      return Center(child: Text('Error loading video'));
    } else {
      // عرض الفيديو إذا كان جاهزًا
      return Chewie(
        controller: _chewieController,
      );
    }
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
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
      setState(() {
        _audioPlayerState = state;
        _isPlaying = _audioPlayerState == AudioPlayerState.PLAYING;
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
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: teal,
            ),
            onPressed: () {
              _isPlaying
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
