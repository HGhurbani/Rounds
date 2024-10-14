import 'package:flutter/material.dart';
import 'package:rounds/AddScreens/AddDailyRoundSectionsScreen.dart';
import 'package:rounds/Network/DoctorSicksModel.dart';
import '../colors.dart';

class NewLaboratoryScreen extends StatelessWidget {
  final String patientId;
  final DoctorSicks patient;

  const NewLaboratoryScreen({Key key, this.patientId, this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _NewLaboratoryContent(patientId: patientId);
  }
}

class _NewLaboratoryContent extends StatefulWidget {
  final String patientId;

  const _NewLaboratoryContent({Key key, this.patientId}) : super(key: key);

  @override
  __NewLaboratoryContentState createState() => __NewLaboratoryContentState();
}

class __NewLaboratoryContentState extends State<_NewLaboratoryContent>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laboratory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Hematology'),
            Tab(text: 'Chemistry'),
            Tab(text: 'Microbiology'),
            Tab(text: 'Histopathology'),
            Tab(text: 'Others')
          ],
          indicator: BoxDecoration(
            color: Colors.deepOrangeAccent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          isScrollable: true,
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              Center(child: Text('Content for Category 1')),
              Center(child: Text('Content for Category 2')),
              Center(child: Text('Content for Category 3')),
              Center(child: Text('Content for Category 4')),
              Center(child: Text('Content for Category 5')),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                // Implement onPressed logic here
                final int selectedTab = _tabController.index;
                String category;
                switch (selectedTab) {
                  case 0:
                    category = "Hematology";
                    break;
                  case 1:
                    category = "Chemistry";
                    break;
                  case 2:
                    category = "Microbiology";
                    break;
                  case 3:
                    category = "Histopathology";
                    break;
                  case 4:
                    category = "Laboratory Others";
                    break;
                }
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => AddDailyRoundSectionsScreen(
                //       category,
                //       0,
                //       "",
                //       "",
                //       "",
                //       "",
                //       0,
                //       "",
                //       "",
                //       widget.patientId,
                //     ),
                //   ),
                // );
              },
              backgroundColor: teal,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
