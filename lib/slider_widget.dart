import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rounds/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:pinch_zoom/pinch_zoom.dart';


class BuildSliderWidget extends StatefulWidget {
  const BuildSliderWidget({
    Key key,
    @required this.images,
  }) : super(key: key);
  final List<String> images;

  @override
  State<BuildSliderWidget> createState() => _BuildSliderWidgetState();
}

class _BuildSliderWidgetState extends State<BuildSliderWidget> {
  final boardController = PageController();
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Expanded(
          child: CarouselSlider.builder(
            itemCount: widget.images.length,
            options: CarouselOptions(
                aspectRatio: 1,
                height: height*0.3,
                viewportFraction: 1,
                autoPlayAnimationDuration: const Duration(seconds: 10),
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlay: true,
                reverse: true,
                autoPlayInterval: const Duration(seconds: 15),
                pageSnapping: false,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                onPageChanged: (index, reason) {
                  setState(() {
                    activeIndex = index;
                  });
                }),
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return Container(
                height:  height*0.3,
                width: double.infinity,
                padding: EdgeInsets.all(8.0),
                child:
                PinchZoom(
                  resetDuration: Duration(seconds: 10),
                  maxScale: 15,
                  onZoomStart: (){print('Start zooming');},
                  onZoomEnd: (){print('Stop zooming');},
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(child: CircularProgressIndicator(color: teal,)),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: AnimatedSmoothIndicator(
            activeIndex: activeIndex,
            count: widget.images.length,
            axisDirection: Axis.horizontal,
            effect: JumpingDotEffect(
              dotColor: orange,
              activeDotColor: teal,
              dotHeight: 8,
              dotWidth: 8,
              spacing: 12,
            ),
          ),
        ),
      ],
    );
  }
}
