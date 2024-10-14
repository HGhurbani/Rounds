import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounds/colors.dart';

class CardInfo extends StatelessWidget {
  final String name;
  final String img;

  CardInfo(this.name, this.img);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: width * 0.45,
        height: height * 0.18,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[300], width: 1),
            borderRadius: BorderRadius.circular(25.0),
          ),
          elevation: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: width * 0.12,
                height: width * 0.12, // Adjust as needed
                child: Image.asset(
                  img,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
