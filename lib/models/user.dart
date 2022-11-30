class Users {
  String? id;
  String? name;
  String? email;
  String? password;
  String? apiToken;
  String? fbToken;
  String? phone;
  String? deviceToken;
  dynamic photo;
  bool? auth;
  bool? isPageHome;
  bool? isNewUser;
  String? otp;
  String? cpassword;
  String? langCode;
  String? loginFrom;
  Users();

  Users.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      phone = jsonMap['phone'] != null ? jsonMap['phone'] : '';
      apiToken = jsonMap['api_token'];
      fbToken = jsonMap['fb_token'] != null ? jsonMap['fb_token'] : '';
      otp = jsonMap['otp'] != null ? jsonMap['otp'].toString() : '';
      photo = jsonMap['photo'] != null ? jsonMap['photo'] : '';
      deviceToken = jsonMap['device_token'];
      isNewUser = jsonMap['isNewUser'];
      langCode = jsonMap['lang_code'];
      loginFrom = jsonMap['login_from'];
    } catch (e) {
      id = '';
      name = '';
      email = '';
      phone = '';
      apiToken = '';
      fbToken = '';
      photo = '';
      deviceToken = '';
      isNewUser = false;
    }
  }

}
