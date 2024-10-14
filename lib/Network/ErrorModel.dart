class Error {
  String st;
  String msg;

  Error({this.st, this.msg});

  Error.fromJson(Map<String, dynamic> json) {
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