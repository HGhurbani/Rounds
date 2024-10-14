import 'package:flutter/material.dart';

class horizontalCardsTeams extends StatelessWidget {
  final String name;
  final String surgey;
  final String img;



  horizontalCardsTeams(this.img,this.name, this.surgey);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8,top: 8 , left: 5,bottom: 8),
                    child: SizedBox(
                      height: 100,
                      child: CircleAvatar(
                        backgroundImage: img.length == 0
                            ? AssetImage('images/doctoravatar.png')
                            : NetworkImage(img),
                        radius: 50,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(name, style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(surgey, style: TextStyle(
                      color: Color(0xffafafaf),
                      fontSize: 12,
                    ),),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
