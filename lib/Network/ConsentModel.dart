class ConsentModel {
  String st;
  List<Consebts> consebts;

  ConsentModel({this.st, this.consebts});

  ConsentModel.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    if (json['consebts'] != null) {
      consebts = new List<Consebts>();
      json['consebts'].forEach((v) {
        consebts.add(new Consebts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['st'] = this.st;
    if (this.consebts != null) {
      data['consebts'] = this.consebts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Consebts {
  String title;
  String description;
  String videoUrl;
  String doctor;

  Consebts({this.title, this.description, this.videoUrl, this.doctor});

  Consebts.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    videoUrl = json['video_url'];
    doctor = json['doctor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['video_url'] = this.videoUrl;
    data['doctor'] = this.doctor;
    return data;
  }
}