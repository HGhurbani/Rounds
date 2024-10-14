import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:rounds/Network/DoctorDataModel.dart';
import 'package:rounds/Screens/ProfileScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';

import 'package:rounds/Network/SuccessModel.dart';

import '../Network/DoctorSicksModel.dart';

class AddRayScreen extends StatefulWidget {
  final int id;

  AddRayScreen(this.id);

  @override
  _AddRayScreenState createState() => _AddRayScreenState();
}

class _AddRayScreenState extends State<AddRayScreen> {
  DoctorData doctor;
  List<Asset> images = <Asset>[];
  List<File> test = <File>[];
  String _error = 'No Error Dectected';
  final nameConroler = TextEditingController();
  final descConroler = TextEditingController();
  final resultController = TextEditingController();
  String _name = '';
  String _desc = '';
  String _result = '';
  bool error = false;
  bool complete = false;
  List<File> ListImage = [];
  File _image;
  final String KEY = 'os14042020ah';
  final String ACTION = 'add-ray-to-sick';
  ImageSource source;
  getDoctorData() async {
    Response response = await Dio().get(
        "https://medicall-rounds.com/api/?key=os14042020ah&action=get-doctor-data&doctor-id=${await DoctorID().readID()}");

    setState(() {
      doctor = DoctorData.fromJson(response.data);
    });
  }

  /*Future<File> getImageFileFromAssets(Asset asset) async {
    final byteData = await asset.getByteData();
    final tempFile = File("${(await getTemporaryDirectory()).path}/${asset.name}");
    final file = await tempFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),);
    return file;
  }
  Future getFile(List<Asset> img,List<File>imgfile) async {
    for(int i = 0; i<img.length; i++){
      print("images$i  "+img[i].name);
      await getImageFileFromAssets(img[i]).then((value) => (){
        setState(() {
          print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa ${value.path}");
          imgfile.add(value);
        });
        });
    }
   // print(test.length);
    return test;
  }*/
  uploadRay(context, name, des, result) async {
    String fileName = _image.path.split('/').last;
    //
    // Map<String, dynamic> params = Map();
    // params['images'] = null;
    // Map<String, dynamic> headers = {
    //   HttpHeaders.contentTypeHeader: 'multipart/form-data',
    // };
    // List<MultipartFile> multipart = List<MultipartFile>();
//listImage is your list assets.
    // if (multipart.isNotEmpty){
    //   params['images'] = multipart;
    // }
    //
    // FormData formData = new FormData.fromMap(params);
    try {
      FormData formData = FormData.fromMap({
        "action": ACTION,
        "key": KEY,
        "ray-img":
            await MultipartFile.fromFile(_image.path, filename: fileName),
        // "ray-img":[for(var x in ListImage){
        //    await MultipartFile.fromFile(x.path, filename: x.path.split('/').last)
        //  }].toList(),
        "ray-description": des,
        "ray-name": name,
        "ray-result": result,
        "sick-id": widget.id,
        "ray-doctor-id": DoctorID().readID(),
      });

      Response response =
          await Dio().post("https://medicall-rounds.com/api", data: formData);
      //var responseServer = jsonDecode(response.data);
      SuccessModel successModel = SuccessModel.fromJson(response.data);
      if (successModel.st == 'success') {
        successMessage(context);
        setState(() {
          error = false;
        });
      } else {
        setState(() {
          error = false;
        });
        errorMessage(context);
      }
    } catch (e) {
      print("Exception Caught : $e");
    }
  }

