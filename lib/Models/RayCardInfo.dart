import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
class RayCardInfo extends StatelessWidget {
  final String name;
  final String desc;
  final String img;
  RayCardInfo(this.name, this.img, this.desc);
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        elevation: 20,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 150,
                  height: 150,
                  child:GestureDetector(
                  onTap: (){
                    AlertDialog alert = AlertDialog(
                        title: Text("Ray Picture"),
                        content: Container(
                            width: 300,
                            height: 350,
                            child:PhotoView(imageProvider:NetworkImage(img),minScale:0.25,maxScale:0.5,)
                        )
                    );
                    // show the dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  },
                    child: Container(
                      child:Image.network(img),
                  ),
                ),

                //Image.asset(img)
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(name, style: TextStyle(
                      color: Color(0xff4d65f8),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('Result',style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(desc,),
                  ),
                ],
              ),
            ),
          ],
        )
        );

  }
}
