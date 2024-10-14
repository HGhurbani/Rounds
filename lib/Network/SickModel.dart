
class SickModel {
  String st;
  String msg;
  int id;
  String name;
  String username;
  String email;
  String registerDate;
  String surgicalHistory;
  String age;
  String surgery;
  String medicines;
  String diagnosis;
  String generalInformation;
  String medicalHistory;
  String gender;
  String height;
  String weight;
  String temperature;
  String bloodPressure;
  String sugarLevel;
  String fileNumber;
  String dateOfAdmission;
  String dateOfDischarge;
  String smoking;
  String alcohol;
  String occupation;
  String bloodGroup;
  String avatar;
  String allergies;
  List<Notes> notes;
  List<Rays> rays;
  List<Orders> orders;
  List<Reports> reports;
  List<Medication> medication;
  List<Vaccination> vaccination;
  List<Consebt> consebt;
  Laboratory laboratory;
  NonRadiology nonRadiology;
  Radiology radiology;
  List<VitalSigns> vitalSigns;
  List<DailyForm> dailyForm;
  SickModel(
      {this.st,
        this.msg,
      this.id,
        this.name,
        this.username,
        this.email,
        this.registerDate,
        this.surgicalHistory,
        this.age,
        this.surgery,
        this.medicines,
        this.diagnosis,
        this.generalInformation,
        this.medicalHistory,
        this.gender,
        this.height,
        this.weight,
        this.temperature,
        this.bloodPressure,
        this.sugarLevel,
        this.fileNumber,
        this.dateOfAdmission,
        this.dateOfDischarge,
        this.smoking,
        this.alcohol,
        this.occupation,
        this.bloodGroup,
        this.allergies,
        this.avatar,
        this.notes,
        this.rays,
        this.orders,
        this.reports,
        this.medication,
        this.vaccination,
        this.consebt,
        this.laboratory,
        this.nonRadiology,
        this.radiology,
        this.vitalSigns ,
        this.dailyForm,
      });

