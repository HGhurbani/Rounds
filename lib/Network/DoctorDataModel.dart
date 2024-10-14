class DoctorData {
  String doctorId;
  String added_by;
  String share_data_id;
  String d_email;
  String share_id;
  String doctor_username;
  String name;
  String status;
  String doctor_password;
  String username;
  String email;
  String registerDate;
  String avatar;
  List<Cloud> cloud;

  DoctorData(
      {this.doctorId,
      this.added_by,
      this.name,
        this.status,
        this.share_id,
        this.doctor_password,
      this.username,
      this.email,
      this.registerDate,
      this.avatar,
      this.cloud,
      this.share_data_id});

  DoctorData.fromJson(Map<String, dynamic> json) {
    doctorId = json['doctorId'];
    share_id = json['share_id'];
    share_data_id = json['share_data_id'];
    status = json['status'];
    added_by = json['added_by'];
    doctor_password = json['doctor_password'];
    d_email = json['email'];
    doctor_username = json['username'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    registerDate = json['register_date'];
    avatar = json['avatar'];
    if (json['cloud'] != null) {
      cloud = new List<Cloud>();
      json['cloud'].forEach((v) {
        cloud.add(new Cloud.fromJson(v));
      });
    }
  }
}

class Cloud {
  String cloudId;
  String fileTitle;
  String fileUrl;
  String cloud_url;
  int index;

  Cloud({this.cloudId, this.fileTitle, this.fileUrl, this.index});

  Cloud.fromJson(Map<String, dynamic> json) {
    cloudId = json['cloudId'];
    fileTitle = json['file-title'];
    fileUrl = json['file-url'];
    cloud_url = json['cloud-url'];
    index = json['index'];
  }
}
