import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rounds/Screens/FullScreenImage.dart';
import '../colors.dart';

class VideoDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const VideoDetailsScreen({Key key, this.data}) : super(key: key);

  @override
  _VideoDetailsScreenState createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  List<VideoPlayerController> _videoControllers = [];
  List<ChewieController> _chewieControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayers();
  }

  @override
  void dispose() {
    _chewieControllers.forEach((controller) => controller.dispose());
    _videoControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeVideoPlayers() {
    if (widget.data['videoUrls'] != null && widget.data['videoUrls'].isNotEmpty) {
      widget.data['videoUrls'].forEach((videoUrl) {
        VideoPlayerController videoController = VideoPlayerController.network(videoUrl);
        ChewieController chewieController = ChewieController(
          videoPlayerController: videoController,
          autoInitialize: true,
          looping: false,
        );
        _videoControllers.add(videoController);
        _chewieControllers.add(chewieController);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['title']),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleAndDescription(),
                SizedBox(height: 10),
                _buildSection(
                  context,
                  Icons.image,
                  'Images',
                  widget.data['images'],
                  _buildImagesList,
                ),
                _buildSection(
                  context,
                  Icons.video_library,
                  'Videos',
                  widget.data['videoUrls'],
                  _buildVideosList,
                ),
                _buildSection(
                  context,
                  Icons.insert_drive_file,
                  'Documents',
                  widget.data['documentUrls'],
                  _buildDocumentsList,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data['title'] ?? 'No Title',
            style: TextStyle(color: teal, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            widget.data['description'] ?? 'No Description',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, IconData icon, String title, List<dynamic> data, Widget Function() buildContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, icon, title),
        data == null || data.isEmpty
            ? _buildNoDataMessage('No $title Selected')
            : buildContent(),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: teal,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagesList() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.data['images'].map<Widget>((imageUrl) {
            return GestureDetector(
              onTap: () => showFullScreenImage(context, imageUrl),
              child: Container(
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVideosList() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _chewieControllers.map<Widget>((chewieController) {
            int index = _chewieControllers.indexOf(chewieController);
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 200,
              child: AspectRatio(
                aspectRatio: _videoControllers[index].value.aspectRatio,
                child: Chewie(
                  controller: chewieController,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.data['documentUrls'].length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.insert_drive_file, color: teal),
            title: Text(widget.data['documentUrls'][index].split('/').last),
            onTap: () {
              // Add your document opening logic here
            },
          );
        },
      ),
    );
  }

  Widget _buildNoDataMessage(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: teal,
            fontSize: 18,
            // fontWeight: FontWeight.bold,
          ),
        ),
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
}
