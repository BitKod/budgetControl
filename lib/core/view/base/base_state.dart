
import 'package:budgetControl/inApp/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:budgetControl/core/constants/app_constants.dart';
import 'package:budgetControl/core/constants/app_strings.dart';


abstract class BaseState<T extends StatefulWidget> extends State<T> {


  // Firebase Auth
  final AuthService _auth = AuthService();
  String userUid;
  getUserUid() async {
    String _userUid = await _auth.currentUserUid;
    setState(
      () {
        userUid = _userUid;
      },
    );
  }

  //widget process status
  bool loading = false;
  String error = '';

  ThemeData get currentTheme => Theme.of(context);

  AppStrings get appStrings => AppStrings.instance;
  AppConstants get appConstants => AppConstants.instance;

  double dynamicHeight(double val) => MediaQuery.of(context).size.height * val;
  double dynamicWidth(double val) => MediaQuery.of(context).size.width * val;

  EdgeInsets insetsAll(double val) => EdgeInsets.all(dynamicHeight(val));
  EdgeInsets insetHorizontal(double val) =>
      EdgeInsets.symmetric(horizontal: dynamicHeight(val));
  EdgeInsets insetVertical(double val) =>
      EdgeInsets.symmetric(horizontal: dynamicHeight(val));
}
