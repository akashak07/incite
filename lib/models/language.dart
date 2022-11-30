import 'package:equatable/equatable.dart';

class Language extends Equatable {
  String? name;
  String? language;

  Language({this.name, this.language});

  Language.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    language = json['language'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['language'] = this.language;
    return data;
  }

  @override
  List<Object> get props => [name.toString(), language.toString()];
  @override
  bool get stringify => false;
}
