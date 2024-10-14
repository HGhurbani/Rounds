import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rounds/Network/DoctorDataModel.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rounds/Status/DoctorID.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../AddScreens/AddReadyOrderScreen.dart';
import '../colors.dart';

class MyTeamScreen extends StatefulWidget {
  @override
  _MyTeamScreenState createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen>
    with SingleTickerProviderStateMixin {
  List<DoctorData> doctors = [];
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  List<DoctorData> filteredDoctors = [];
  bool loading = false;
  String doctorShareId = '';
  TextEditingController searchController = TextEditingController();
  TabController _tabController;
  bool contactsLoading = true;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getDoctorId();
    fetchDoctors();
    getContacts();
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTime();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void getDoctorId() async {
    try {
      String userId = await DoctorID().readID();
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          doctorShareId = snapshot.data()['share_id'] ?? '';
        });
        fetchDoctors();
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error getting doctor ID: $e');
    }
  }

  Future<void> fetchDoctors() async {
    setState(() {
      loading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && doctorShareId.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('share_id', isEqualTo: doctorShareId)
          .get();

      setState(() {
        doctors = snapshot.docs
            .map((doc) => DoctorData.fromJson(doc.data()))
            .toList();
        filteredDoctors = doctors;
        loading = false;
      });
    } else {
      setState(() {
        doctors = [];
        filteredDoctors = [];
        loading = false;
      });
    }
  }

  bool _contactsLoaded = false; // متغير لتتبع إذا تم تحميل الجهات

  Future<void> getContacts() async {
    print("Attempting to load contacts...");
    setState(() {
      contactsLoading = true;
      progress = 0.0;
    });

    if (await Permission.contacts.request().isGranted) {
      print("Permission granted. Fetching contacts...");
      Iterable<Contact> _contacts = await ContactsService.getContacts();
      setState(() {
        contacts = _contacts.toList();
        filteredContacts = contacts;
        contactsLoading = false;
      });
      print("Contacts loaded: ${contacts.length}");
    } else {
      setState(() {
        contactsLoading = false;
      });
      print("Permission denied.");
      Fluttertoast.showToast(
        msg: "Permission to access contacts denied.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
      );
    }
  }

  void filterSearchResults(String query) {
    if (query == null || query.isEmpty) {
      setState(() {
        filteredContacts = contacts;
        filteredDoctors = doctors;
      });
      return;
    }

    query = query.toLowerCase();

    List<Contact> tempContactList = [];
    contacts.forEach((contact) {
      if (contact.displayName != null &&
          contact.displayName.toLowerCase().contains(query) ||
          contact.phones.any((phone) =>
              phone.value.replaceAll(RegExp(r'[^0-9]'), '').contains(query))) {
        tempContactList.add(contact);
      }
    });

    List<DoctorData> tempDoctorList = [];
    doctors.forEach((doctor) {
      if (doctor.doctor_username != null &&
          doctor.doctor_username.toLowerCase().contains(query)) {
        tempDoctorList.add(doctor);
      }
    });

    setState(() {
      filteredContacts = tempContactList;
      filteredDoctors = tempDoctorList;
    });
  }

  Future<void> deleteDoctor(String doctorId) async {
    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .delete();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Text("Success",
                style:
                TextStyle(color: teal, fontWeight: FontWeight.bold)),
            content: Text("Doctor deleted successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK", style: TextStyle(color: teal)),
              ),
            ],
          );
        },
      );

      fetchDoctors();
    } catch (error) {
      print("Error deleting doctor: $error");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Text("Error",
                style: TextStyle(
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.bold)),
            content: Text("Failed to delete doctor. Please try again later."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK", style: TextStyle(color: teal)),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> editDoctor(DoctorData doctor) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReadyOrderScreen(
          doctor.doctor_username,
          doctor.d_email,
          doctor.doctorId,
        ),
      ),
    );
  }

  Future<void> inviteViaWhatsApp(Contact contact, String doctorShareId) async {
    if (contact.phones.isEmpty) {
      Fluttertoast.showToast(
        msg: "No phone number available for this contact.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
      );
      return;
    }

    final String phoneNumber =
    contact.phones.first.value.replaceAll(RegExp(r'[^0-9]'), '');
    final String appLink =
        'https://play.google.com/store/apps/details?id=com.rounds.eg.rounds'; // Replace with your actual app's Play Store link
    final String whatsappUrl =
        'https://wa.me/$phoneNumber?text=Join our team using this Share ID: $doctorShareId\nDownload app from $appLink';

    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl); // Open WhatsApp with the link
      } else {
        // If WhatsApp is not installed, inform the user
        Fluttertoast.showToast(
          msg: "WhatsApp is not installed on this device.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.deepOrangeAccent,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print("Error launching WhatsApp: $e");
      // Handle the error appropriately
      Fluttertoast.showToast(
        msg: "Failed to launch WhatsApp. Please try again later.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.deepOrangeAccent,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time_team_screen') ?? true;

    if (isFirstTime) {
      _showUsageInstructions();
      await prefs.setBool('first_time_team_screen', false);
    }
  }

  void _showUsageInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usage Instructions', style: TextStyle(color: teal)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('1. Use the search bar to find doctors or contacts.'),
                Text('2. Tap on the edit or delete icons to manage doctors.'),
                Text(
                    '3. Tap on the send icon to invite contacts via WhatsApp.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: teal)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Team'),
        backgroundColor: teal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              getContacts();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          indicator: BoxDecoration(
            color: Colors.deepOrangeAccent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          tabs: [
            Tab(text: "Doctors"),
            Tab(text: "Contacts"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildDoctorListView(),
                buildContactListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDoctorListView() {
    return loading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        DoctorData doctor = filteredDoctors[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 30, // Increased size
              backgroundColor: teal, // Teal background color
              backgroundImage: doctor.avatar != null
                  ? NetworkImage(doctor.avatar)
                  : AssetImage('images/doctoravatar.png'),
            ),
            title: Text(doctor.doctor_username ?? '',
                style: TextStyle(
                    color: teal, fontWeight: FontWeight.bold)),
            subtitle: Text(doctor.d_email ?? '',
                style: TextStyle(color: Colors.deepOrangeAccent)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    editDoctor(doctor);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    deleteDoctor(doctor.doctorId ?? '');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildContactListView() {
    if (contactsLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Loading contacts...', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(teal),
            ),
          ],
        ),
      );
    } else {
      return filteredContacts.isEmpty
          ? Center(child: Text('No Contacts Found'))
          : ListView.builder(
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          Contact contact = filteredContacts[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 30, // Increased size
                backgroundColor: teal, // Teal background color
                child: Icon(Icons.person, size: 30, color: Colors.white), // Increased icon size
              ),
              title: Text(contact.displayName ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                contact.phones.isNotEmpty
                    ? contact.phones.first.value
                    : '',
                style: TextStyle(),
              ),
              trailing: IconButton(
                icon: Icon(Icons.send, color: teal),
                onPressed: () {
                  inviteViaWhatsApp(contact, doctorShareId);
                },
              ),
            ),
          );
        },
      );
    }
  }
}
