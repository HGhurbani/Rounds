class TeamsModel {
  String st;
  String username;
  String avatar;
  List<Team> team;

  TeamsModel({this.st, this.team});

  TeamsModel.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    username = json['username'];
    avatar = json['avatar'];
    if (json['team'] != null) {
      team = new List<Team>();
      json['team'].forEach((v) {
        team.add(new Team.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['st'] = this.st;
    if (this.team != null) {
      data['team'] = this.team.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Team {
  int id;
  String name;
  String username;
  String email;
  String registerDate;
  String avatar;

  Team(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.registerDate,
      this.avatar});

  Team.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    registerDate = json['register_date'];
    avatar = json['avatar'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['register_date'] = this.registerDate;
    data['avatar'] = this.avatar;
    return data;
  }
}