  SickModel.fromJson(Map<String, dynamic> json) {
    st = json['st']??"";
    msg = json['msg'];
    id = json['id'] ;
    name = json['name']??"";
    username = json['username']??"";
    email = json['email']??"";
    registerDate = json['register_date']??"";
    surgicalHistory = json['surgical-history']??"";
    age = json['age']??"";
    surgery = json['surgery']??"";
    medicines = json['medicines']??"";
    diagnosis = json['diagnosis']??"";
    generalInformation = json['general-information']??"";
    medicalHistory = json['medical-history']??"";
    gender = json['gender']??"";
    height = json['height']??"";
    weight = json['weight']??"";
    temperature = json['temperature']??"";
    bloodPressure = json['blood_pressure']??"";
    sugarLevel = json['sugar_level']??"";
    fileNumber = json['file-number']??"";
    dateOfAdmission = json['date-of-admission']??"";
    dateOfDischarge = json['date-of-discharge']??"";
    smoking = json['smoking']??"";
    alcohol = json['alcohol']??"";
    occupation = json['occupation']??"";
    allergies = json['allergies']??"";
    bloodGroup = json['blood-group']??"";
    avatar = json['avatar']??"";
    if (json['notes'] != null) {
      notes = new List<Notes>();
      json['notes'].forEach((v) {
        notes.add(new Notes.fromJson(v));
      });
    }
    if (json['rays'] != null) {
      rays = new List<Rays>();
      json['rays'].forEach((v) {
        rays.add(new Rays.fromJson(v));
      });
    }
    if (json['orders'] != null) {
      orders = new List<Orders>();
      json['orders'].forEach((v) {
        orders.add(new Orders.fromJson(v));
      });
    }
    if (json['reports'] != null) {
      reports = new List<Reports>();
      json['reports'].forEach((v) {
        reports.add(new Reports.fromJson(v));
      });
    }
    if (json['medication'] != null) {
      medication = new List<Medication>();
      json['medication'].forEach((v) {
        medication.add(new Medication.fromJson(v));
      });
    }
    if (json['vaccination'] != null) {
      vaccination = new List<Vaccination>();
      json['vaccination'].forEach((v) {
        vaccination.add(new Vaccination.fromJson(v));
      });
    }
    if (json['consebt'] != null) {
      consebt = new List<Consebt>();
      json['consebt'].forEach((v) {
        consebt.add(new Consebt.fromJson(v));
      });
    }
    laboratory = json['laboratory'] != null
        ? new Laboratory.fromJson(json['laboratory'])
        : null;
    nonRadiology = json['non-radiology'] != null
        ? new NonRadiology.fromJson(json['non-radiology'])
        : null;
    radiology = json['radiology'] != null
        ? new Radiology.fromJson(json['radiology'])
        : null;
    if (json['vital-signs'] != null) {
      vitalSigns = new List<VitalSigns>();
      json['vital-signs'].forEach((v) {
        vitalSigns.add(new VitalSigns.fromJson(v));
      });
    }
    if (json['daily-form'] != null) {
      dailyForm = new List<DailyForm>();
      json['daily-form'].forEach((v) {
        dailyForm.add(new DailyForm.fromJson(v));
      });
    }
  }
  
}
//////////////////////////////////////////////
class DailyForm {
  int index;
  String finding;
  String comment;
  String assessment;
  String date;
  String discharge;
  List<Items> items;
  Consultation consultation;
  String doctor;
  DailyForm(
      {this.index,
        this.finding,
        this.comment,
        this.items,
        this.consultation,
        this.doctor});
  DailyForm.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    finding = json['finding'];
    assessment = json['assessment'];
    comment = json['comment'];
    date = json['date'];
    discharge = json['discharge'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
    consultation = json['consultation'] != null
        ? new Consultation.fromJson(json['consultation'])
        : null;
    doctor = json['doctor'];
  }
}
class Items {
  String text;
  String date;
  String complete;
  Items({this.text, this.date, this.complete});
  Items.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    date = json['date'];
    complete = json['complete'];
  }
}
class Consultation {
  String to;
  String why;
  String replay;
  Consultation({this.to, this.why, this.replay});
  Consultation.fromJson(Map<String, dynamic> json) {
    to = json['to'];
    why = json['why'];
    replay = json['replay'];
  }
}
class Notes {
  String noteText;
  String noteDoctor;
  int index;
  Notes({this.noteText, this.noteDoctor});
  Notes.fromJson(Map<String, dynamic> json) {
    noteText = json['note-text'];
    noteDoctor = json['note-doctor'];
    index = json['index'];
  }
 }
/////////////////////////////////////////////
class Rays {
  String rayName;
  String rayDescription;
  String rayImg;
  String rayDoctor;
  String rayResult;
  int index;
  Rays({this.rayName, this.rayDescription, this.rayImg, this.rayDoctor, this.rayResult});

  Rays.fromJson(Map<String, dynamic> json) {
    rayName = json['ray-name'];
    rayDescription = json['ray-description'];
    rayImg = json['ray-img'];
    rayDoctor = json['ray-doctor'];
    rayResult = json['ray-result'];
    index = json['index'];

  }


}

class Orders {
  String orderTitle;
  String orderText;
  int index;
  Orders({this.orderTitle, this.orderText});

  Orders.fromJson(Map<String, dynamic> json) {
    orderTitle = json['order_title'];
    orderText = json['order_text'];
    index = json['index'];

  }


}

class Reports {
  String reportTitle;
  String reportText;
  String reportDoctor;
  String reportFile;
  String reportPdf;
  int index;
  Reports({this.reportTitle, this.reportText, this.reportDoctor});

  Reports.fromJson(Map<String, dynamic> json) {
    reportTitle = json['report-title'];
    reportText = json['report-text'];
    reportDoctor = json['report-doctor'];
    reportFile = json['report-file'];
    reportPdf = json['pdf-file'];
    index = json['index'];

  }



}

