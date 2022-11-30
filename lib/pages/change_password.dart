import 'package:flutter/material.dart';

import '../appColors.dart';
import '../app_theme.dart';
import '../controllers/user_controller.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  UserController? userController = UserController();
  TextEditingController oldPass = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController conPass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: commonAppBar(context,
      //     width: MediaQuery.of(context).size.width, isProfile: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appMainColor,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).cardColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Change Password',
                    style: Theme.of(context).textTheme.bodyText1?.merge(
                          TextStyle(
                              color: appMainColor,
                              fontFamily: 'Montserrat',
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold),
                        ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              _changePasswordTextField(
                  title: "Old Password", controller: oldPass),
              const SizedBox(
                height: 10,
              ),
              _changePasswordTextField(
                  title: "New Password", controller: newPass),
              const SizedBox(
                height: 10,
              ),
              _changePasswordTextField(
                  title: "Confirm Password", controller: conPass),
              const SizedBox(
                height: 10,
              ),
              _buildChangeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  _buildChangeButton(BuildContext context) {
    return ButtonTheme(
      minWidth: 0.5 * MediaQuery.of(context).size.width,
      height: 0.057 * MediaQuery.of(context).size.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffff914d),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        onPressed: () {
          print('Password Password Password');
          userController?.changePassword(
            context,
            oldPass: oldPass.text,
            newPass: newPass.text,
            conPass: conPass.text,
          );
        },
        child: Text(
          "Change Password",
          style: Theme.of(this.context).textTheme.bodyText1?.merge(
                const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal),
              ),
        ),
      ),
    );
  }

  _changePasswordTextField(
      {String? title, required TextEditingController controller}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title ?? "",
        style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16.0,
            color: appThemeModel.value.isDarkModeEnabled.value
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.normal),
      ),
      TextField(
          controller: controller,
          style: Theme.of(this.context).textTheme.bodyText1?.merge(TextStyle(
              color: appThemeModel.value.isDarkModeEnabled.value
                  ? Colors.white
                  : Colors.black,
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              fontWeight: FontWeight.normal))),
    ]);
  }
}
