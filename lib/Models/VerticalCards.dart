import 'package:flutter/material.dart';

class Cards extends StatelessWidget {
  final String name;
  final String post;
  final String doc;
  final String temperature;
  final String bloodPressure;
  final String sugarLevel;
  final String image;

  Cards(this.image,this.name, this.post , this.doc,this.temperature, this.bloodPressure , this.sugarLevel);

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
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8,top: 8 , left: 5,bottom: 8),
                      child:  SizedBox(
                        height: 100,
                        child: CircleAvatar(
                          backgroundImage: image.length == 0
                              ? AssetImage('images/doctoravatar.png')
                              : NetworkImage(image),
                          radius: 50,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       // mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(name, style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),),
                          ),

                          SizedBox(
                            height: 5,
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                          //   decoration: BoxDecoration(
                          //       border: Border.all(color: Color(0xfff7f7fa))
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: <Widget>[
                          //       Text('Last Notes',style: TextStyle(color: Color(0xff19d7e7)),),
                          //       Padding(
                          //         padding: const EdgeInsets.symmetric(vertical: 8),
                          //         child: Text(post,overflow: TextOverflow.ellipsis),
                          //       ),
                          //       Row(children: <Widget>[
                          //         ImageIcon(
                          //           AssetImage("images/icons/teamwork.png"),
                          //           color: Color(0xFF4d65f8),
                          //         ),
                          //         Flexible(child: Text(doc,overflow: TextOverflow.ellipsis,)),
                          //       ],
                          //       ),
                          //     ],
                          //   ),
                          // )

                        ],
                      ),
                    ),

                  ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(children: <Widget>[
                    ImageIcon(
                      AssetImage("images/icons/heat.png"),
                      color: Color(0xFF1ad7e8),
                    ),
                    Text(' $temperature'),
                  ],),
                  Row(
                    children: <Widget>[
                      ImageIcon(
                        AssetImage("images/icons/presure.png"),
                        color: Color(0xFF1ad7e8),
                      ),
                      Text(' $bloodPressure'),
                    ],
                  ),
                  Row(children: <Widget>[
                    ImageIcon(
                      AssetImage("images/icons/suger.png"),
                      color: Color(0xFF1ad7e8),
                    ),
                    Text(' $sugarLevel'),
                  ],)
                ],
              ),
            ),
          ],
        )
    );
  }
}
