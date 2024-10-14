class RestPassword {
  String st;
  String msg;

  RestPassword({this.st, this.msg});

  RestPassword.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['st'] = this.st;
    data['msg'] = this.msg;
    return data;
  }
}