class Medication {
  String medicationTitle;
  String medicationText;
  String medicationDoctor;
  int index;
  Medication({this.medicationTitle, this.medicationText, this.medicationDoctor});
  Medication.fromJson(Map<String, dynamic> json) {
    medicationTitle = json['medication-title'];
    medicationText = json['medication-text'];
    medicationDoctor = json['medication-doctor'];
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

class Vaccination {
  String vaccinationName;
  String vaccinationDate;
  String vaccinationAge;
  String vaccinationDoctor;
 int index;
  Vaccination(
      {this.vaccinationName,
        this.vaccinationDate,
        this.vaccinationAge,
        this.vaccinationDoctor});

  Vaccination.fromJson(Map<String, dynamic> json) {
    vaccinationName = json['vaccination-name'];
    vaccinationDate = json['vaccination-date'];
    vaccinationAge = json['vaccination-age'];
    vaccinationDoctor = json['vaccination-doctor'];
    index = json['index'];

  }
  Map<String, dynamic> toJson() {
    List<String>x=["name", "data","age"];
     Map<String, dynamic> data = new Map<String, dynamic>();
    //data['index'] = this.index;
    data['vaccination-name'] = this.vaccinationName;
    data['vaccination-date'] = this.vaccinationDate;
    data['vaccination-age'] = this.vaccinationAge;
    //data['vaccination-doctor'] = this.vaccinationDoctor;
    return data;
  }
}
class Consebt {
  String title;
  String description;
  String image;
  String video;
  String audio;
  String doctor;
  int index;

  Consebt(
      {this.title,
        this.description,
        this.image,
        this.video,
        this.audio,
        this.doctor});

  Consebt.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    image = json["image"] /*== null? [] : List<String>.from(json["image"].map((x) => x))*/;
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }



}
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

class NonRadiology {
  List<NervousSystem> nervousSystem;
  List<Skin> skin;
  List<Eye> eye;
  List<MusculoskeletalSystem> musculoskeletalSystem;
  List<CardiovascularSystem> cardiovascularSystem;
  List<Blood> blood;
  List<DigestiveSystem> digestiveSystem;
  List<GenitalSystem> genitalSystem;
  List<Prenatal> prenatal;
  List<Infertility> infertility;
  List<LymphaticSystem> lymphaticSystem;
  List<Others> others;

  NonRadiology({this.nervousSystem,
        this.skin,
        this.eye,
        this.musculoskeletalSystem,
        this.cardiovascularSystem,
        this.blood,
        this.digestiveSystem,
        this.genitalSystem,
        this.prenatal,
        this.infertility,
        this.lymphaticSystem,
        this.others});

