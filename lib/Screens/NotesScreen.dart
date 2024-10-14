import 'package:rounds/AddScreens/AddNoteScreen.dart';
import 'package:rounds/Network/SickModel.dart';
import 'package:flutter/material.dart';


class NotesScreen extends StatefulWidget {
  final SickModel sick;
  final int id;

  NotesScreen(this.id,this.sick);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Notes') ,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.topLeft,
                        colors: <Color>[
                          Color(0xff1e3be8),
                          Color(0xff8f00ff)
                        ])
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,

                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(30) , bottomLeft: Radius.circular(30)),
                      gradient: LinearGradient(
                          colors: [
                            Color(0xff1e3be8),
                            Color(0xff8f00ff)
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.topLeft
                      )

                  ),

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
                    padding:
                        const EdgeInsets.only(right: 8, top: 8, left: 5, bottom: 8),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
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
                            Text('${widget.sick.notes.length==0?'No doctor note found':widget.sick.notes[0].noteDoctor}'),
                          ],
                        ),
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
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddNoteScreen(widget.id,widget.sick)));
                                    },
                                    child: Text(
                                      'Add Note',
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
        ),
      ),
                  widget.sick.notes.length==0?Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text('No Notes Found')),
                  ): ListView.builder(
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.sick.notes.length,
                      itemBuilder: (ctx,index){
                        return  Card(
                            margin: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white70, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: Colors.white,
                            elevation: 20,
                            child:Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Text('${ widget.sick.notes[index].noteText}'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            ImageIcon(
                                              AssetImage("images/icons/teamwork.png"),
                                              color: Color(0xFF4d65f8),
                                            ),
                                            Text(' ${ widget.sick.notes[index].noteDoctor}'),
                                          ],
                                        ),


                                      ],
                                    ),
                                  )

                                ],
                              ),
                            )
                        );
                      }
                  )


    ]),
              ],
            )
        )
    );
  }
}
