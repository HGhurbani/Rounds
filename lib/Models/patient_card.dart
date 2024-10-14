import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rounds/colors.dart';

class PatientCard extends StatelessWidget {
  final String name;
  final String post;
  final String doc;
  final String fileNumber;
  final String temperature;
  final String bloodPressure;
  final String sugarLevel;
  final String image;
  PatientCard(this.image, this.name, this.fileNumber, this.post, this.doc,
      this.temperature, this.bloodPressure, this.sugarLevel);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    TextStyle style =
        TextStyle(color: teal, fontSize: 15, fontWeight: FontWeight.w600);
    return Card(
        //color: Colors.grey,
        shape: RoundedRectangleBorder(
          // side: BorderSide(color: Colors.grey[400], width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  AlertDialog alert = AlertDialog(
                      title: Text("Picture"),
                      content: Container(
                        color: Colors.white,
                        width: width * 0.6,
                        height: width * 0.6,
                        child: image == null ||
                                image?.length == 0 ||
                                image?.length == null
                            ? Image.asset('images/doctoravatar.png')
                            : PhotoView(
                                imageProvider: NetworkImage(image),
                                minScale: 0.25,
                                maxScale: 0.5,
                              ),
                      ));
                  // show the dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
                },
                child: CircleAvatar(
                  backgroundImage: image.length == 0
                      ? AssetImage('images/doctoravatar.png')
                      : NetworkImage(image),
                  radius: width * 0.1,
                  backgroundColor: teal,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: width * 0.63,
                  child: Column(
                    //mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "$name",
                        style: TextStyle(
                          color: teal,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "$fileNumber",
                        style: TextStyle(
                          color: orange,
                          // fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                ImageIcon(
                                  AssetImage("images/icons/heat.png"),
                                  color: Colors.black,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: width * 0.001),
                                  child: Text(
                                    ' $temperature',
                                    style: style,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                ImageIcon(
                                  AssetImage("images/icons/presure.png"),
                                  color: Colors.black,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: width * 0.01),
                                  child: Text(
                                    ' $bloodPressure',
                                    style: style,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                ImageIcon(
                                  AssetImage("images/icons/suger.png"),
                                  color: Colors.black,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: width * 0.01),
                                  child: Text(
                                    ' $sugarLevel',
                                    style: style,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
