import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageDetail extends StatelessWidget {
  final String imageUrl;

  FullScreenImageDetail({@required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          backgroundDecoration: BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
