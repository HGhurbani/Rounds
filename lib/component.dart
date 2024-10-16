
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rounds/colors.dart';

Widget defaultTextFormField({
  TextEditingController controller,
  TextInputType typingType,
  Function validate,
  String hintText,
  IconData prefix,
  IconData suffix,
  bool isPassword = false,
  Function onTap,
  bool read = false,
  double TextformSize = 8.0,
}) =>
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: teal, width: 2), // نفس حدود TextFormField
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 60, // تثبيت ارتفاع الحقل
      child: TextFormField(
        controller: controller,
        keyboardType: typingType,
        obscureText: isPassword,
        validator: validate,
        readOnly: read,
        onTap: onTap,
        maxLines: null, // يتيح التمرير العمودي
        // minLines: 1, // بدءًا من سطر واحد
        decoration: InputDecoration(
          prefixIcon: suffix != null ? Icon(suffix, color: teal) : null,
          hintText: hintText,
          hintStyle: TextStyle(
            color: orange,
            fontSize: 16,
          ),
          contentPadding: EdgeInsets.all(TextformSize),
          border: InputBorder.none, // إزالة الحدود الداخلية
        ),
        scrollPhysics: BouncingScrollPhysics(), // تفعيل التمرير العمودي
      ),
    );

Widget headApp()=>Container(
  width: double.infinity,
  height: 80,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.only(bottomRight: Radius.circular(30) , bottomLeft: Radius.circular(30)),
    color: teal,
  ),
);
Widget myButton({
  double width,
  Function onPressed ,
  String text,
})=> Padding(
  padding: const EdgeInsets.all(10.0),
  child: Center(
    child: Container(
      width: width * 0.4,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: orange),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            // fontWeight: FontWeight.bold
          ),
        ),),
    ),
  ),
);

Future<void> _checkPermission() async {
  final storage = await Permission.storage.request();
  if (storage == PermissionStatus.granted) {
  } else if (storage == PermissionStatus.denied) {
    Fluttertoast.showToast(
        msg: "Storage Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
  } else if (storage == PermissionStatus.permanentlyDenied) {
    Fluttertoast.showToast(
        msg: "Storage Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
    await openAppSettings();
  }
  final camera = await Permission.camera.request();
  if (camera == PermissionStatus.granted) {
  } else if (camera == PermissionStatus.denied) {
    Fluttertoast.showToast(
        msg: "Camera Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
  } else if (camera == PermissionStatus.permanentlyDenied) {
    Fluttertoast.showToast(
        msg: "Camera Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
    await openAppSettings();
  }

  final audio = await Permission.microphone.request();
  if (audio == PermissionStatus.granted) {
    print('Permission granted');
  } else if (audio == PermissionStatus.denied) {
    Fluttertoast.showToast(
        msg: "Mic Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
    print('Permission denied. Show a dialog and again ask for the permission');
  } else if (audio == PermissionStatus.permanentlyDenied) {
    Fluttertoast.showToast(
        msg: "Mic Access Denied,",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
    await openAppSettings();
  }
}