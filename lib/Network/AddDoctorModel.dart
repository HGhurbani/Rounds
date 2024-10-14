class AddDoctor {
  String st;
  int doctorId;

  AddDoctor({this.st, this.doctorId});

  AddDoctor.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    doctorId = json['doctor_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['st'] = this.st;
    data['doctor_id'] = this.doctorId;
    return data;
  }
}