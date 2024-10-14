import 'package:rounds/AddScreens/AddRayScreen.dart';
import 'package:rounds/Models/RayCardInfo.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:flutter/material.dart';
class RayScreen extends StatefulWidget {

 final SickModel sick;
 final String noteDoctor;
 final int id;

  RayScreen(this.sick, this.noteDoctor,this.id);

  @override
  _RayScreenState createState() => _RayScreenState();
}

class _RayScreenState extends State<RayScreen> {



  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.topLeft,
                        colors: <Color>[Color(0xff1e3be8), Color(0xff8f00ff)])),
              ),
              title: Text('Rays'),
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                      gradient: LinearGradient(
                          colors: [Color(0xff1e3be8), Color(0xff8f00ff)],
                          begin: Alignment.topRight,
                          end: Alignment.topLeft)),
                ),
                ListView(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
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
                            padding: const EdgeInsets.only(
                                right: 8, top: 8, left: 5, bottom: 8),
                            child: SizedBox(
                              height: 100,
                              child: SizedBox(
                                height: 100,
                                child: CircleAvatar(
                                  backgroundImage: (widget.sick?.avatar == null || widget.sick?.avatar == false)
                                      ? AssetImage('images/doctoravatar.png')
                                      : NetworkImage(widget.sick.avatar),
                                  radius: 50,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8),
                                  child: Text(
                                    widget.sick.name,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.sick.surgery,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage("images/icons/teamwork.png"),
                                      color: Color(0xFF4d65f8),
                                    ),
                                    Text(' ${widget.noteDoctor}'),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color:  Color(0xff19d7e7) ),
                                              child: TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => AddRayScreen(widget.id)));
                                                  },
                                                  child: Text(
                                                    'Upload Ray',
                                                    style: TextStyle(
                                                      color: const Color(0xffffffff),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                     scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: widget.sick.rays.length,
                      itemBuilder: (context, index){
                        return  RayCardInfo(widget.sick.rays[index].rayName.length==0?'Ray Name':widget.sick.rays[index].rayName,widget.sick.rays[index].rayImg,widget.sick.rays[index].rayDescription);
                      }
                  ),

                ]),
              ],
            )));
  }
}
