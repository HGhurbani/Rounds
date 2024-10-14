import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart'; // استيراد مكتبة المشغل الصوتي
import 'package:rounds/Screens/FullScreenImage.dart';
import '../colors.dart';

class RadiologyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const RadiologyDetailScreen({Key key, this.data}) : super(key: key);

  @override
  _RadiologyDetailScreenState createState() => _RadiologyDetailScreenState();
}

class _RadiologyDetailScreenState extends State<RadiologyDetailScreen> {
  ChewieController _chewieController;
  AudioPlayer _audioPlayer = AudioPlayer(); // إنشاء مثيل من مشغل الصوت
  VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    if (widget.data['video'] != null && widget.data['video'].isNotEmpty) {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _audioPlayer.dispose(); // تحرير الموارد عند الانتهاء
    super.dispose();
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.network(widget.data['video']);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
      looping: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['title']),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              _buildResultDetailsSection(),
              SizedBox(height: 10),
              _buildResultImagesSection(),
              SizedBox(height: 10),
              _buildAudioSection(),
              _buildImageSection(),
              _buildVideoSection(),
              _buildDocumentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultDetailsSection() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Result Details',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.data['result'] ?? 'No result provided',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultImagesSection() {
    if (widget.data['result_images'] == null || widget.data['result_images'].isEmpty) {
      return _noDataAvailableWidget('No result images added');
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Result Images',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int index = 0; index < widget.data['result_images'].length; index++)
                    GestureDetector(
                      onTap: () => _showFullScreenImage(context, widget.data['result_images'][index]),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            key: UniqueKey(),
                            imageUrl: widget.data['result_images'][index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    if (widget.data['audios'] == null || widget.data['audios'].isEmpty) {
      return _noDataAvailableWidget('No audios added');
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Audios',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 100, // تحديد ارتفاع مناسب
            padding: EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(widget.data['audios'].length, (index) {
                  return _buildAudioPlayer(widget.data['audios'][index]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAudioPlayer(String audioUrl) {
    return Container(
      width: 300, // تحديد عرض مناسب لكل مشغل صوت
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.teal, size: 30),
            onPressed: () {
              _playAudio(audioUrl);
            },
          ),
          Text('Play Audio', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (widget.data['images'] == null || widget.data['images'].isEmpty) {
      return _noDataAvailableWidget('No images added');
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Images',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 1),
          Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int index = 0; index < widget.data['images'].length; index++)
                    GestureDetector(
                      onTap: () => _showFullScreenImage(context, widget.data['images'][index]),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            key: UniqueKey(),
                            imageUrl: widget.data['images'][index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    if (widget.data['videos'] == null || widget.data['videos'].isEmpty) {
      return _noDataAvailableWidget('No videos added');
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Videos',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 200, // تحديد ارتفاع مناسب
            padding: EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(widget.data['videos'].length, (index) {
                  return _buildVideoPlayer(widget.data['videos'][index]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              enableRotation: true,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildVideoPlayer(String videoUrl) {
    VideoPlayerController videoPlayerController = VideoPlayerController.network(videoUrl);
    ChewieController chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoInitialize: true,
      looping: false,
      aspectRatio: 16 / 9,
    );

    return Container(
      width: 300, // تحديد عرض مناسب لكل فيديو
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Chewie(
        controller: chewieController,
      ),
    );
  }

  Widget _buildDocumentsSection() {
    if (widget.data['documents'] == null || widget.data['documents'].isEmpty) {
      return _noDataAvailableWidget('No documents added');
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: teal,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Documents',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.data['documents'].length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Document ${index + 1}'),
                trailing: Icon(Icons.picture_as_pdf),
                onTap: () {
                  // عرض المستند في طريقة العرض المناسبة
                  // يمكنك إضافة عرض PDF هنا إذا كنت تستخدم مستندات PDF
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _noDataAvailableWidget(String message) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
      ),
      padding: EdgeInsets.all(16),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey, fontSize: 16, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
    );
  }

  void showFullScreenImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageDetail(imageUrl: url),
      ),
    );
  }

  void _playAudio(String url) async {
    int result = await _audioPlayer.play(url); // تشغيل الصوت
    if (result == 1) {
      // تم تشغيل الصوت بنجاح
      print('Audio playing');
    }
  }
}
