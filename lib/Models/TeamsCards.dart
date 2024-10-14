import 'package:flutter/material.dart';
import 'package:rounds/colors.dart';

class TeamsCards extends StatelessWidget {
  final String name;
  final String image;
  final String email;
  final Function(String) onDelete;
  final Function(String, String, String) onEdit;

  TeamsCards({
    this.name,
    this.image,
    this.email,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .9,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 8, top: 8, left: 5, bottom: 8),
                      child: SizedBox(
                        height: 100,
                        child: CircleAvatar(
                          backgroundColor: deepBlue,
                          backgroundImage: image.length != 0
                              ? AssetImage('images/doctoravatar.png')
                              : NetworkImage(image),
                          radius: 50,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () {
                            // Call the edit function with necessary data
                            onEdit(name, image, email);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            // Call the delete function with appropriate identifier
                            onDelete(name); // Assuming name is the doctor's ID
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
