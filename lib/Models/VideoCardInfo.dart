import 'dart:io';
import 'package:rounds/Screens/FullScreenImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rounds/AddScreens/AddConsentScreen.dart';
import 'package:rounds/colors.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class VideoCardInfo extends StatelessWidget {
  final String name;
  final String desc;
  final List<String> img;
  final BuildContext context;
  final int index;
  final int indexInList;
  final Function(BuildContext context, int index, int indexList) delete;
  final Function(
      BuildContext context, String title, String description, int index) edit;

  VideoCardInfo(
      {this.name,
      this.img,
      this.desc,
      this.context,
      this.index,
      this.indexInList,
      this.delete,
      this.edit});

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, String title, String desc,
      {String sora}) async {
    if (sora.isNotEmpty && sora != "images/play.png") {
      NetworkImage imageProvider = await NetworkImage(sora);
      final image = await flutterImageProvider(imageProvider);
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (context) {
            return pw.Padding(
              padding: pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Title : $name", style: pw.TextStyle(fontSize: 40)),
                  pw.SizedBox(height: 20),
                  pw.Text("Description : $desc",
                      style: pw.TextStyle(fontSize: 36)),
                  pw.SizedBox(height: 20),
                  pw.Image(image),
                  //    pw.Text(title),
                ],
              ),
            );
          },
        ),
      );
      return pdf.save();
    } else {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (context) {
            return pw.Padding(
              padding: pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Title : $name", style: pw.TextStyle(fontSize: 40)),
                  pw.SizedBox(height: 20),
                  pw.Text("Description : $desc",
                      style: pw.TextStyle(fontSize: 36)),
                  //    pw.Text(title),
                ],
              ),
            );
          },
        ),
      );
      return pdf.save();
    }
  }

  Future<void> share({name, desc, filePath}) async {
    if (filePath != null) {
      http.Response response = await http.get(filePath);
      await WcFlutterShare.share(
          sharePopupTitle: 'share',
          subject: 'Data',
          text: 'Title :  $name\nDescription:  $desc ',
          fileName: 'image.jpg',
          mimeType: 'image/jpg',
          bytesOfFile: response.bodyBytes);
    } else {
      await FlutterShare.share(
          title: 'Data',
          text: 'Title :  $name\nDescription:  $desc ',
          chooserTitle: 'Share with');
    }
  }

  _showToast() {
    Fluttertoast.showToast(
        msg: "Please Wait, Collecting Data ..",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 20.0);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        elevation: 20,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => FullScreenImage(images: img),
                  //     ),
                  //   );
                  // },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: img[0].split('/').last == "play.png"
                        ? AssetImage(img[0])
                        : NetworkImage(img[0]),
                    radius: width * 0.11,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: TextStyle(
                        color: teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      desc,
                      style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 14),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                edit(context, name, desc, index);
                              },
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue,
                              )),
                          GestureDetector(
                              onTap: () {
                                Fluttertoast.showToast(
                                    msg: "Deleting",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.deepOrangeAccent,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                delete(context, index, indexInList);
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              )),
                          GestureDetector(
                              onTap: () {
                                _showToast();
                                if (img.isNotEmpty &&
                                    img != "images/play.png") {
                                  share(
                                    name: name,
                                    desc: desc,
                                    filePath: img[0],
                                  );
                                } else {
                                  share(
                                    name: name,
                                    desc: desc,
                                  );
                                }
                              },
                              child: Icon(
                                Icons.share,
                                color: Colors.black87,
                              )),
                          GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text("Printing"),
                                          content: Container(
                                            width: 400,
                                            height: 500,
                                            child: PdfPreview(
                                              allowSharing: false,
                                              canChangePageFormat: false,
                                              build: (format) => _generatePdf(
                                                  format, name, desc,
                                                  sora: img[0]),
                                            ),
                                          ),
                                        ));
                              },
                              child: Icon(
                                Icons.print,
                                color: teal,
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