  NonRadiology.fromJson(Map<String, dynamic> json) {
    if (json['nervous-system'] != null) {
      nervousSystem = new List<NervousSystem>();
      json['nervous-system'].forEach((v) {
        nervousSystem.add(new NervousSystem.fromJson(v));
      });
    }
    if (json['skin'] != null) {
      skin = new List<Skin>();
      json['skin'].forEach((v) {
        skin.add(new Skin.fromJson(v));
      });
    }
    if (json['eye'] != null) {
      eye = new List<Eye>();
      json['eye'].forEach((v) {
        eye.add(new Eye.fromJson(v));
      });
    }
    if (json['musculoskeletal-system'] != null) {
      musculoskeletalSystem = new List<MusculoskeletalSystem>();
      json['musculoskeletal-system'].forEach((v) {
        musculoskeletalSystem.add(new MusculoskeletalSystem.fromJson(v));
      });
    }
    if (json['cardiovascular-system'] != null) {
      cardiovascularSystem = new List<CardiovascularSystem>();
      json['cardiovascular-system'].forEach((v) {
        cardiovascularSystem.add(new CardiovascularSystem.fromJson(v));
      });
    }
    if (json['blood'] != null) {
      blood = new List<Blood>();
      json['blood'].forEach((v) {
        blood.add(new Blood.fromJson(v));
      });
    }
    if (json['digestive-system'] != null) {
      digestiveSystem = new List<DigestiveSystem>();
      json['digestive-system'].forEach((v) {
        digestiveSystem.add(new DigestiveSystem.fromJson(v));
      });
    }
    if (json['genital-system'] != null) {
      genitalSystem = new List<GenitalSystem>();
      json['genital-system'].forEach((v) {
        genitalSystem.add(new GenitalSystem.fromJson(v));
      });
    }
    if (json['prenatal'] != null) {
      prenatal = new List<Prenatal>();
      json['prenatal'].forEach((v) {
        prenatal.add(new Prenatal.fromJson(v));
      });
    }
    if (json['infertility'] != null) {
      infertility = new List<Infertility>();
      json['infertility'].forEach((v) {
        infertility.add(new Infertility.fromJson(v));
      });
    }
    if (json['lymphatic-system'] != null) {
      lymphaticSystem = new List<LymphaticSystem>();
      json['lymphatic-system'].forEach((v) {
        lymphaticSystem.add(new LymphaticSystem.fromJson(v));
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

class NervousSystem {
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

  NervousSystem(
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

  NervousSystem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class Skin {
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

  Skin(
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

  Skin.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class Eye {
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

  Eye(
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

  Eye.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class MusculoskeletalSystem {
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

  MusculoskeletalSystem(
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

  MusculoskeletalSystem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class CardiovascularSystem {
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

  CardiovascularSystem(
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

  CardiovascularSystem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class Blood {
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

  Blood(
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

  Blood.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class DigestiveSystem {
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

  DigestiveSystem(
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

  DigestiveSystem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class GenitalSystem {
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

  GenitalSystem(
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

  GenitalSystem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class Prenatal {
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

  Prenatal(
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

  Prenatal.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class Infertility {
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

  Infertility(
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

  Infertility.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class LymphaticSystem {
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

  LymphaticSystem(
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

  LymphaticSystem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }
}



class Radiology {
  List<Xray> xray;
  List<CtScan> ctScan;
  List<Mri> mri;
  List<Ultrasound> ultrasound;
  List<IsotopeScan> isotopeScan;
  List<Others> others;

  Radiology(
      {this.xray,
        this.ctScan,
        this.mri,
        this.ultrasound,
        this.isotopeScan,
        this.others});

  Radiology.fromJson(Map<String, dynamic> json) {
    if (json['xray'] != null) {
      xray = new List<Xray>();
      json['xray'].forEach((v) {
        xray.add(new Xray.fromJson(v));
      });
    }
    if (json['ct-scan'] != null) {
      ctScan = new List<CtScan>();
      json['ct-scan'].forEach((v) {
        ctScan.add(new CtScan.fromJson(v));
      });
    }
    if (json['mri'] != null) {
      mri = new List<Mri>();
      json['mri'].forEach((v) {
        mri.add(new Mri.fromJson(v));
      });
    }
    if (json['ultrasound'] != null) {
      ultrasound = new List<Ultrasound>();
      json['ultrasound'].forEach((v) {
        ultrasound.add(new Ultrasound.fromJson(v));
      });
    }
    if (json['isotope-scan'] != null) {
      isotopeScan = new List<IsotopeScan>();
      json['isotope-scan'].forEach((v) {
        isotopeScan.add(new IsotopeScan.fromJson(v));
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

class Xray {
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

  Xray(
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

  Xray.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class CtScan {
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

  CtScan(
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

  CtScan.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class Mri {
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

  Mri(
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

  Mri.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class Ultrasound {
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

  Ultrasound(
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

  Ultrasound.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}

class IsotopeScan {
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

  IsotopeScan(
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

  IsotopeScan.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    date = json['date'];
    result = json['result'];
    normalValue = json['normal_value'];
    report = json['report'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    result_image = json['result_image'];
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

}



class VitalSigns {
  int index;
  String id;
  String heart_rate;
  String respiratory_rate;
  String blood_pressure;
  String temperature;
  String blood_sugar;
  String other;
  String date;
  String vital_file;
  String doctor;



  VitalSigns.fromJson(Map<String, dynamic> json) {

    index = json['index'];
    id = json['sick_id'];
    heart_rate = json['heart-rate'];
    respiratory_rate = json['respiratory-rate'];
    blood_pressure = json['blood_pressure'];
    temperature = json['temperature'];
    blood_sugar = json['blood_sugar'];
    other = json['other'];
    date = json['date'];
    vital_file = json['vital_file'];
    doctor = json['doctor'];
  }
}




