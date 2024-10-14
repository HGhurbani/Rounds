import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../colors.dart';
import 'package:rounds/Network/DoctorDataModel.dart';
import 'package:rounds/Status/AuthStatus.dart'; // استيراد AuthStatus.dart الذي يحتوي على معرف الدخول
import 'package:flutter/services.dart';

class Header extends StatelessWidget {
  const Header({
    Key key,
    @required this.userData,
  }) : super(key: key);

  final DoctorData userData;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Check if a user is logged in
    bool isLoggedIn = AuthStatus()
        .isLoggedIn(); // يفترض أن يكون AuthStatus().isLoggedIn() يعيد true إذا كان المستخدم قد سجل دخوله

    // Check if the user has share_data_id
    bool hasShareDataId = userData?.share_data_id != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              if (isLoggedIn && userData != null && userData.email != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ), // حواف مربعة ناعمة
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${userData.email}'),
                              if (hasShareDataId)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '-${userData.share_id}',
                                              style: TextStyle(color: Colors.teal),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.copy, color: Colors.teal),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: userData.share_id));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Copied Successfully'),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: 10),
                          userData.avatar == null || userData.avatar.isEmpty
                              ? Image.asset(
                            'images/doctoravatar.png', // استخدام الصورة الافتراضية هنا
                          )
                              : Image.network(
                            userData.avatar,
                            fit: BoxFit.contain, // ضبط الصورة لتناسب الحاوية
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
            child: CircleAvatar(
              backgroundImage: isLoggedIn &&
                  userData != null &&
                  userData.avatar != null &&
                  userData.avatar.isNotEmpty
                  ? NetworkImage(userData.avatar)
                  : AssetImage(
                  'images/doctoravatar.png'), // Use default image here
              radius: width * 0.1,
              backgroundColor: teal,
            ),
          ),
        ),
        if (isLoggedIn && userData != null && userData.email != null)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${userData.email}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              if (userData.username != null)
                Text(
                  '${userData.username}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
            ],
          )
        else
          CircularProgressIndicator(color: Colors.white),
      ],
    );
  }
}
