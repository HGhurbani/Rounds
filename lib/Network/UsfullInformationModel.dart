class UsfullInformationModel {
  String st;
  List<Information> information;

  UsfullInformationModel({this.st, this.information});

  UsfullInformationModel.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    if (json['information'] != null) {
      information = new List<Information>();
      json['information'].forEach((v) {
        information.add(new Information.fromJson(v));
      });
    }
  }

 }

class Information {
  String title;
  String description;
  List<String> image;
  String video;
  String audio;
  String doctor;
  int index;

  Information(
      {this.title,
        this.description,
        this.image,
        this.video,
        this.audio,
        this.doctor,
        this.index
      });

  Information.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    image = json["image"] == null? [] : List<String>.from(json["image"].map((x) => x));
    video = json['video'];
    audio = json['audio'];
    doctor = json['doctor'];
    index = json['index'];

  }

 }