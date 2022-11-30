import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blog_app/repository/user_repository.dart';
import '../appColors.dart';

SharedPreferences? prefs;

class ResetPasswordSheet extends StatefulWidget {
  final String email;
  ResetPasswordSheet(this.email);

  @override
  _ResetPasswordSheetState createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<ResetPasswordSheet> {
  var width, height;
  bool showtextInput = false;
  UserController? userController;

  void showToast(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 5,
        backgroundColor: appMainColor,
        textColor: Colors.white);
  }

//key for validation of input fields
  GlobalKey<FormState> key = GlobalKey<FormState>();
  var email, password;
  String? _id;
  String? _otp;
  @override
  void initState() {
    userController = UserController();
    getValuesofShared();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.close),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          _buildTextFields(),
          const SizedBox(
            height: 20.0,
          ),
          _buildSignInButton(context),
          SizedBox(
            height: 0.05 * height,
          ),
        ],
      ),
    );
  }

  _buildTextFields() {
    return Form(
      key: userController?.resetFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.length <= 0 && v.length > 5) {
                    return allMessages.value.enterAValidOtp;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController!.user?.otp = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        width: 10,
                        height: 10,
                        child: Image.asset("assets/img/otp.png")),
                    hintText: allMessages.value.otp,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.text,
                validator: (v) {
                  if (v!.length <= 7) {
                    return allMessages.value.enterAValidPassword;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController?.user?.password = v;
                  });
                },
                obscureText: userController!.forgotHidePassword ?? false,
                decoration: InputDecoration(
                    prefixIcon: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        width: 10,
                        height: 10,
                        child: Image.asset("assets/img/lock.png")),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          userController!.forgotHidePassword =
                              !(userController!.forgotHidePassword ?? false);
                        });
                      },
                      color: Theme.of(context).focusColor,
                      icon: Icon(userController!.forgotHidePassword ?? false
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    hintText: allMessages.value.newEnterPassword ??
                        'New Enter Password',
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.text,
                validator: (v) {
                  if (v!.length <= 7) {
                    return allMessages.value.enterAValidPassword;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController?.user!.cpassword = v;
                  });
                },
                obscureText: userController!.forgotHidePassword ?? false,
                decoration: InputDecoration(
                    prefixIcon: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        width: 10,
                        height: 10,
                        child: Image.asset("assets/img/lock.png")),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          userController!.forgotHidePassword =
                              !(userController!.forgotHidePassword ?? false);
                        });
                      },
                      color: Theme.of(context).focusColor,
                      icon: Icon(userController!.forgotHidePassword ?? false
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    hintText:
                        allMessages.value.reEnterPassword, //allMessages.value.
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
            allMessages.value.resetPassword.toString(),
            style: Theme.of(context).textTheme.headline3,
          ),
          onPressed: () {
            setState(() {
              userController?.resetPassword(context, widget.email);
            });
          },
        ),
      ),
    );
  }

  void getValuesofShared() async {
    prefs = GetIt.instance<SharedPreferencesUtils>().prefs!;
    _otp = prefs?.getString('otp')!;
  }
}
