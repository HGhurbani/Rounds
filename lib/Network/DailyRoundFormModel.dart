class DailyRoundForm {
  String st;
  String msg;
  String findings;
  String comments;
  String reminder;
  List<Plan> plan;
  List<Consultations> consultations;

  DailyRoundForm(
      {this.st,
        this.msg,
        this.findings,
        this.comments,
        this.reminder,
        this.plan,
        this.consultations});

  DailyRoundForm.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    msg = json['msg'];
    findings = json['findings'];
    comments = json['comments'];
    reminder = json['reminder'];
    if (json['plan'] != null) {
      plan = new List<Plan>();
      json['plan'].forEach((v) {
        plan.add(new Plan.fromJson(v));
      });
    }
    if (json['consultations'] != null) {
      consultations = new List<Consultations>();
      json['consultations'].forEach((v) {
        consultations.add(new Consultations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['st'] = this.st;
    data['findings'] = this.findings;
    data['comments'] = this.comments;
    data['reminder'] = this.reminder;
    if (this.plan != null) {
      data['plan'] = this.plan.map((v) => v.toJson()).toList();
    }
    if (this.consultations != null) {
      data['consultations'] =
          this.consultations.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Plan {
  int index;
  String text;
  String carried;

  Plan({this.index, this.text, this.carried});

  Plan.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    text = json['text'];
    carried = json['carried'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['index'] = this.index;
    data['text'] = this.text;
    data['carried'] = this.carried;
    return data;
  }
}

class Consultations {
  int index;
  String to;
  String why;
  String replay;

  Consultations({this.index, this.to, this.why, this.replay});

  Consultations.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    to = json['to'];
    why = json['why'];
    replay = json['replay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['index'] = this.index;
    data['to'] = this.to;
    data['why'] = this.why;
    data['replay'] = this.replay;
    return data;
  }
}