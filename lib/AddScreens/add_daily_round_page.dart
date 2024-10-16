import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../Colors.dart';

class AddDailyRoundPage extends StatefulWidget {
  final dynamic patient;
  final Map<String, dynamic> dailyRound; // Data for editing
  final String documentId; // Document ID for updating
  final bool isEditMode;  // Flag to check if it's edit mode or add mode

  AddDailyRoundPage({Key key,  this.patient, this.dailyRound, this.documentId, this.isEditMode = false}) : super(key: key);

  @override
  _AddDailyRoundPageState createState() => _AddDailyRoundPageState();
}

class _AddDailyRoundPageState extends State<AddDailyRoundPage> {
  String newDate = '';
  List<Map<String, dynamic>> newTasks = [];
  String selectedMedication;
  bool isStopped = false;
  stt.SpeechToText _speech = stt.SpeechToText();
  List<DropdownMenuItem<String>> dropdownItems = [];

  TextEditingController findingsController = TextEditingController();
  TextEditingController assessmentController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController dischargePlanController = TextEditingController();
  TextEditingController doctorNameController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController replyController = TextEditingController();

  Map<String, bool> listeningStates = {
    'findings': false,
    'assessment': false,
    'comment': false,
    'dischargePlan': false,
    'doctorName': false,
    'reason': false,
    'reply': false,
  };

  Map<int, bool> taskListeningStates = {};  // To manage listening state for each task

  @override
  void initState() {
    super.initState();
    loadMedications();

    _speech.statusListener = (val) {
      print('onStatus: $val');
      if (val == 'done' || val == 'notListening') {
        setState(() {
          _resetListeningStates();
        });
      }
    };

    _speech.errorListener = (val) {
      print('onError: $val');
      setState(() {
        _resetListeningStates();
      });
    };

    // إذا كانت الصفحة في وضع التعديل، ملء الحقول بالقيم الحالية
    if (widget.isEditMode && widget.dailyRound != null) {
      newDate = widget.dailyRound['date'];
      newTasks = List<Map<String, dynamic>>.from(widget.dailyRound['tasks'] ?? []);
      selectedMedication = widget.dailyRound['medication'];
      isStopped = widget.dailyRound['is_stopped'];
      findingsController.text = widget.dailyRound['findings'] ?? '';
      assessmentController.text = widget.dailyRound['assessment'] ?? '';
      commentController.text = widget.dailyRound['comment'] ?? '';
      dischargePlanController.text = widget.dailyRound['discharge_plan'] ?? '';
      doctorNameController.text = widget.dailyRound['doctor_name'] ?? '';
      reasonController.text = widget.dailyRound['reason'] ?? '';
      replyController.text = widget.dailyRound['reply'] ?? '';

      // إضافة TextEditingController لكل مهمة موجودة في حالة التعديل
      for (int i = 0; i < newTasks.length; i++) {
        newTasks[i]['controller'] = TextEditingController(text: newTasks[i]['task']);
        taskListeningStates[i] = false; // تعيين حالة المايك كغير مفعلة
      }
    }
  }

  void _resetListeningStates() {
    listeningStates.updateAll((key, value) => false);
    taskListeningStates.updateAll((key, value) => false);
  }

