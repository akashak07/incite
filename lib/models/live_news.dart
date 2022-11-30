class LiveNewsModel {
  int? id;
  String? image;
  String? companyName;
  String? url;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  LiveNewsModel(
      {this.id,
      this.image,
      this.companyName,
      this.url,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  LiveNewsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    companyName = json['company_name'];
    url = json['url'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['company_name'] = this.companyName;
    data['url'] = this.url;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