  /* Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Pick The Source",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;
    //
    setState(() {
      images = resultList;
      _error = error;
    });
  }*/
  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Choose option",
              style: TextStyle(color: Colors.blue),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      setState(() {
                        source = ImageSource.gallery;
                      });
                      Navigator.pop(context);
                      //   getImage(ListImage,source);
                      getImage(source);
                    },
                    title: Text("Gallery"),
                    leading: Icon(
                      Icons.account_box,
                      color: Colors.blue,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.blue,
                  ),
                  ListTile(
                    onTap: () {
                      setState(() {
                        source = ImageSource.camera;
                      });
                      Navigator.pop(context);
                      //   getImage(ListImage,source);
                      getImage(source);
                    },
                    title: Text("Camera"),
                    leading: Icon(
                      Icons.camera,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Future getImage(List<File>x,ImageSource source) async {
  //   var image = await ImagePicker.pickImage(source:source);
  //   setState(() {
  //     _image = image;
  //     x.add(_image);
  //     if (_name.length != 0 && _desc.length != 0 && _image != null)
  //       complete = true;
  //   });
  // }
  Future getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = image;
      //x.add(_image);
      if (_name.length != 0 &&
          _desc.length != 0 &&
          _result.length != 0 &&
          _image != null) complete = true;
    });
  }

  internetMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Connection Error"),
      content: Text("please check your internet connection"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  errorMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("ERROR"),
      content: Text("something went wrong"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  DoctorSicks doc;
  successMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      // onPressed: () {
      //   Navigator.pushReplacement(context,
      //       MaterialPageRoute(builder: (_) => ProfileScreen(id:widget.id,sickData:doc,)));
      // },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Success"),
      content: Text("Uploaded"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDoctorData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Container(
              height: 150,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30)),
                  color: Color(0xff395ef2)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 8, top: 8, left: 5, bottom: 8),
                    child: CircleAvatar(
                      backgroundImage: doctor?.avatar == null
                          ? AssetImage('images/doctoravatar.png')
                          : NetworkImage(doctor.avatar),
                      radius: 30,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${doctor?.name == null ? 'loading data...' : doctor.name}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
//                        Text(
//                          'Modile Developer',
//                          style: TextStyle(
//                            fontSize: 12,
//                            color: Colors.white,
//                          ),
//                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: nameConroler,
                      onChanged: (val) {
                        _name = val;
                        if (_desc.length != 0 &&
                            _name.length != 0 &&
                            _result.length != 0 &&
                            _image != null) {
                          setState(() {
                            complete = true;
                          });
                        } else {
                          setState(() {
                            complete = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: TextStyle(
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: descConroler,
                      onChanged: (val) {
                        _desc = val;
                        if (_desc.length != 0 &&
                            _name.length != 0 &&
                            _result.length != 0 &&
                            _image != null) {
                          setState(() {
                            complete = true;
                          });
                        } else {
                          setState(() {
                            complete = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Description',
                        hintStyle: TextStyle(
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            bottom: 20,
                            left: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                  onTap: () {
                                    _showChoiceDialog(context);
                                    //getImage();
                                    //getImage(ListImage);
                                  },
                                  child: _image == null
                                      ? Row(
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 30,
                                            ),
                                            Text('select image')
                                          ],
                                        )
                                      : Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          child: Image.file(_image),
                                        )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: resultController,
                      onChanged: (val) {
                        _result = val;
                        if (_desc.length != 0 &&
                            _name.length != 0 &&
                            _result.length != 0 &&
                            _image != null) {
                          setState(() {
                            complete = true;
                          });
                        } else {
                          setState(() {
                            complete = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Result',
                        hintStyle: TextStyle(
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(20,),
                //   child:ListImage.length==0?Container():
                //   Container(
                //     decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(25),
                //         boxShadow: [
                //         BoxShadow(
                //           color: Colors.grey.withOpacity(0.5),
                //           spreadRadius: 5,
                //           blurRadius: 7,
                //           offset: Offset(0, 3), // changes position of shadow
                //         ),
                //       ],
                //     ),
                //     height: 200,
                //     child: Padding(
                //       padding: const EdgeInsets.all(10),
                //       child: GridView.count(
                //         crossAxisCount: 1,
                //         childAspectRatio:1.5,
                //         scrollDirection:Axis.horizontal,
                //         children: List.generate(ListImage.length, (index) {
                //           return Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Image.file(ListImage[index],fit: BoxFit.fill,),
                //           );
                //         }),
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color:
                                complete ? Color(0xff19d7e7) : Colors.blueGrey),
                        child: Column(
                          children: [
                            // ElevatedButton(onPressed: (){
                            //   getImage();
                            // }, child: Text("sss")),
                            TextButton(
                                onPressed: () async {
                                  // print("el path = ${_image.path}");
                                  check().then((intenet) async {
                                    if (intenet != null && intenet) {
                                      // Internet Present Case
                                      if (nameConroler.text.isEmpty ||
                                              descConroler.text.isEmpty ||
                                              resultController.text.isEmpty
                                          //     || ListImage.length == 0
                                          ) {
                                      } else {
                                        setState(() {
                                          error = true;
                                        });
                                        //print(ListImage.length);
                                        // print(.length);
                                        uploadRay(
                                            context, _name, _desc, _result);
                                      }
                                    } else {
                                      internetMessage(context);
                                    }
                                  });
                                },
                                child: Text(
                                  error ? 'Uploading' : 'Add Ray',
                                  style: TextStyle(
                                    color: const Color(0xffffffff),
                                  ),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