  Future<void> loadMedications() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('medications')
        .where('sick_id', isEqualTo: widget.patient.id)
        .get();
    snapshot.docs.forEach((doc) {
      if (!doc['is_stopped']) {
        dropdownItems.add(DropdownMenuItem(
          child: Text(doc['medication_title']),
          value: doc['medication_title'],
        ));
      }
    });
    setState(() {}); // Update UI
  }

  Future<void> _startListening(TextEditingController controller, String field) async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        if (field.startsWith('task')) {
          int taskIndex = int.parse(field.replaceAll('task', ''));
          taskListeningStates[taskIndex] = true;
        } else {
          listeningStates[field] = true;
        }
      });

      String originalText = controller.text;  // النص الأصلي الموجود في الحقل
      List<String> recognizedWordsList = [];  // قائمة لتخزين الكلمات المعترف بها

      _speech.listen(
        onResult: (result) {
          setState(() {
            // الحصول على الكلمات الجديدة المعترف بها
            String currentRecognizedWords = result.recognizedWords.trim();
            List<String> currentWords = currentRecognizedWords.split(' ');

            // استخراج الكلمات الجديدة التي لم تضاف بعد
            List<String> newWords = currentWords.where((word) => !recognizedWordsList.contains(word)).toList();

            if (newWords.isNotEmpty) {
              // تحديث النص القديم بإضافة الكلمات الجديدة
              controller.text = originalText + (originalText.isEmpty ? "" : " ") + newWords.join(' ');
              originalText = controller.text;  // تحديث النص الأصلي
              recognizedWordsList.addAll(newWords);  // إضافة الكلمات الجديدة للقائمة
            }
          });
        },
        listenFor: Duration(minutes: 1),
      );
    }
  }


  void _stopListening(String field) {
    if (field.startsWith('task')) {
      int taskIndex = int.parse(field.replaceAll('task', ''));
      if (taskListeningStates[taskIndex] == true) {
        _speech.stop();
        setState(() {
          taskListeningStates[taskIndex] = false;
        });
      }
    } else {
      if (listeningStates[field] == true) {
        _speech.stop();
        setState(() {
          listeningStates[field] = false;
        });
      }
    }
  }

  void _toggleListening(TextEditingController controller, String field) {
    if (field.startsWith('task')) {
      int taskIndex = int.parse(field.replaceAll('task', ''));
      if (taskListeningStates[taskIndex] == true) {
        _stopListening(field);
      } else {
        _startListening(controller, field);
      }
    } else {
      if (listeningStates[field] == true) {
        _stopListening(field);
      } else {
        _startListening(controller, field);
      }
    }
  }

  Widget _buildVoiceInputField(String label, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.all(8),
      height: 70, // تثبيت ارتفاع الحقل
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),

      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null, // يتيح التمرير العمودي
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _toggleListening(controller, label.toLowerCase()),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: listeningStates[label.toLowerCase()] == true ? Colors.red : teal,
              child: Icon(
                listeningStates[label.toLowerCase()] == true ? Icons.pause : Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskField(int index, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: newTasks[index]['completed'] ?? false,
            onChanged: (value) {
              setState(() {
                newTasks[index]['completed'] = value;
              });
            },
          ),
          Expanded(
            child: TextField(
              onChanged: (value) {
                newTasks[index]['task'] = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter Task ${index + 1}',
                border: InputBorder.none,
              ),
              controller: controller,
            ),
          ),
          GestureDetector(
            onTap: () => _toggleListening(controller, 'task$index'),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: taskListeningStates[index] == true ? Colors.red : teal,
              child: Icon(
                taskListeningStates[index] == true ? Icons.pause : Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveDailyRound() {
    Map<String, dynamic> dailyRoundData = {
      'date': newDate,
      'patientId': widget.patient.id,
      'tasks': newTasks.isNotEmpty ? newTasks.map((task) {
        return {
          'task': task['task'],
          'completed': task['completed'] ?? false,
        };
      }).toList() : [],
      'medication': selectedMedication ?? '',
      'is_stopped': isStopped,
      'findings': findingsController.text.isNotEmpty ? findingsController.text : '',
      'assessment': assessmentController.text.isNotEmpty ? assessmentController.text : '',
      'comment': commentController.text.isNotEmpty ? commentController.text : '',
      'discharge_plan': dischargePlanController.text.isNotEmpty ? dischargePlanController.text : '',
      'doctor_name': doctorNameController.text.isNotEmpty ? doctorNameController.text : '',
      'reason': reasonController.text.isNotEmpty ? reasonController.text : '',
      'reply': replyController.text.isNotEmpty ? replyController.text : '',
    };

    if (widget.isEditMode && widget.documentId != null) {
      // تعديل الجولة اليومية في حالة التعديل
      FirebaseFirestore.instance
          .collection('daily_rounds')
          .doc(widget.documentId)
          .update(dailyRoundData)
          .then((value) {
        Navigator.pop(context); // إغلاق الصفحة بعد التعديل
      }).catchError((error) {
        print('Failed to update daily round: $error');
      });
    } else {
      // إضافة جولة جديدة في حالة الإضافة
      FirebaseFirestore.instance.collection('daily_rounds').add(dailyRoundData).then((value) {
        Navigator.pop(context); // إغلاق الصفحة بعد الإضافة
      }).catchError((error) {
        print('Failed to add daily round: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Daily Round' : 'Add Daily Round'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Widget for selecting date (newDate)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  onTap: () async {
                    DateTime selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2025),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        newDate = '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
                      });
                    }
                  },
                  readOnly: true,
                  controller: TextEditingController(text: newDate),
                  decoration: InputDecoration(
                    hintText: 'Select Date',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Dropdown for selecting medication
              DropdownButtonFormField<String>(
                value: selectedMedication,
                items: dropdownItems,
                onChanged: (value) {
                  setState(() {
                    selectedMedication = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select Medication',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Task List and Add Task Button
              Column(
                children: newTasks.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> task = entry.value;
                  TextEditingController taskController = task['controller'];
                  return _buildTaskField(index, taskController);
                }).toList(),
              ),
              SizedBox(height: 8),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    int newIndex = newTasks.length;
                    newTasks.add({
                      'task': '',
                      'completed': false,
                      'controller': TextEditingController(), // إضافة TextEditingController جديد
                    });
                    taskListeningStates[newIndex] = false;  // Initialize listening state for new task
                  });
                },
              ),
              Center(
                child: Text(
                  'To add a new task, press the "+" button.',
                  style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              SizedBox(height: 16),

              // Instruction Section Header
              Text(
                'Instruction',
                style: TextStyle(color: teal, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Findings
              _buildVoiceInputField('Findings', findingsController),
              SizedBox(height: 8),

              // Assessment
              _buildVoiceInputField('Assessments', assessmentController),
              SizedBox(height: 8),

              // Comment
              _buildVoiceInputField('Comments', commentController),
              SizedBox(height: 8),

              // Discharge Plan
              _buildVoiceInputField('Discharge Plan', dischargePlanController),
              SizedBox(height: 16),

              // Consultation Section Header
              Text(
                'Consultation',
                style: TextStyle(color: teal, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Doctor Name
              _buildVoiceInputField('Doctor Name', doctorNameController),
              SizedBox(height: 8),

              // Reason
              _buildVoiceInputField('Reason', reasonController),
              SizedBox(height: 8),

              // Reply
              _buildVoiceInputField('Reply', replyController),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: _saveDailyRound,
                child: Text(widget.isEditMode ? 'Update' : 'Save'),
                style: ElevatedButton.styleFrom(
                  primary: teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
