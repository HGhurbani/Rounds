import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSicks {
  int id;
  String doctorId;
  String msg;
  List dailyForm;
  Laboratory laboratory;
  List reports;
  List consebt;
  List medication;
  List vaccination;
  List consent;
  String bloodGroup;
  String weight;
  String surgicalHistory;
  String age;
  String alcohol;
  String allergies;
  String dateOfAdmission;
  String dateOfDischarge;
  String diagnosis;
  String gender;
  String height;
  String medicalHistory;
  String occupation;
  String smoking;
  String status;
  String surgery;
  Timestamp createdAt;
  String name;
  String username;
  String email;
  Timestamp registerDate;
  String temperature;
  String bloodPressure;
  String sugarLevel;
  String avatar;
  String fileNumber;
  LastNote lastNote;

  DoctorSicks(
      {this.msg,
      this.dailyForm,
      this.reports,
      this.consebt,
      this.vaccination,
      this.medication,
      this.consent,
      this.bloodGroup,
      this.weight,
      this.surgicalHistory,
      this.age,
        this.laboratory,
      this.alcohol,
      this.allergies,
      this.dateOfAdmission,
      this.createdAt,
      this.dateOfDischarge,
      this.diagnosis,
      this.gender,
      this.height,
      this.medicalHistory,
      this.occupation,
      this.smoking,
      this.status,
      this.surgery,
      this.id,
      this.name,
      this.username,
      this.email,
      this.registerDate,
      this.temperature,
      this.bloodPressure,
      this.sugarLevel,
      this.avatar,
      this.fileNumber,
      this.lastNote,
      this.doctorId});

  DoctorSicks.fromJson(Map<String, dynamic> json) {
    doctorId = json['doctorId'];
    id = json['id'];
    reports = ['reports'];
    consebt = json['consebt'];
    vaccination = json['vaccination'];
    medication = json['medication'];
    surgery = json['surgery'];
    consent = json['consent'];
    weight = json['weight'];
    bloodGroup = json['blood-group'];
    surgicalHistory = json['surgicalHistory'];
    occupation = json['occupation'];
    age = json['age'];
    alcohol = json['alcohol'];
    allergies = json['allergies'];
    dateOfAdmission = json['date-of-admission'];
    dateOfDischarge = json['date-of-discharge'];
    diagnosis = json['diagnosis'];
    gender = json['gender'];
    height = json['height'];
    createdAt = json['created-at'];
    smoking = json['smoking'];
    status = json['status'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    registerDate = json['register_date'];
    temperature = json['temperature'];
    bloodPressure = json['blood_pressure'];
    sugarLevel = json['sugar_level'];
    avatar = json['avatar'];
    fileNumber = json['file_number'];
    lastNote = json['last_note'] != null
        ? new LastNote.fromJson(json['last_note'])
        : null;
  }
}

class LastNote {
  String noteText;
  String noteDoctor;

  LastNote({this.noteText, this.noteDoctor});

  LastNote.fromJson(Map<String, dynamic> json) {
    noteText = json['note-text'];
    noteDoctor = json['note_doctor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['note-text'] = this.noteText;
    data['note_doctor'] = this.noteDoctor;
    return data;
  }
}

/////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
class Laboratory {
  List<Hematology> hematology;
  List<Chemistry> chemistry;
  List<Microbiology> microbiology;
  List<Histopathology> histopathology;
  List<Others> others;

  Laboratory(
      {this.hematology,
        this.chemistry,
        this.microbiology,
        this.histopathology,
        this.others});

  Laboratory.fromJson(Map<String, dynamic> json) {

    if (json['hematology'] != null) {
      hematology = new List<Hematology>();
      json['hematology'].forEach((v) {
        hematology.add(new Hematology.fromJson(v));
      });
    }
    if (json['chemistry'] != null) {
      chemistry = new List<Chemistry>();
      json['chemistry'].forEach((v) {
        chemistry.add(new Chemistry.fromJson(v));
      });
    }
    if (json['microbiology'] != null) {
      microbiology = new List<Microbiology>();
      json['microbiology'].forEach((v) {
        microbiology.add(new Microbiology.fromJson(v));
      });
    }
    if (json['histopathology'] != null) {
      histopathology = new List<Histopathology>();
      json['histopathology'].forEach((v) {
        histopathology.add(new Histopathology.fromJson(v));
      });
    }
    if (json['others'] != null) {
      others = new List<Others>();
      json['others'].forEach((v) {
        others.add(new Others.fromJson(v));
      });
    }
  }

}

class Hematology {
  String title;
  String date;
  String result;
  String normalValue;
  String report;
  List<String> image;
  String result_image;
  String video;
  String audio;
  String doctor;
  int index;
  Hematology(
      {this.title,
        this.date,
        this.result,
        this.normalValue,
        this.report,
        this.image,
        this.result_image,
        this.video,
        this.audio,
        this.doctor});

  Hematology.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }



}
class Chemistry {
  String title;
  String date;
  String result;
  String normalValue;
  String report;
  List<String> image;
  String result_image;
  String video;
  String audio;
  String doctor;
  int index;
  Chemistry(
      {this.title,
        this.date,
        this.result,
        this.normalValue,
        this.report,
        this.image,
        this.result_image,
        this.video,
        this.audio,
        this.doctor});

  Chemistry.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}
class Microbiology {
  String title;
  String date;
  String result;
  String normalValue;
  String report;
  List<String> image;
  String result_image;
  String video;
  String audio;
  String doctor;
  int index;
  Microbiology(
      {this.title,
        this.date,
        this.result,
        this.normalValue,
        this.report,
        this.image,
        this.result_image,
        this.video,
        this.audio,
        this.doctor});

  Microbiology.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}
class Histopathology {
  String title;
  String date;
  String result;
  String normalValue;
  String report;
  List<String> image;
  String result_image;
  String video;
  String audio;
  String doctor;
  int index;

  Histopathology(
      {this.title,
        this.date,
        this.result,
        this.normalValue,
        this.report,
        this.image,
        this.result_image,
        this.video,
        this.audio,
        this.doctor});

  Histopathology.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}
class Others {
  String title;
  String date;
  String result;
  String normalValue;
  String report;
  List<String> image;
  String result_image;
  String video;
  String audio;
  String doctor;
  int index;

  Others(
      {this.title,
        this.date,
        this.result,
        this.normalValue,
        this.report,
        this.image,
        this.result_image,
        this.video,
        this.audio,
        this.doctor});

  Others.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class Consebt {
  String title;
  String description;
  String image;
  String video;
  String audio;
  int patientId;
  int index;

  Consebt(
      {this.title,
        this.description,
        this.image,
        this.video,
        this.audio,
        this.patientId});

  Consebt.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    image = json["image"] /*== null? [] : List<String>.from(json["image"].map((x) => x))*/;
    video = json['video'];
    audio = json['audio'];
    patientId = json['patientId'];
    index = json['index'];

  }



}



class Medication {
  String medicationTitle;
  String medicationText;
  int patientId;
  String medicationDoctor;
  int index;
  Medication({this.medicationTitle, this.medicationText, this.medicationDoctor,this.patientId});
  Medication.fromJson(Map<String, dynamic> json) {
    medicationTitle = json['medication-title'];
    medicationText = json['medication-text'];
    medicationDoctor = json['medication-doctor'];
    patientId = json['sick_id'];
    index = json['index'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    //data['index'] = this.index;
    data['medication-title'] = this.medicationTitle;
    data['medication-text'] = this.medicationText;
    //data['medication-doctor'] = this.medicationDoctor;
    return data;
  }
}