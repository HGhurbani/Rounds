import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditVitalSignsScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  EditVitalSignsScreen({this.initialData});

  @override
  _EditVitalSignsScreenState createState() => _EditVitalSignsScreenState();
}

class _EditVitalSignsScreenState extends State<EditVitalSignsScreen> {
  TextEditingController _heartRateController;
  TextEditingController _respiratoryRateController;
  TextEditingController _bloodSugarController;
  TextEditingController _bloodPressureController;
  TextEditingController _temperatureController;
  TextEditingController _othersController;
  TextEditingController _dateController;
  String _videoUrl;
  String _audioUrl; // Added for audio URL
  VideoPlayerController _videoPlayerController;
  ChewieController _videoChewieController;
  AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _heartRateController = TextEditingController(text: widget.initialData['heart_rate']);
    _respiratoryRateController = TextEditingController(text: widget.initialData['respiratary_rate']);
    _bloodSugarController = TextEditingController(text: widget.initialData['blood_suger']);
    _bloodPressureController = TextEditingController(text: widget.initialData['blood_pressure']);
    _temperatureController = TextEditingController(text: widget.initialData['temperature']);
    _othersController = TextEditingController(text: widget.initialData['others']);
    _dateController = TextEditingController(text: widget.initialData['date']);
    _videoUrl = widget.initialData['video'];
    _audioUrl = widget.initialData['audio'];

    // Initialize video player
    _videoPlayerController = VideoPlayerController.network(_videoUrl);
    _videoChewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      // Other configurations as needed
    );

    // Initialize audio player
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(_audioUrl);
  }

  @override
  void dispose() {
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _bloodSugarController.dispose();
    _bloodPressureController.dispose();
    _temperatureController.dispose();
    _othersController.dispose();
    _dateController.dispose();
    _videoPlayerController.dispose();
    _videoChewieController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Vital Signs'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('Heart Rate', Icons.favorite_border, _heartRateController),
            SizedBox(height: 16.0),

            _buildTextField('Respiratory Rate', Icons.air, _respiratoryRateController),
            SizedBox(height: 16.0),

            _buildTextField('Blood Sugar', Icons.favorite, _bloodSugarController),
            SizedBox(height: 16.0),

            _buildTextField('Blood Pressure', Icons.favorite_outline, _bloodPressureController),
            SizedBox(height: 16.0),

            _buildTextField('Temperature', Icons.thermostat_outlined, _temperatureController),
            SizedBox(height: 16.0),

            _buildTextField('Others', Icons.error_outline, _othersController),
            SizedBox(height: 16.0),

            _buildTextField('Date', Icons.calendar_today, _dateController),
            SizedBox(height: 16.0),

            // GridView for Images
            GridView.builder(
              shrinkWrap: true,
              itemCount: widget.initialData['images'].length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle image editing or deletion
                      },
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: teal, width: 1.5),
                          image: DecorationImage(
                            image: NetworkImage(widget.initialData['images'][index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.delete_forever_outlined,color: Colors.red,),
                        onPressed: () {
                          // Handle image deletion
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            // Video Player
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Edit Video', style: TextStyle(color: teal, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  if (_videoUrl != null)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: VideoPlayerWidget(url: _videoUrl),
                    ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      // Handle video replacement
                    },
                    style: ElevatedButton.styleFrom(
                      primary: teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('Replace Video'),
                  ),
                ],
              ),
            ),

            // Audio Player
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Edit Audio', style: TextStyle(color: teal, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      _audioPlayer.play(_audioUrl); // Play audio
                    },
                    icon: Icon(Icons.play_arrow), // Play icon
                    label: Text('Play Audio'),
                    style: ElevatedButton.styleFrom(
                      primary: teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      // Handle audio replacement
                    },
                    style: ElevatedButton.styleFrom(
                      primary: teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text('Replace Audio'),
                  ),
                ],

              ),
            ),

            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10.0),
    ),
    child: Row(
    children: [
    Icon(icon, color: teal),
    SizedBox(width: 8.0),
    Expanded(
    child: TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: InputBorder.none,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: teal, width: 1.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: teal, width: 1.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    ),
    ),
    ],
    ),
    );
  }

  void _saveChanges() async {
    // Implement your save logic here
    // Retrieve data from controllers and update the database or perform necessary actions
    Map<String, dynamic> newData = {
      'heart_rate': _heartRateController.text,
      'respiratory_rate': _respiratoryRateController.text,
      'blood_suger': _bloodSugarController.text,
      'blood_pressure': _bloodPressureController.text,
      'temperature': _temperatureController.text,
      'others': _othersController.text,
      'date': _dateController.text,
      'video': _videoUrl,
      'audio': _audioUrl,
    };

    // Update database with newData
    try {
      await FirebaseFirestore.instance.collection('vital_sign').doc(widget.initialData['documentId']).update(newData);
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Changes saved successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error updating data: $e');
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while saving changes.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

class VideoPlayerWidget extends StatelessWidget {
  final String url;

  const VideoPlayerWidget({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: ChewieController(
        videoPlayerController: VideoPlayerController.network(url),
        autoPlay: false,
        looping: false,
        // Other configurations as needed
      ),
    );
  }
}


