import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/elements/sign_up_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'package:mdi/mdi.dart';

import '../appColors.dart';
import 'package:blog_app/repository/user_repository.dart';

import '../app_theme.dart';

class ForgotPasswordSheet extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  ForgotPasswordSheet(this.scaffoldKey);

  @override
  _ForgotPasswordSheetState createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  var width, height;
  UserController? userController;

//key for validation of input fields
  GlobalKey<FormState> key = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var email, password;
  @override
  void initState() {
    userController = UserController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: height * 0.05,
              ),
              Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    margin: EdgeInsets.only(left: 08, right: 08),
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
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  /*
                  Text(
                    'Settings page',
                    style: Theme.of(context).textTheme.bodyText1?.merge(
                      TextStyle(
                          color: appMainColor,
                          fontFamily: 'Montserrat',
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold),
                    ),
                    textAlign: TextAlign.left,
                  ),
        */
                ],
              ),
              SizedBox(
                height: height * 0.15,
              ),
              Text(
                allMessages.value.forgotPassword.toString(),
                style: Theme.of(context).textTheme.headline3?.merge(
                      TextStyle(
                          color: appThemeModel.value.isDarkModeEnabled.value
                              ? Colors.white
                              : appMainColor,
                          fontFamily: 'Montserrat',
                          fontSize: 35,
                          fontWeight: FontWeight.bold),
                    ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              _buildTextFields(),
              SizedBox(
                height: 20.0,
              ),
              _buildSignInButton(context),
              SizedBox(
                height: 0.05 * height,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(' ${allMessages.value.signIn}',
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            ?.copyWith(color: appMainColor)),
                  ),
                  Text(' | ', style: Theme.of(context).textTheme.headline5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SignUpBottomSheet(scaffoldKey),
                          ));
                    },
                    child: Text(' ${allMessages.value.signUp}',
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            ?.copyWith(color: appMainColor)),
                  )
                ],
              ),
              SizedBox(
                height: 0.05 * height,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildTextFields() {
    return Form(
      key: userController!.forgetFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.length <= 0) {
                    return allMessages.value.enterAValidEmail;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController?.user?.email = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.account),
                    hintText: allMessages.value.email,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
        ],
      ),
    );
  }

  _buildSignInButton(BuildContext context) {
    return Center(
      child: ButtonTheme(
        minWidth: 0.85 * width,
        height: 0.075 * height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: appMainColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
          child: Text(
            allMessages.value.submit.toString(),
            style: Theme.of(context).textTheme.headline3,
          ),
          onPressed: () {
            userController?.forgetPassword(context);
          },
        ),
      ),
    );
  }
}
