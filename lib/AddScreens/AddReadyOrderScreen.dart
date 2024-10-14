import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:rounds/Screens/HomeScreen.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:flutter/material.dart';
import 'package:rounds/Network/SuccessModel.dart';
import 'package:rounds/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rounds/component.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:rounds/Screens/ReadyOrderScreen.dart';

class AddReadyOrderScreen extends StatefulWidget {
  String title;
  String description;
  String orderId;

  AddReadyOrderScreen(this.title, this.description, this.orderId);

  @override
  _AddReadyOrderScreen createState() => _AddReadyOrderScreen();
}

class _AddReadyOrderScreen extends State<AddReadyOrderScreen> {
  final textConroler = TextEditingController();
  final titleConroler = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool error = false;
  bool complete = false;

  final String KEY = 'os14042020ah';
  final String ACTION = 'add-order';

  Future<void> showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // حواف مربعة ناعمة
          ),
          title: Text(
            'Success',
            style: TextStyle(color: teal), // لون النص للعنوان
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Order has been uploaded successfully!',
                  style: TextStyle(color: Colors.black), // لون النص للمحتوى
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: teal), // لون النص للزر
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to ReadyOrderScreen after successful upload
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadyOrderScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  uploadOrder(BuildContext context, String text, String title) async {
    try {
      if (title.isEmpty || text.isEmpty) return;

      String doctorId = await DoctorID().readID();
      String shareId = '';

      // Get the share_id from the current user in the 'doctors' collection
      DocumentSnapshot doctorSnapshot =
      await _firestore.collection('doctors').doc(doctorId).get();

      if (doctorSnapshot.exists) {
        shareId = doctorSnapshot.data()['share_id'] ?? '';
      } else {
        print('Doctor document not found');
        return; // Exit the function if doctor document is not found
      }

      DocumentReference orderRef = await _firestore.collection('orders').add({
        'order_title': title,
        'order_text': text,
        'doctor_id': doctorId,
        'share_id': shareId, // Add the share_id to the order document
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Get the generated document ID and update the orderId field
      String orderId = orderRef.id;
      await orderRef.update({'orderId': orderId});

      // Close the dialog
      Navigator.pop(context);

      // Show success dialog
      await showSuccessDialog(context);
    } catch (e) {
      print("Exception Caught : $e");
      // errorMessage(context);
    }
  }

  editOrder(context, text, title) async {
    try {
      await _firestore.collection('orders').doc(widget.orderId).update({
        'order_title': title,
        'order_text': text,
      });

      Navigator.pop(context);
      await showSuccessDialog(context);
    } catch (e) {
      print("Exception Caught : $e");
    }
  }

  successMessage(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false);
      },
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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    titleConroler.text = widget.title;
    textConroler.text = widget.description;

    // تعيين مستمع لتغيرات الحالة
    _speech.statusListener = (status) {
      if (status == 'done' || status == 'notListening') {
        // إعادة الأيقونة واللون عند انتهاء الاستماع
        setState(() {
          _isListeningTitle = false;
          _isListeningDesc = false;
        });
      }
    };
  }

  stt.SpeechToText _speech;
  bool _isListeningTitle = false;
  bool _isListeningDesc = false;

  Future<bool> _listen(TextEditingController controller, bool coloring) async {
    // إذا لم يكن في وضع الاستماع حالياً
    if (!coloring) {
      bool available = await _speech.initialize();
      if (available) {
        // تفعيل وضع الاستماع
        setState(() => coloring = true);

        // تخزين النص الأصلي في بداية الاستماع
        String originalText = controller.text;
        String newText = ""; // متغير لتجميع النصوص الجديدة

        // بدء عملية الاستماع للصوت
        _speech.listen(
          onResult: (val) => setState(() {
            // الحصول على النص المكتشف من الصوت
            String detectedWords = val.recognizedWords.trim();

            // التحقق من أن النص الجديد ليس فارغًا ومختلف عن آخر تحديث
            if (detectedWords.isNotEmpty && newText != detectedWords) {
              newText = detectedWords; // تحديث النص الجديد
              controller.text = originalText + (newText.isEmpty ? "" : " " + newText); // دمج النص الجديد مع الأصلي
            }
          }),
          // listenFor: Duration(seconds: 30), // تحديد مدة الاستماع (مثال: 5 ثواني)
          // pauseFor: Duration(seconds: 30), // مدة التوقف بين الأوامر الصوتية
          partialResults: false,
        );
      }
    } else {
      // إيقاف الاستماع عند إعادة الضغط على الزر
      setState(() => coloring = false);
      _speech.stop();
    }

    return coloring;
  }






  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.orderId == null ? 'Add selected procedure orders' : 'Edit selected procedure orders',
          style: TextStyle(fontSize: 17),
        ),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: width * 0.75,
                  child: defaultTextFormField(
                    controller: titleConroler,
                    hintText: 'Procedure name',
                  ),
                ),
                CircleAvatar(
                  radius: (width - (width * 0.8)) / 4,
                  backgroundColor: _isListeningTitle ? Colors.deepOrangeAccent : teal,
                  child: IconButton(
                    icon: Icon(
                      _isListeningTitle ? Icons.pause : Icons.mic_none_outlined,
                    ),
                    onPressed: () {
                      _listen(titleConroler, _isListeningTitle).then((value) {
                        setState(() {
                          _isListeningTitle = value;
                        });
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: width * 0.75,
                  child: defaultTextFormField(
                      controller: textConroler,
                      hintText: 'Orders',
                      typingType: TextInputType.multiline),
                ),
                CircleAvatar(
                    radius: (width - (width * 0.8)) / 4,
                    backgroundColor: _isListeningDesc ? Colors.deepOrangeAccent : teal,
                    child: IconButton(
                      icon: Icon(
                        _isListeningDesc ? Icons.pause : Icons.mic_none_outlined,
                      ),
                      onPressed: () {
                        _listen(textConroler, _isListeningDesc).then((value) {
                          setState(() {
                            _isListeningDesc = value;
                          });
                        });
                      },
                    ))
              ],
            ),
          ),
          myButton(
              width: width,
              onPressed: () async {
                check().then((intenet) {
                  if (intenet != null && intenet) {
                    if (titleConroler.text.isEmpty || textConroler.text.isEmpty) {
                    } else {
                      setState(() {
                        error = true;
                      });
                      widget.orderId == null
                          ? uploadOrder(context, titleConroler.text, textConroler.text)
                          : editOrder(context, textConroler.text, titleConroler.text);
                    }
                  } else {
                    internetMessage(context);
                  }
                });
              },
              text: error ? 'Uploading' : (widget.orderId == null ? 'Add' : 'Update')),
        ],
      ),
    );
  }
}
