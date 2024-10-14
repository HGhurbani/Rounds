class AddSickModel {
  String st;
  String msg;
  int userId;

  AddSickModel({this.st, this.userId});

  AddSickModel.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    userId = json['doctorId'];
    msg = json['msg'];
  }
}