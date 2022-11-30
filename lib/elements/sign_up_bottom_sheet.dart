import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:blog_app/elements/sign_in_bottom_sheet.dart';

import '../appColors.dart';
import '../app_theme.dart';

class SignUpBottomSheet extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  SignUpBottomSheet(this.scaffoldKey);
  @override
  _SignUpBottomSheetState createState() => _SignUpBottomSheetState();
}

class _SignUpBottomSheetState extends State<SignUpBottomSheet> {
  UserController? userController;
  var width, height;

  GlobalKey<FormState> key = GlobalKey<FormState>();
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
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0)),
          ),
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
                height: height * 0.05,
              ),
              Text(
                allMessages.value.signUp.toString(),
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
                height: 20,
              ),
              _buildSignInButton(context),
              _buildOldUserRichText(),
            ],
          ),
        ),
      ),
    );
  }

  _buildTextFields() {
    return Form(
      key: userController!.signupFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                validator: (v) {
                  if (v!.length <= 0) {
                    return allMessages.value.enterAValidUserName;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController!.user?.name = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.faceProfile),
                    hintText: allMessages.value.userName,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  bool emailValid =
                      RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                          .hasMatch(v!);
                  if (v.length <= 0) {
                    return allMessages.value.enterAValidEmail;
                  } else if (!emailValid) {
                    return allMessages.value.enterAValidEmail;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController!.user!.email = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.email),
                    hintText: allMessages.value.email,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (v) {
                  // if (v!.length <= 0) {
                  //   return allMessages.value.enterAValidPhoneNumber;
                  // }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController!.user?.phone = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.phone),
                    hintText: '${allMessages.value.phoneNumber} (Optional)',
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                validator: (v) {
                  if (v!.length <= 7) {
                    return allMessages.value.enterAValidPassword;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController!.user?.password = v;
                  });
                },
                obscureText: userController!.hidePassword ?? false,
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.key),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          userController!.hidePassword =
                              !(userController!.hidePassword ?? false);
                        });
                      },
                      color: Theme.of(context).focusColor,
                      icon: Icon(userController!.hidePassword ?? false
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    hintText: allMessages.value.password,
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
            allMessages.value.signUp.toString(),
            style: Theme.of(context).textTheme.headline3,
          ),
          onPressed: () {
            userController!.register(context);
          },
        ),
      ),
    );
  }

  _buildOldUserRichText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            // showModalBottomSheet(
            //     isScrollControlled: true,
            //     backgroundColor: Colors.transparent,
            //     context: context,
            //     builder: (context) {
            //       return SignInBottomSheet(widget.scaffoldKey);
            //     });
          },
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: allMessages.value.alreadyHaveAnAccount,
                  style: Theme.of(context).textTheme.headline6),
              TextSpan(
                  text: ' ${allMessages.value.signIn}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.copyWith(color: appMainColor))
            ]),
          ),
        ),
      ),
    );
  }
}
