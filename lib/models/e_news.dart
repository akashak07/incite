class ENews {
  int? id;
  String? image;
  String? paperName;
  String? pdf;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  ENews(
      {this.id,
      this.image,
      this.paperName,
      this.pdf,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  ENews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    paperName = json['paper_name'];
    pdf = json['pdf'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['paper_name'] = this.paperName;
    data['pdf'] = this.pdf;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
