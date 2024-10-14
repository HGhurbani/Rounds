class EducationModel {
  String st;
  List<Educations> educations;

  EducationModel({this.st, this.educations});

  EducationModel.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    if (json['educations'] != null) {
      educations =   List<Educations>();
      json['educations'].forEach((v) {
        educations.add(new Educations.fromJson(v));
      });
    }
  }

 }

class Educations {
  String title;
  String description;
  List<String> image;
  String video;
  String audio;
  String doctor;
  int index;

  Educations(
      {this.title,
        this.description,
        this.image,
        this.video,
        this.audio,
        this.doctor,
        this.index
      });

  Educations.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
     index = json['index'];

  }

 }