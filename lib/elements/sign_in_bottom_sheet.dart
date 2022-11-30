import 'package:blog_app/elements/forgot_password_sheet.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:mdi/mdi.dart';

import 'package:blog_app/elements/sign_up_bottom_sheet.dart';
import '../appColors.dart';
import '../app_theme.dart';
import '../controllers/user_controller.dart';

class SignInBottomSheet extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  SignInBottomSheet(this.scaffoldKey);

  @override
  _SignInBottomSheetState createState() => _SignInBottomSheetState();
}

class _SignInBottomSheetState extends StateMVC<SignInBottomSheet> {
  UserController? userController;
  var width, height;
  bool isLoading = false;
  var email, password;

  @override
  void initState() {
    userController = UserController();
    super.initState();
  }

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
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: height * 0.15,
              ),
              Text(
                allMessages.value.signIn.toString(),
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
              Padding(
                padding:
                    const EdgeInsets.only(right: 20.0, top: 10.0, bottom: 30.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ForgotPasswordSheet(widget.scaffoldKey),
                        ));
                    // showModalBottomSheet(
                    //     context: context,
                    //     backgroundColor: Colors.transparent,
                    //     isScrollControlled: true,
                    //     builder: (context) =>
                    //         ForgotPasswordSheet(widget.scaffoldKey));
                  },
                  child: Text(
                    allMessages.value.forgotPassword.toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ),
              _buildSignInButton(context),
              _buildNewUserRichText(),
            ],
          ),
        ),
      ),
    );
  }

  _buildTextFields() {
    return Form(
      key: userController!.loginFormKey,
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
                    userController!.user!.email = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.account),
                    hintText: allMessages.value.email,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.text,
                validator: (v) {
                  if (v!.length < 3) {
                    return allMessages
                        .value.passwordShouldBeMoreThanThereeCharacter;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController!.user!.password = v;
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
            allMessages.value.signIn.toString(),
            style: Theme.of(context).textTheme.headline3,
          ),
          onPressed: () {
            setState(() {
              isLoading = true;
            });
            userController!.login(context);
          },
        ),
      ),
    );
  }

  _buildNewUserRichText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignUpBottomSheet(widget.scaffoldKey),
                ));
            // showModalBottomSheet(
            //     isScrollControlled: true,
            //     backgroundColor: Colors.transparent,
            //     context: context,
            //     builder: (context) {
            //       return SignUpBottomSheet(widget.scaffoldKey);
            //     });
          },
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: allMessages.value.newUser,
                  style: Theme.of(context).textTheme.headline6),
              TextSpan(
                  text: ' ${allMessages.value.signUp}',
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
