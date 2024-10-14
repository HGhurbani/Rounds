class LoginDoctor {
  String st;
  int id;
  String name;
  String username;
  String email;
  String registerDate;

  LoginDoctor(
      {this.st,
        this.id,
        this.name,
        this.username,
        this.email,
        this.registerDate});

  LoginDoctor.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    registerDate = json['register_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['st'] = this.st;
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['register_date'] = this.registerDate;
    return data;
  }
}