class GetAllReadyModel {
  String st;
  List<Orders> orders;
  String description;
  String title;
  String index;
  GetAllReadyModel(
      {this.st, this.orders, this.description, this.index, this.title});

  GetAllReadyModel.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    if (json['orders'] != null) {
      orders = new List<Orders>();
      json['orders'].forEach((v) {
        orders.add(new Orders.fromJson(v));
      });
    }
  }
}

class Orders {
  String title;
  String id;
  String description;
  String doctor;
  int index;

  Orders({this.title, this.description, this.doctor, this.index, this.id});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['orderId'];
    title = json['title'];
    description = json['description'];
    doctor = json['doctor'];
    index = json['index'];
  }
}
